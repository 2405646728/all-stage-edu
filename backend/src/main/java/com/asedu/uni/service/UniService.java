package com.asedu.uni.service;

import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.asedu.uni.entity.UniAcademicWarning;
import com.asedu.uni.entity.UniActivity;
import com.asedu.uni.entity.UniClub;
import com.asedu.uni.entity.UniClubMember;
import com.asedu.uni.entity.UniComprehensiveEval;
import com.asedu.uni.entity.UniCourseOffer;
import com.asedu.uni.entity.UniCourseSelect;
import com.asedu.uni.entity.UniDegreePrecheck;
import com.asedu.uni.entity.UniDepartment;
import com.asedu.uni.entity.UniDormBed;
import com.asedu.uni.entity.UniDormBuilding;
import com.asedu.uni.entity.UniDormCheck;
import com.asedu.uni.entity.UniDormHygiene;
import com.asedu.uni.entity.UniDormRoom;
import com.asedu.uni.entity.UniDormStudent;
import com.asedu.uni.entity.UniEmployment;
import com.asedu.uni.entity.UniEvalItem;
import com.asedu.uni.entity.UniHealthRecord;
import com.asedu.uni.entity.UniInnovation;
import com.asedu.uni.entity.UniMajor;
import com.asedu.uni.entity.UniMakeupRetake;
import com.asedu.uni.entity.UniProgramCourse;
import com.asedu.uni.entity.UniRepair;
import com.asedu.uni.entity.UniScholarship;
import com.asedu.uni.entity.UniScore;
import com.asedu.uni.entity.UniThesis;
import com.asedu.uni.entity.UniThesisDefense;
import com.asedu.uni.entity.UniTrainingProgram;
import com.asedu.uni.mapper.UniAcademicWarningMapper;
import com.asedu.uni.mapper.UniActivityMapper;
import com.asedu.uni.mapper.UniClubMapper;
import com.asedu.uni.mapper.UniClubMemberMapper;
import com.asedu.uni.mapper.UniComprehensiveEvalMapper;
import com.asedu.uni.mapper.UniCourseOfferMapper;
import com.asedu.uni.mapper.UniCourseSelectMapper;
import com.asedu.uni.mapper.UniDegreePrecheckMapper;
import com.asedu.uni.mapper.UniDepartmentMapper;
import com.asedu.uni.mapper.UniDormBedMapper;
import com.asedu.uni.mapper.UniDormBuildingMapper;
import com.asedu.uni.mapper.UniDormCheckMapper;
import com.asedu.uni.mapper.UniDormHygieneMapper;
import com.asedu.uni.mapper.UniDormRoomMapper;
import com.asedu.uni.mapper.UniDormStudentMapper;
import com.asedu.uni.mapper.UniEmploymentMapper;
import com.asedu.uni.mapper.UniEvalItemMapper;
import com.asedu.uni.mapper.UniHealthRecordMapper;
import com.asedu.uni.mapper.UniInnovationMapper;
import com.asedu.uni.mapper.UniMajorMapper;
import com.asedu.uni.mapper.UniMakeupRetakeMapper;
import com.asedu.uni.mapper.UniProgramCourseMapper;
import com.asedu.uni.mapper.UniRepairMapper;
import com.asedu.uni.mapper.UniScholarshipMapper;
import com.asedu.uni.mapper.UniScoreMapper;
import com.asedu.uni.mapper.UniThesisDefenseMapper;
import com.asedu.uni.mapper.UniThesisMapper;
import com.asedu.uni.mapper.UniTrainingProgramMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 高校专属服务：院系专业/培养方案/选课绩点/综测评奖/科创社团/论文学位/宿舍后勤/就业健康
 * 对应文档 10.1.1 ~ 10.1.7
 */
@Service
@RequiredArgsConstructor
public class UniService {

    private final UniDepartmentMapper deptMapper;
    private final UniMajorMapper majorMapper;
    private final UniTrainingProgramMapper programMapper;
    private final UniProgramCourseMapper programCourseMapper;
    private final UniCourseOfferMapper offerMapper;
    private final UniCourseSelectMapper selectMapper;
    private final UniScoreMapper scoreMapper;
    private final UniMakeupRetakeMapper makeupMapper;
    private final UniAcademicWarningMapper warningMapper;
    private final UniComprehensiveEvalMapper evalMapper;
    private final UniEvalItemMapper evalItemMapper;
    private final UniScholarshipMapper scholarshipMapper;
    private final UniInnovationMapper innovationMapper;
    private final UniClubMapper clubMapper;
    private final UniClubMemberMapper clubMemberMapper;
    private final UniActivityMapper activityMapper;
    private final UniThesisMapper thesisMapper;
    private final UniThesisDefenseMapper defenseMapper;
    private final UniDegreePrecheckMapper precheckMapper;
    private final UniEmploymentMapper employmentMapper;
    private final UniDormBuildingMapper buildingMapper;
    private final UniDormRoomMapper roomMapper;
    private final UniDormBedMapper bedMapper;
    private final UniDormStudentMapper dormStudentMapper;
    private final UniDormCheckMapper dormCheckMapper;
    private final UniRepairMapper repairMapper;
    private final UniDormHygieneMapper hygieneMapper;
    private final UniHealthRecordMapper healthMapper;

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

    private <T> T upsert(T entity, com.baomidou.mybatisplus.core.mapper.BaseMapper<T> mapper, Long id) {
        if (id == null) {
            mapper.insert(entity);
        } else {
            mapper.updateById(entity);
        }
        return entity;
    }

    // ================= 院系专业 / 培养方案 =================
    public List<UniDepartment> listDepartments(Long orgId) {
        Long oid = resolveOrgId(orgId);
        return deptMapper.selectList(new LambdaQueryWrapper<UniDepartment>()
                .eq(UniDepartment::getOrgId, oid).orderByAsc(UniDepartment::getDeptCode));
    }

    public List<UniMajor> listMajors(Long orgId, Long deptId) {
        Long oid = resolveOrgId(orgId);
        return majorMapper.selectList(new LambdaQueryWrapper<UniMajor>()
                .eq(UniMajor::getOrgId, oid)
                .eq(deptId != null, UniMajor::getDeptId, deptId));
    }

    public List<UniTrainingProgram> listPrograms(Long orgId, Long majorId) {
        Long oid = resolveOrgId(orgId);
        return programMapper.selectList(new LambdaQueryWrapper<UniTrainingProgram>()
                .eq(UniTrainingProgram::getOrgId, oid)
                .eq(majorId != null, UniTrainingProgram::getMajorId, majorId));
    }

    public List<UniProgramCourse> listProgramCourses(Long programId) {
        return programCourseMapper.selectList(new LambdaQueryWrapper<UniProgramCourse>()
                .eq(UniProgramCourse::getProgramId, programId));
    }

    @Transactional
    public UniDepartment saveDepartment(UniDepartment dept) {
        dept.setOrgId(resolveOrgId(dept.getOrgId()));
        return upsert(dept, deptMapper, dept.getId());
    }

    @Transactional
    public UniMajor saveMajor(UniMajor major) {
        major.setOrgId(resolveOrgId(major.getOrgId()));
        return upsert(major, majorMapper, major.getId());
    }

    @Transactional
    public UniTrainingProgram saveProgram(UniTrainingProgram program) {
        program.setOrgId(resolveOrgId(program.getOrgId()));
        program.setCreatedBy(UserContext.userId());
        return upsert(program, programMapper, program.getId());
    }

    @Transactional
    public UniProgramCourse saveProgramCourse(UniProgramCourse pc) {
        return upsert(pc, programCourseMapper, pc.getId());
    }

    // ================= 开课 / 选课 / 成绩 =================
    public List<UniCourseOffer> listOffers(Long orgId, Long termId) {
        Long oid = resolveOrgId(orgId);
        return offerMapper.selectList(new LambdaQueryWrapper<UniCourseOffer>()
                .eq(UniCourseOffer::getOrgId, oid)
                .eq(termId != null, UniCourseOffer::getTermId, termId));
    }

    @Transactional
    public UniCourseOffer saveOffer(UniCourseOffer offer) {
        offer.setOrgId(resolveOrgId(offer.getOrgId()));
        offer.setCreatedBy(UserContext.userId());
        if (offer.getSelectedCount() == null) {
            offer.setSelectedCount(0);
        }
        return upsert(offer, offerMapper, offer.getId());
    }

    public List<UniCourseSelect> listSelects(Long orgId, Long offerId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        return selectMapper.selectList(new LambdaQueryWrapper<UniCourseSelect>()
                .eq(UniCourseSelect::getOrgId, oid)
                .eq(offerId != null, UniCourseSelect::getOfferId, offerId)
                .eq(studentId != null, UniCourseSelect::getStudentId, studentId));
    }

    /** 选课/退课（容量校验） */
    @Transactional
    public UniCourseSelect saveSelect(UniCourseSelect sel) {
        sel.setOrgId(resolveOrgId(sel.getOrgId()));
        if ("selected".equals(sel.getSelectStatus()) && sel.getId() == null) {
            UniCourseOffer offer = offerMapper.selectById(sel.getOfferId());
            if (offer != null && offer.getCapacity() != null
                    && offer.getSelectedCount() >= offer.getCapacity()) {
                throw new BusinessException("课程人数已满");
            }
        }
        if (sel.getId() == null) {
            selectMapper.insert(sel);
        } else {
            selectMapper.updateById(sel);
        }
        if (sel.getOfferId() != null && sel.getSelectStatus() != null) {
            UniCourseOffer offer = offerMapper.selectById(sel.getOfferId());
            if (offer != null) {
                Long cnt = selectMapper.selectCount(new LambdaQueryWrapper<UniCourseSelect>()
                        .eq(UniCourseSelect::getOfferId, sel.getOfferId())
                        .eq(UniCourseSelect::getSelectStatus, "selected"));
                offer.setSelectedCount(cnt == null ? 0 : cnt.intValue());
                offerMapper.updateById(offer);
            }
        }
        return sel;
    }

    public PageResult<UniScore> pageScore(long current, long size, Long orgId, Long studentId, Long termId) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<UniScore> qw = new LambdaQueryWrapper<UniScore>()
                .eq(UniScore::getOrgId, oid)
                .eq(studentId != null, UniScore::getStudentId, studentId)
                .eq(termId != null, UniScore::getTermId, termId)
                .orderByDesc(UniScore::getCreatedAt);
        return PageResult.of(scoreMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public UniScore saveScore(UniScore score) {
        score.setOrgId(resolveOrgId(score.getOrgId()));
        score.setEntryBy(UserContext.userId());
        return upsert(score, scoreMapper, score.getId());
    }

    @Transactional
    public UniMakeupRetake saveMakeup(UniMakeupRetake makeup) {
        makeup.setOrgId(resolveOrgId(makeup.getOrgId()));
        makeup.setOperatorId(UserContext.userId());
        if (makeup.getApplyStatus() == null || makeup.getApplyStatus().isBlank()) {
            makeup.setApplyStatus("pending");
        }
        return upsert(makeup, makeupMapper, makeup.getId());
    }

    public List<UniAcademicWarning> listWarnings(Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        return warningMapper.selectList(new LambdaQueryWrapper<UniAcademicWarning>()
                .eq(UniAcademicWarning::getOrgId, oid)
                .eq(studentId != null, UniAcademicWarning::getStudentId, studentId));
    }

    @Transactional
    public UniAcademicWarning saveWarning(UniAcademicWarning warning) {
        warning.setOrgId(resolveOrgId(warning.getOrgId()));
        return upsert(warning, warningMapper, warning.getId());
    }

    // ================= 综测 / 奖助 / 科创 / 社团 =================
    public List<UniComprehensiveEval> listEvals(Long orgId, Long studentId, Long schoolYearId) {
        Long oid = resolveOrgId(orgId);
        return evalMapper.selectList(new LambdaQueryWrapper<UniComprehensiveEval>()
                .eq(UniComprehensiveEval::getOrgId, oid)
                .eq(studentId != null, UniComprehensiveEval::getStudentId, studentId)
                .eq(schoolYearId != null, UniComprehensiveEval::getSchoolYearId, schoolYearId));
    }

    @Transactional
    public UniComprehensiveEval saveEval(UniComprehensiveEval eval) {
        eval.setOrgId(resolveOrgId(eval.getOrgId()));
        return upsert(eval, evalMapper, eval.getId());
    }

    @Transactional
    public UniEvalItem saveEvalItem(UniEvalItem item) {
        item.setOrgId(resolveOrgId(item.getOrgId()));
        return upsert(item, evalItemMapper, item.getId());
    }

    public List<UniScholarship> listScholarships(Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        return scholarshipMapper.selectList(new LambdaQueryWrapper<UniScholarship>()
                .eq(UniScholarship::getOrgId, oid)
                .eq(studentId != null, UniScholarship::getStudentId, studentId));
    }

    @Transactional
    public UniScholarship saveScholarship(UniScholarship scholarship) {
        scholarship.setOrgId(resolveOrgId(scholarship.getOrgId()));
        scholarship.setOperatorId(UserContext.userId());
        return upsert(scholarship, scholarshipMapper, scholarship.getId());
    }

    public List<UniInnovation> listInnovations(Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        return innovationMapper.selectList(new LambdaQueryWrapper<UniInnovation>()
                .eq(UniInnovation::getOrgId, oid)
                .eq(studentId != null, UniInnovation::getStudentId, studentId));
    }

    @Transactional
    public UniInnovation saveInnovation(UniInnovation innovation) {
        innovation.setOrgId(resolveOrgId(innovation.getOrgId()));
        return upsert(innovation, innovationMapper, innovation.getId());
    }

    public List<UniClub> listClubs(Long orgId) {
        Long oid = resolveOrgId(orgId);
        return clubMapper.selectList(new LambdaQueryWrapper<UniClub>()
                .eq(UniClub::getOrgId, oid));
    }

    @Transactional
    public UniClub saveClub(UniClub club) {
        club.setOrgId(resolveOrgId(club.getOrgId()));
        return upsert(club, clubMapper, club.getId());
    }

    public List<UniClubMember> listClubMembers(Long clubId) {
        return clubMemberMapper.selectList(new LambdaQueryWrapper<UniClubMember>()
                .eq(UniClubMember::getClubId, clubId)
                .eq(UniClubMember::getStatus, 1));
    }

    @Transactional
    public UniClubMember saveClubMember(UniClubMember member) {
        if (member.getStatus() == null) {
            member.setStatus(1);
        }
        return upsert(member, clubMemberMapper, member.getId());
    }

    public List<UniActivity> listActivities(Long orgId, Long clubId) {
        Long oid = resolveOrgId(orgId);
        return activityMapper.selectList(new LambdaQueryWrapper<UniActivity>()
                .eq(UniActivity::getOrgId, oid)
                .eq(clubId != null, UniActivity::getClubId, clubId)
                .orderByDesc(UniActivity::getActivityDate));
    }

    @Transactional
    public UniActivity saveActivity(UniActivity activity) {
        activity.setOrgId(resolveOrgId(activity.getOrgId()));
        activity.setRecorderId(UserContext.userId());
        return upsert(activity, activityMapper, activity.getId());
    }

    // ================= 论文 / 答辩 / 学位 / 就业 =================
    public List<UniThesis> listTheses(Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        return thesisMapper.selectList(new LambdaQueryWrapper<UniThesis>()
                .eq(UniThesis::getOrgId, oid)
                .eq(studentId != null, UniThesis::getStudentId, studentId));
    }

    @Transactional
    public UniThesis saveThesis(UniThesis thesis) {
        thesis.setOrgId(resolveOrgId(thesis.getOrgId()));
        return upsert(thesis, thesisMapper, thesis.getId());
    }

    @Transactional
    public UniThesisDefense saveDefense(UniThesisDefense defense) {
        defense.setOrgId(resolveOrgId(defense.getOrgId()));
        defense.setOperatorId(UserContext.userId());
        return upsert(defense, defenseMapper, defense.getId());
    }

    public List<UniDegreePrecheck> listPrechecks(Long orgId, Integer checkYear) {
        Long oid = resolveOrgId(orgId);
        return precheckMapper.selectList(new LambdaQueryWrapper<UniDegreePrecheck>()
                .eq(UniDegreePrecheck::getOrgId, oid)
                .eq(checkYear != null, UniDegreePrecheck::getCheckYear, checkYear));
    }

    @Transactional
    public UniDegreePrecheck savePrecheck(UniDegreePrecheck precheck) {
        precheck.setOrgId(resolveOrgId(precheck.getOrgId()));
        precheck.setOperatorId(UserContext.userId());
        return upsert(precheck, precheckMapper, precheck.getId());
    }

    public List<UniEmployment> listEmployments(Long orgId, Integer graduateYear) {
        Long oid = resolveOrgId(orgId);
        return employmentMapper.selectList(new LambdaQueryWrapper<UniEmployment>()
                .eq(UniEmployment::getOrgId, oid)
                .eq(graduateYear != null, UniEmployment::getGraduateYear, graduateYear));
    }

    @Transactional
    public UniEmployment saveEmployment(UniEmployment employment) {
        employment.setOrgId(resolveOrgId(employment.getOrgId()));
        employment.setOperatorId(UserContext.userId());
        return upsert(employment, employmentMapper, employment.getId());
    }

    // ================= 宿舍后勤 =================
    public List<UniDormBuilding> listBuildings(Long orgId) {
        Long oid = resolveOrgId(orgId);
        return buildingMapper.selectList(new LambdaQueryWrapper<UniDormBuilding>()
                .eq(UniDormBuilding::getOrgId, oid));
    }

    public List<UniDormRoom> listRooms(Long buildingId) {
        return roomMapper.selectList(new LambdaQueryWrapper<UniDormRoom>()
                .eq(UniDormRoom::getBuildingId, buildingId)
                .orderByAsc(UniDormRoom::getFloorNo).orderByAsc(UniDormRoom::getRoomNo));
    }

    public List<UniDormBed> listBeds(Long roomId) {
        return bedMapper.selectList(new LambdaQueryWrapper<UniDormBed>()
                .eq(UniDormBed::getRoomId, roomId));
    }

    @Transactional
    public UniDormBuilding saveBuilding(UniDormBuilding building) {
        building.setOrgId(resolveOrgId(building.getOrgId()));
        return upsert(building, buildingMapper, building.getId());
    }

    @Transactional
    public UniDormRoom saveRoom(UniDormRoom room) {
        room.setOrgId(resolveOrgId(room.getOrgId()));
        return upsert(room, roomMapper, room.getId());
    }

    public List<UniDormStudent> listDormStudents(Long orgId, Long roomId) {
        Long oid = resolveOrgId(orgId);
        return dormStudentMapper.selectList(new LambdaQueryWrapper<UniDormStudent>()
                .eq(UniDormStudent::getOrgId, oid)
                .eq(roomId != null, UniDormStudent::getRoomId, roomId)
                .eq(UniDormStudent::getStatus, 1));
    }

    /** 分配床位（入住） */
    @Transactional
    public UniDormStudent assignDorm(UniDormStudent ds) {
        Long oid = resolveOrgId(ds.getOrgId());
        ds.setOrgId(oid);
        ds.setOperatorId(UserContext.userId());
        if (ds.getAssignType() == null || ds.getAssignType().isBlank()) {
            ds.setAssignType("manual");
        }
        if (ds.getStatus() == null) {
            ds.setStatus(1);
        }
        if (ds.getId() == null) {
            dormStudentMapper.insert(ds);
        } else {
            dormStudentMapper.updateById(ds);
        }
        // 同步房间已住人数
        if (ds.getRoomId() != null) {
            UniDormRoom room = roomMapper.selectById(ds.getRoomId());
            if (room != null) {
                Long cnt = dormStudentMapper.selectCount(new LambdaQueryWrapper<UniDormStudent>()
                        .eq(UniDormStudent::getRoomId, room.getId())
                        .eq(UniDormStudent::getStatus, 1));
                room.setOccupiedCount(cnt == null ? 0 : cnt.intValue());
                roomMapper.updateById(room);
            }
        }
        return ds;
    }

    public List<UniDormCheck> listDormChecks(Long orgId, String checkDate) {
        Long oid = resolveOrgId(orgId);
        return dormCheckMapper.selectList(new LambdaQueryWrapper<UniDormCheck>()
                .eq(UniDormCheck::getOrgId, oid)
                .eq(checkDate != null && !checkDate.isBlank(), UniDormCheck::getCheckDate, checkDate));
    }

    @Transactional
    public UniDormCheck saveDormCheck(UniDormCheck check) {
        check.setOrgId(resolveOrgId(check.getOrgId()));
        check.setCheckerId(UserContext.userId());
        if (check.getIsAlert() == null) {
            check.setIsAlert(0);
        }
        return upsert(check, dormCheckMapper, check.getId());
    }

    public List<UniRepair> listRepairs(Long orgId, String status) {
        Long oid = resolveOrgId(orgId);
        return repairMapper.selectList(new LambdaQueryWrapper<UniRepair>()
                .eq(UniRepair::getOrgId, oid)
                .eq(status != null && !status.isBlank(), UniRepair::getStatus, status)
                .orderByDesc(UniRepair::getCreatedAt));
    }

    @Transactional
    public UniRepair saveRepair(UniRepair repair) {
        repair.setOrgId(resolveOrgId(repair.getOrgId()));
        return upsert(repair, repairMapper, repair.getId());
    }

    public List<UniDormHygiene> listHygiene(Long orgId, String checkDate) {
        Long oid = resolveOrgId(orgId);
        return hygieneMapper.selectList(new LambdaQueryWrapper<UniDormHygiene>()
                .eq(UniDormHygiene::getOrgId, oid)
                .eq(checkDate != null && !checkDate.isBlank(), UniDormHygiene::getCheckDate, checkDate));
    }

    @Transactional
    public UniDormHygiene saveHygiene(UniDormHygiene hygiene) {
        hygiene.setOrgId(resolveOrgId(hygiene.getOrgId()));
        hygiene.setCheckerId(UserContext.userId());
        return upsert(hygiene, hygieneMapper, hygiene.getId());
    }

    public List<UniHealthRecord> listHealthRecords(Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        return healthMapper.selectList(new LambdaQueryWrapper<UniHealthRecord>()
                .eq(UniHealthRecord::getOrgId, oid)
                .eq(studentId != null, UniHealthRecord::getStudentId, studentId));
    }

    @Transactional
    public UniHealthRecord saveHealthRecord(UniHealthRecord record) {
        record.setOrgId(resolveOrgId(record.getOrgId()));
        record.setRecorderId(UserContext.userId());
        return upsert(record, healthMapper, record.getId());
    }
}
