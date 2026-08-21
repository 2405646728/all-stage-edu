package com.asedu.base.service;

import com.asedu.base.dto.ClassAssignDTO;
import com.asedu.base.dto.EnrollmentChangeDTO;
import com.asedu.base.dto.StudentSaveDTO;
import com.asedu.base.entity.BaseClass;
import com.asedu.base.entity.BaseClassStudent;
import com.asedu.base.entity.BaseSchoolYear;
import com.asedu.base.entity.BaseStudent;
import com.asedu.base.entity.BaseStudentEnrollment;
import com.asedu.base.entity.BaseStudentStatusChange;
import com.asedu.base.mapper.BaseClassMapper;
import com.asedu.base.mapper.BaseClassStudentMapper;
import com.asedu.base.mapper.BaseStudentEnrollmentMapper;
import com.asedu.base.mapper.BaseStudentMapper;
import com.asedu.base.mapper.BaseStudentStatusChangeMapper;
import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Map;

/**
 * 学生服务：主档 CRUD / 学籍自动建档 / 学籍异动台账 / 分班调班
 */
@Service
@RequiredArgsConstructor
public class StudentService {

    private final BaseStudentMapper studentMapper;
    private final BaseStudentEnrollmentMapper enrollmentMapper;
    private final BaseStudentStatusChangeMapper statusChangeMapper;
    private final BaseClassStudentMapper classStudentMapper;
    private final BaseClassMapper classMapper;
    private final com.asedu.base.mapper.BaseSchoolYearMapper schoolYearMapper;
    private final com.asedu.sys.mapper.SysOrgMapper sysOrgMapper;

    private Long resolveOrgId(Long orgId) {
        if (UserContext.isSuperAdmin()) {
            if (orgId == null) {
                throw new BusinessException("平台超级管理员操作机构数据必须指定 orgId");
            }
            return orgId;
        }
        Long mine = UserContext.orgId();
        if (mine == null) {
            throw new BusinessException("当前账号未绑定机构");
        }
        return mine;
    }

    public PageResult<BaseStudent> page(long current, long size, Long orgId, String keyword,
                                        Long gradeId, Long classId, String studyStatus) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<BaseStudent> qw = new LambdaQueryWrapper<BaseStudent>()
                .eq(BaseStudent::getOrgId, oid)
                .eq(studyStatus != null && !studyStatus.isBlank(), BaseStudent::getStudyStatus, studyStatus);
        if (keyword != null && !keyword.isBlank()) {
            qw.and(w -> w.like(BaseStudent::getName, keyword)
                    .or().like(BaseStudent::getStudentNo, keyword)
                    .or().like(BaseStudent::getIdCard, keyword));
        }
        if (classId != null) {
            qw.eq(BaseStudent::getCurrentClassId, classId);
        } else if (gradeId != null) {
            qw.inSql(BaseStudent::getCurrentClassId,
                    "SELECT id FROM base_class WHERE org_id=" + oid + " AND grade_id=" + gradeId);
        }
        qw.orderByDesc(BaseStudent::getCreatedAt);
        Page<BaseStudent> page = studentMapper.selectPage(new Page<>(current, size), qw);
        return PageResult.of(page);
    }

    public BaseStudent detail(Long id) {
        BaseStudent student = studentMapper.selectById(id);
        if (student == null) {
            throw new BusinessException("学生不存在");
        }
        return student;
    }

    @Transactional
    public BaseStudent create(StudentSaveDTO dto) {
        Long oid = resolveOrgId(dto.getOrgId());
        // 学号唯一查重（文档：以学籍号/身份证号为唯一主键自动查重，杜绝重复建档）
        Long dup = studentMapper.selectCount(new LambdaQueryWrapper<BaseStudent>()
                .eq(BaseStudent::getOrgId, oid).eq(BaseStudent::getStudentNo, dto.getStudentNo()));
        if (dup != null && dup > 0) {
            throw new BusinessException("学号已存在：" + dto.getStudentNo());
        }
        BaseStudent student = new BaseStudent();
        BeanUtils.copyProperties(dto, student);
        student.setId(null);
        student.setOrgId(oid);
        if (student.getStage() == null || student.getStage().isBlank()) {
            // 学段自动判定：以机构学段为唯一依据（文档 12.2 冻结规则）
            student.setStage(orgStage(oid));
        }
        if (student.getStudyStatus() == null || student.getStudyStatus().isBlank()) {
            student.setStudyStatus("normal");
        }
        studentMapper.insert(student);
        // 学籍自动建档（标准化学籍档案）
        createEnrollment(student, oid);
        // 自动分班（录入时指定班级）
        if (student.getCurrentClassId() != null) {
            ClassAssignDTO assign = new ClassAssignDTO();
            assign.setStudentId(student.getId());
            assign.setClassId(student.getCurrentClassId());
            assign.setEnterType("assigned");
            assign.setEnterDate(student.getAdmitDate());
            assignClass(assign, student);
        }
        return student;
    }

    private String orgStage(Long orgId) {
        com.asedu.sys.entity.SysOrg org = sysOrgMapper.selectById(orgId);
        return org == null ? null : org.getStage();
    }

    private void createEnrollment(BaseStudent student, Long oid) {
        BaseStudentEnrollment en = new BaseStudentEnrollment();
        en.setOrgId(oid);
        en.setStudentId(student.getId());
        en.setStage(student.getStage());
        en.setSchoolingYears(schoolingYears(student.getStage()));
        en.setEnrollDate(student.getAdmitDate() == null ? LocalDate.now() : student.getAdmitDate());
        en.setEnrollBatch(student.getAdmitBatch());
        en.setCurrentClassId(student.getCurrentClassId());
        en.setCurrentGradeId(classGradeId(student.getCurrentClassId()));
        en.setEnrollStatus(mapEnrollStatus(student.getStudyStatus()));
        // 学籍号自动生成：学段前缀 + 年份 + 序号
        String prefix = switch (student.getStage() == null ? "" : student.getStage()) {
            case "kindergarten" -> "KGXJ";
            case "primary" -> "PSXJ";
            case "junior" -> "MSXJ";
            case "senior" -> "HSXJ";
            case "vocational" -> "VSXJ";
            case "university" -> "UNXJ";
            default -> "XJ";
        };
        en.setEnrollNo(prefix + LocalDate.now().getYear()
                + String.format("%04d", student.getId() % 10000));
        enrollmentMapper.insert(en);
    }

    private Long classGradeId(Long classId) {
        if (classId == null) {
            return null;
        }
        BaseClass c = classMapper.selectById(classId);
        return c == null ? null : c.getGradeId();
    }

    private Integer schoolingYears(String stage) {
        return switch (stage == null ? "" : stage) {
            case "kindergarten" -> 3;
            case "primary" -> 6;
            case "junior", "senior", "vocational" -> 3;
            case "university" -> 4;
            default -> 0;
        };
    }

    private String mapEnrollStatus(String studyStatus) {
        if (studyStatus == null) {
            return "normal";
        }
        return switch (studyStatus) {
            case "suspended" -> "suspended";
            case "graduated" -> "graduated";
            case "withdrawn" -> "withdrawn";
            default -> "normal";
        };
    }

    @Transactional
    public BaseStudent update(Long id, StudentSaveDTO dto) {
        BaseStudent exist = detail(id);
        BaseStudent update = new BaseStudent();
        BeanUtils.copyProperties(dto, update);
        update.setId(id);
        update.setOrgId(exist.getOrgId());
        studentMapper.updateById(update);
        return detail(id);
    }

    @Transactional
    public void remove(Long id) {
        BaseStudent student = detail(id);
        studentMapper.deleteById(id);
        // 学籍注销留痕
        BaseStudentEnrollment en = enrollmentMapper.selectOne(new LambdaQueryWrapper<BaseStudentEnrollment>()
                .eq(BaseStudentEnrollment::getStudentId, id).last("LIMIT 1"));
        if (en != null) {
            recordChange(student, en, "deregister", "注销", "逻辑删除学生档案");
            enrollmentMapper.deleteById(en.getId());
        }
    }

    /** 学籍异动登记：写台账 + 同步学籍状态 + 同步学生就读状态（单向联动下游权限） */
    @Transactional
    public BaseStudentStatusChange enrollmentChange(EnrollmentChangeDTO dto) {
        BaseStudent student = detail(dto.getStudentId());
        BaseStudentEnrollment en = enrollmentMapper.selectOne(new LambdaQueryWrapper<BaseStudentEnrollment>()
                .eq(BaseStudentEnrollment::getStudentId, student.getId()).last("LIMIT 1"));
        if (en == null) {
            throw new BusinessException("该学生未建档学籍，请先建档");
        }
        BaseStudentStatusChange change = recordChange(student, en, dto.getChangeType(),
                dto.getChangeReason(), dto.getTargetOrgName());
        // 同步学籍与学生状态（before/after）
        String after = dto.getAfterStatus() == null ? mapEnrollStatus(dto.getChangeType()) : dto.getAfterStatus();
        en.setEnrollStatus(after);
        enrollmentMapper.updateById(en);
        if ("graduate".equals(dto.getChangeType())) {
            student.setStudyStatus("graduated");
            studentMapper.updateById(student);
        } else if ("suspend".equals(dto.getChangeType())) {
            student.setStudyStatus("suspended");
            studentMapper.updateById(student);
        } else if ("resume".equals(dto.getChangeType())) {
            student.setStudyStatus("normal");
            studentMapper.updateById(student);
        } else if ("withdraw".equals(dto.getChangeType()) || "deregister".equals(dto.getChangeType())
                || "transfer_out".equals(dto.getChangeType())) {
            student.setStudyStatus("left");
            studentMapper.updateById(student);
        }
        return change;
    }

    private BaseStudentStatusChange recordChange(BaseStudent student, BaseStudentEnrollment en,
                                                 String type, String reason, String target) {
        BaseStudentStatusChange change = new BaseStudentStatusChange();
        change.setOrgId(student.getOrgId());
        change.setStudentId(student.getId());
        change.setEnrollId(en.getId());
        change.setChangeType(type);
        change.setBeforeStatus(en.getEnrollStatus());
        change.setAfterStatus(mapEnrollStatus(type));
        change.setChangeReason(reason);
        change.setTargetOrgName(target == null ? "" : target);
        change.setAuditStatus("approved");
        change.setOperatorId(UserContext.userId());
        statusChangeMapper.insert(change);
        return change;
    }

    /** 分班/调班：写入班级学生关系 + 更新当前班级（升班/调班历史可追溯） */
    @Transactional
    public void assignClass(ClassAssignDTO dto, BaseStudent student) {
        BaseStudent s = student == null ? detail(dto.getStudentId()) : student;
        BaseClass target = classMapper.selectById(dto.getClassId());
        if (target == null) {
            throw new BusinessException("班级不存在");
        }
        // 原在班记录置为历史
        classStudentMapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<BaseClassStudent>()
                .eq(BaseClassStudent::getStudentId, s.getId())
                .eq(BaseClassStudent::getStatus, 1)
                .set(BaseClassStudent::getStatus, 0)
                .set(BaseClassStudent::getLeaveDate, dto.getEnterDate() == null ? LocalDate.now() : dto.getEnterDate()));
        BaseClassStudent rel = new BaseClassStudent();
        rel.setOrgId(s.getOrgId());
        rel.setStudentId(s.getId());
        rel.setClassId(dto.getClassId());
        BaseSchoolYear year = schoolYearMapper.selectOne(new LambdaQueryWrapper<BaseSchoolYear>()
                .eq(BaseSchoolYear::getOrgId, s.getOrgId())
                .eq(BaseSchoolYear::getStatus, 1).last("LIMIT 1"));
        rel.setSchoolYearId(year == null ? 0L : year.getId());
        rel.setEnterType(dto.getEnterType() == null ? "manual" : dto.getEnterType());
        rel.setEnterDate(dto.getEnterDate() == null ? LocalDate.now() : dto.getEnterDate());
        rel.setStatus(1);
        rel.setOperatorId(UserContext.userId());
        classStudentMapper.insert(rel);

        BaseStudent upd = new BaseStudent();
        upd.setId(s.getId());
        upd.setCurrentClassId(dto.getClassId());
        studentMapper.updateById(upd);
    }

    /** 学籍异动台账分页（全流程登记/审核/溯源） */
    public PageResult<BaseStudentStatusChange> pageStatusChange(long current, long size, Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<BaseStudentStatusChange> qw = new LambdaQueryWrapper<BaseStudentStatusChange>()
                .eq(BaseStudentStatusChange::getOrgId, oid)
                .eq(studentId != null, BaseStudentStatusChange::getStudentId, studentId)
                .orderByDesc(BaseStudentStatusChange::getCreatedAt);
        return PageResult.of(statusChangeMapper.selectPage(new Page<>(current, size), qw));
    }

    /** 分班/调班记录分页（每学年人员变动明细可追溯） */
    public PageResult<BaseClassStudent> pageClassStudent(long current, long size, Long orgId, Long studentId, Long classId) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<BaseClassStudent> qw = new LambdaQueryWrapper<BaseClassStudent>()
                .eq(BaseClassStudent::getOrgId, oid)
                .eq(studentId != null, BaseClassStudent::getStudentId, studentId)
                .eq(classId != null, BaseClassStudent::getClassId, classId)
                .orderByDesc(BaseClassStudent::getCreatedAt);
        return PageResult.of(classStudentMapper.selectPage(new Page<>(current, size), qw));
    }

    /** 学生数统计（看板支撑） */
    public Map<String, Long> countByStage(Long orgId) {
        Long oid = resolveOrgId(orgId);
        return Map.of("total", studentMapper.selectCount(new LambdaQueryWrapper<BaseStudent>()
                .eq(BaseStudent::getOrgId, oid)));
    }
}