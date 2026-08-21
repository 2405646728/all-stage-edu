package com.asedu.edu.service;

import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.edu.entity.EduCourse;
import com.asedu.edu.entity.EduResource;
import com.asedu.edu.entity.EduScheduleChange;
import com.asedu.edu.entity.EduSchedulePlan;
import com.asedu.edu.entity.EduTeachingRecord;
import com.asedu.edu.entity.EduTierStudent;
import com.asedu.edu.entity.EduWeakPoint;
import com.asedu.edu.mapper.EduCourseMapper;
import com.asedu.edu.mapper.EduResourceMapper;
import com.asedu.edu.mapper.EduScheduleChangeMapper;
import com.asedu.edu.mapper.EduSchedulePlanMapper;
import com.asedu.edu.mapper.EduTeachingRecordMapper;
import com.asedu.edu.mapper.EduTierStudentMapper;
import com.asedu.edu.mapper.EduWeakPointMapper;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 教务服务：课程体系/排课调课/教学纪实/资源库/薄弱点/分层
 */
@Service
@RequiredArgsConstructor
public class EduService {

    private final EduCourseMapper courseMapper;
    private final EduSchedulePlanMapper scheduleMapper;
    private final EduScheduleChangeMapper changeMapper;
    private final EduTeachingRecordMapper teachingMapper;
    private final EduResourceMapper resourceMapper;
    private final EduWeakPointMapper weakPointMapper;
    private final EduTierStudentMapper tierMapper;

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

    // ---------- 课程 ----------
    public List<EduCourse> listCourses(Long orgId, Long gradeId) {
        Long oid = resolveOrgId(orgId);
        return courseMapper.selectList(new LambdaQueryWrapper<EduCourse>()
                .eq(EduCourse::getOrgId, oid)
                .eq(gradeId != null, EduCourse::getGradeId, gradeId)
                .orderByAsc(EduCourse::getSubjectCode));
    }

    @Transactional
    public EduCourse saveCourse(EduCourse course) {
        course.setOrgId(resolveOrgId(course.getOrgId()));
        course.setCreatedBy(UserContext.userId());
        if (course.getId() == null) {
            courseMapper.insert(course);
        } else {
            courseMapper.updateById(course);
        }
        return course;
    }

    // ---------- 课表 ----------
    public List<EduSchedulePlan> listSchedules(Long orgId, Long termId, Long classId) {
        Long oid = resolveOrgId(orgId);
        return scheduleMapper.selectList(new LambdaQueryWrapper<EduSchedulePlan>()
                .eq(EduSchedulePlan::getOrgId, oid)
                .eq(termId != null, EduSchedulePlan::getTermId, termId)
                .eq(classId != null, EduSchedulePlan::getClassId, classId)
                .orderByAsc(EduSchedulePlan::getWeekday).orderByAsc(EduSchedulePlan::getSectionNo));
    }

    @Transactional
    public EduSchedulePlan saveSchedule(EduSchedulePlan plan) {
        plan.setOrgId(resolveOrgId(plan.getOrgId()));
        plan.setOperatorId(UserContext.userId());
        if (plan.getId() == null) {
            scheduleMapper.insert(plan);
        } else {
            scheduleMapper.updateById(plan);
        }
        return plan;
    }

    @Transactional
    public EduScheduleChange saveChange(EduScheduleChange change) {
        change.setOrgId(resolveOrgId(change.getOrgId()));
        change.setOperatorId(UserContext.userId());
        changeMapper.insert(change);
        return change;
    }

    // ---------- 教学纪实 ----------
    public PageResult<EduTeachingRecord> pageTeaching(long current, long size, Long orgId, Long classId) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<EduTeachingRecord> qw = new LambdaQueryWrapper<EduTeachingRecord>()
                .eq(EduTeachingRecord::getOrgId, oid)
                .eq(classId != null, EduTeachingRecord::getClassId, classId)
                .orderByDesc(EduTeachingRecord::getTeachDate);
        return PageResult.of(teachingMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public EduTeachingRecord saveTeaching(EduTeachingRecord record) {
        record.setOrgId(resolveOrgId(record.getOrgId()));
        if (record.getId() == null) {
            teachingMapper.insert(record);
        } else {
            teachingMapper.updateById(record);
        }
        return record;
    }

    // ---------- 资源库 ----------
    public List<EduResource> listResources(Long orgId, String subjectCode) {
        Long oid = resolveOrgId(orgId);
        return resourceMapper.selectList(new LambdaQueryWrapper<EduResource>()
                .eq(EduResource::getOrgId, oid)
                .eq(subjectCode != null && !subjectCode.isBlank(), EduResource::getSubjectCode, subjectCode)
                .orderByDesc(EduResource::getCreatedAt));
    }

    @Transactional
    public EduResource saveResource(EduResource resource) {
        resource.setOrgId(resolveOrgId(resource.getOrgId()));
        resource.setUploaderId(UserContext.userId());
        if (resource.getId() == null) {
            resourceMapper.insert(resource);
        } else {
            resourceMapper.updateById(resource);
        }
        return resource;
    }

    // ---------- 薄弱点 / 分层 ----------
    public List<EduWeakPoint> listWeakPoints(Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        return weakPointMapper.selectList(new LambdaQueryWrapper<EduWeakPoint>()
                .eq(EduWeakPoint::getOrgId, oid)
                .eq(studentId != null, EduWeakPoint::getStudentId, studentId)
                .orderByDesc(EduWeakPoint::getCreatedAt));
    }

    @Transactional
    public EduWeakPoint saveWeakPoint(EduWeakPoint wp) {
        wp.setOrgId(resolveOrgId(wp.getOrgId()));
        wp.setCreatedBy(UserContext.userId());
        if (wp.getId() == null) {
            weakPointMapper.insert(wp);
        } else {
            weakPointMapper.updateById(wp);
        }
        return wp;
    }

    public List<EduTierStudent> listTiers(Long orgId, Long termId) {
        Long oid = resolveOrgId(orgId);
        return tierMapper.selectList(new LambdaQueryWrapper<EduTierStudent>()
                .eq(EduTierStudent::getOrgId, oid)
                .eq(termId != null, EduTierStudent::getTermId, termId)
                .orderByDesc(EduTierStudent::getCreatedAt));
    }

    @Transactional
    public EduTierStudent saveTier(EduTierStudent tier) {
        tier.setOrgId(resolveOrgId(tier.getOrgId()));
        tier.setOperatorId(UserContext.userId());
        if (tier.getId() == null) {
            tierMapper.insert(tier);
        } else {
            tierMapper.updateById(tier);
        }
        return tier;
    }
}
