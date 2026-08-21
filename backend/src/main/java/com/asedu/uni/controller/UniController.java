package com.asedu.uni.controller;

import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import com.asedu.uni.entity.*;
import com.asedu.uni.service.UniService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 高校专属（院系培养/选课绩点/综测评奖/科创社团/论文答辩/学位就业/宿舍后勤/健康体测） */
@RestController
@RequestMapping("/api/uni")
@RequiredArgsConstructor
public class UniController {

    private final UniService uniService;

    // 院系专业
    @GetMapping("/department/list")
    public R<List<UniDepartment>> listDepartments(@RequestParam(required = false) Long orgId) {
        return R.ok(uniService.listDepartments(orgId));
    }

    @PostMapping("/department/save")
    public R<UniDepartment> saveDepartment(@RequestBody UniDepartment dept) {
        return R.ok(uniService.saveDepartment(dept));
    }

    @GetMapping("/major/list")
    public R<List<UniMajor>> listMajors(@RequestParam(required = false) Long orgId,
                                        @RequestParam(required = false) Long deptId) {
        return R.ok(uniService.listMajors(orgId, deptId));
    }

    @PostMapping("/major/save")
    public R<UniMajor> saveMajor(@RequestBody UniMajor major) {
        return R.ok(uniService.saveMajor(major));
    }

    // 培养方案
    @GetMapping("/program/list")
    public R<List<UniTrainingProgram>> listPrograms(@RequestParam(required = false) Long orgId,
                                                    @RequestParam(required = false) Long majorId) {
        return R.ok(uniService.listPrograms(orgId, majorId));
    }

    @PostMapping("/program/save")
    public R<UniTrainingProgram> saveProgram(@RequestBody UniTrainingProgram program) {
        return R.ok(uniService.saveProgram(program));
    }

    @GetMapping("/program-course/list")
    public R<List<UniProgramCourse>> listProgramCourses(@RequestParam Long programId) {
        return R.ok(uniService.listProgramCourses(programId));
    }

    @PostMapping("/program-course/save")
    public R<UniProgramCourse> saveProgramCourse(@RequestBody UniProgramCourse pc) {
        return R.ok(uniService.saveProgramCourse(pc));
    }

    // 开课选课
    @GetMapping("/offer/list")
    public R<List<UniCourseOffer>> listOffers(@RequestParam(required = false) Long orgId,
                                              @RequestParam(required = false) Long termId) {
        return R.ok(uniService.listOffers(orgId, termId));
    }

    @PostMapping("/offer/save")
    public R<UniCourseOffer> saveOffer(@RequestBody UniCourseOffer offer) {
        return R.ok(uniService.saveOffer(offer));
    }

    @GetMapping("/select/list")
    public R<List<UniCourseSelect>> listSelects(@RequestParam(required = false) Long orgId,
                                                @RequestParam(required = false) Long offerId,
                                                @RequestParam(required = false) Long studentId) {
        return R.ok(uniService.listSelects(orgId, offerId, studentId));
    }

    @PostMapping("/select/save")
    public R<UniCourseSelect> saveSelect(@RequestBody UniCourseSelect sel) {
        return R.ok(uniService.saveSelect(sel));
    }

    // 成绩绩点
    @GetMapping("/score/page")
    public R<PageResult<UniScore>> pageScore(@RequestParam(defaultValue = "1") long current,
                                             @RequestParam(defaultValue = "10") long size,
                                             @RequestParam(required = false) Long orgId,
                                             @RequestParam(required = false) Long studentId,
                                             @RequestParam(required = false) Long termId) {
        return R.ok(uniService.pageScore(current, size, orgId, studentId, termId));
    }

    @PostMapping("/score/save")
    public R<UniScore> saveScore(@RequestBody UniScore score) {
        return R.ok(uniService.saveScore(score));
    }

    @PostMapping("/makeup/save")
    public R<UniMakeupRetake> saveMakeup(@RequestBody UniMakeupRetake makeup) {
        return R.ok(uniService.saveMakeup(makeup));
    }

    @GetMapping("/warning/list")
    public R<List<UniAcademicWarning>> listWarnings(@RequestParam(required = false) Long orgId,
                                                    @RequestParam(required = false) Long studentId) {
        return R.ok(uniService.listWarnings(orgId, studentId));
    }

    @PostMapping("/warning/save")
    public R<UniAcademicWarning> saveWarning(@RequestBody UniAcademicWarning warning) {
        return R.ok(uniService.saveWarning(warning));
    }

    // 综测评奖
    @GetMapping("/eval/list")
    public R<List<UniComprehensiveEval>> listEvals(@RequestParam(required = false) Long orgId,
                                                   @RequestParam(required = false) Long studentId,
                                                   @RequestParam(required = false) Long schoolYearId) {
        return R.ok(uniService.listEvals(orgId, studentId, schoolYearId));
    }

    @PostMapping("/eval/save")
    public R<UniComprehensiveEval> saveEval(@RequestBody UniComprehensiveEval eval) {
        return R.ok(uniService.saveEval(eval));
    }

    @PostMapping("/eval-item/save")
    public R<UniEvalItem> saveEvalItem(@RequestBody UniEvalItem item) {
        return R.ok(uniService.saveEvalItem(item));
    }

    @GetMapping("/scholarship/list")
    public R<List<UniScholarship>> listScholarships(@RequestParam(required = false) Long orgId,
                                                    @RequestParam(required = false) Long studentId) {
        return R.ok(uniService.listScholarships(orgId, studentId));
    }

    @PostMapping("/scholarship/save")
    public R<UniScholarship> saveScholarship(@RequestBody UniScholarship scholarship) {
        return R.ok(uniService.saveScholarship(scholarship));
    }

    // 科创社团
    @GetMapping("/innovation/list")
    public R<List<UniInnovation>> listInnovations(@RequestParam(required = false) Long orgId,
                                                  @RequestParam(required = false) Long studentId) {
        return R.ok(uniService.listInnovations(orgId, studentId));
    }

    @PostMapping("/innovation/save")
    public R<UniInnovation> saveInnovation(@RequestBody UniInnovation innovation) {
        return R.ok(uniService.saveInnovation(innovation));
    }

    @GetMapping("/club/list")
    public R<List<UniClub>> listClubs(@RequestParam(required = false) Long orgId) {
        return R.ok(uniService.listClubs(orgId));
    }

    @PostMapping("/club/save")
    public R<UniClub> saveClub(@RequestBody UniClub club) {
        return R.ok(uniService.saveClub(club));
    }

    @GetMapping("/club-member/list")
    public R<List<UniClubMember>> listClubMembers(@RequestParam Long clubId) {
        return R.ok(uniService.listClubMembers(clubId));
    }

    @PostMapping("/club-member/save")
    public R<UniClubMember> saveClubMember(@RequestBody UniClubMember member) {
        return R.ok(uniService.saveClubMember(member));
    }

    @GetMapping("/activity/list")
    public R<List<UniActivity>> listActivities(@RequestParam(required = false) Long orgId,
                                               @RequestParam(required = false) Long clubId) {
        return R.ok(uniService.listActivities(orgId, clubId));
    }

    @PostMapping("/activity/save")
    public R<UniActivity> saveActivity(@RequestBody UniActivity activity) {
        return R.ok(uniService.saveActivity(activity));
    }

    // 论文答辩学位
    @GetMapping("/thesis/list")
    public R<List<UniThesis>> listTheses(@RequestParam(required = false) Long orgId,
                                         @RequestParam(required = false) Long studentId) {
        return R.ok(uniService.listTheses(orgId, studentId));
    }

    @PostMapping("/thesis/save")
    public R<UniThesis> saveThesis(@RequestBody UniThesis thesis) {
        return R.ok(uniService.saveThesis(thesis));
    }

    @PostMapping("/thesis/defense/save")
    public R<UniThesisDefense> saveDefense(@RequestBody UniThesisDefense defense) {
        return R.ok(uniService.saveDefense(defense));
    }

    @GetMapping("/precheck/list")
    public R<List<UniDegreePrecheck>> listPrechecks(@RequestParam(required = false) Long orgId,
                                                    @RequestParam(required = false) Integer checkYear) {
        return R.ok(uniService.listPrechecks(orgId, checkYear));
    }

    @PostMapping("/precheck/save")
    public R<UniDegreePrecheck> savePrecheck(@RequestBody UniDegreePrecheck precheck) {
        return R.ok(uniService.savePrecheck(precheck));
    }

    @GetMapping("/employment/list")
    public R<List<UniEmployment>> listEmployments(@RequestParam(required = false) Long orgId,
                                                  @RequestParam(required = false) Integer graduateYear) {
        return R.ok(uniService.listEmployments(orgId, graduateYear));
    }

    @PostMapping("/employment/save")
    public R<UniEmployment> saveEmployment(@RequestBody UniEmployment employment) {
        return R.ok(uniService.saveEmployment(employment));
    }

    // 宿舍后勤
    @GetMapping("/dorm/building/list")
    public R<List<UniDormBuilding>> listBuildings(@RequestParam(required = false) Long orgId) {
        return R.ok(uniService.listBuildings(orgId));
    }

    @PostMapping("/dorm/building/save")
    public R<UniDormBuilding> saveBuilding(@RequestBody UniDormBuilding building) {
        return R.ok(uniService.saveBuilding(building));
    }

    @GetMapping("/dorm/room/list")
    public R<List<UniDormRoom>> listRooms(@RequestParam Long buildingId) {
        return R.ok(uniService.listRooms(buildingId));
    }

    @PostMapping("/dorm/room/save")
    public R<UniDormRoom> saveRoom(@RequestBody UniDormRoom room) {
        return R.ok(uniService.saveRoom(room));
    }

    @GetMapping("/dorm/bed/list")
    public R<List<UniDormBed>> listBeds(@RequestParam Long roomId) {
        return R.ok(uniService.listBeds(roomId));
    }

    @GetMapping("/dorm/student/list")
    public R<List<UniDormStudent>> listDormStudents(@RequestParam(required = false) Long orgId,
                                                    @RequestParam(required = false) Long roomId) {
        return R.ok(uniService.listDormStudents(orgId, roomId));
    }

    @PostMapping("/dorm/student/assign")
    public R<UniDormStudent> assignDorm(@RequestBody UniDormStudent ds) {
        return R.ok(uniService.assignDorm(ds));
    }

    @GetMapping("/dorm/check/list")
    public R<List<UniDormCheck>> listDormChecks(@RequestParam(required = false) Long orgId,
                                                @RequestParam(required = false) String checkDate) {
        return R.ok(uniService.listDormChecks(orgId, checkDate));
    }

    @PostMapping("/dorm/check/save")
    public R<UniDormCheck> saveDormCheck(@RequestBody UniDormCheck check) {
        return R.ok(uniService.saveDormCheck(check));
    }

    @GetMapping("/repair/list")
    public R<List<UniRepair>> listRepairs(@RequestParam(required = false) Long orgId,
                                          @RequestParam(required = false) String status) {
        return R.ok(uniService.listRepairs(orgId, status));
    }

    @PostMapping("/repair/save")
    public R<UniRepair> saveRepair(@RequestBody UniRepair repair) {
        return R.ok(uniService.saveRepair(repair));
    }

    @GetMapping("/dorm/hygiene/list")
    public R<List<UniDormHygiene>> listHygiene(@RequestParam(required = false) Long orgId,
                                               @RequestParam(required = false) String checkDate) {
        return R.ok(uniService.listHygiene(orgId, checkDate));
    }

    @PostMapping("/dorm/hygiene/save")
    public R<UniDormHygiene> saveHygiene(@RequestBody UniDormHygiene hygiene) {
        return R.ok(uniService.saveHygiene(hygiene));
    }

    @GetMapping("/health/list")
    public R<List<UniHealthRecord>> listHealthRecords(@RequestParam(required = false) Long orgId,
                                                      @RequestParam(required = false) Long studentId) {
        return R.ok(uniService.listHealthRecords(orgId, studentId));
    }

    @PostMapping("/health/save")
    public R<UniHealthRecord> saveHealthRecord(@RequestBody UniHealthRecord record) {
        return R.ok(uniService.saveHealthRecord(record));
    }
}
