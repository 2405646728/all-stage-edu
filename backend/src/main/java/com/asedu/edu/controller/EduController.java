package com.asedu.edu.controller;

import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import com.asedu.edu.entity.EduCourse;
import com.asedu.edu.entity.EduResource;
import com.asedu.edu.entity.EduScheduleChange;
import com.asedu.edu.entity.EduSchedulePlan;
import com.asedu.edu.entity.EduTeachingRecord;
import com.asedu.edu.entity.EduTierStudent;
import com.asedu.edu.entity.EduWeakPoint;
import com.asedu.edu.service.EduService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 教务教学（课程/排课/教学纪实/资源库/薄弱点/分层，K12 共用） */
@RestController
@RequestMapping("/api/edu")
@RequiredArgsConstructor
public class EduController {

    private final EduService eduService;

    @GetMapping("/course/list")
    public R<List<EduCourse>> listCourses(@RequestParam(required = false) Long orgId,
                                          @RequestParam(required = false) Long gradeId) {
        return R.ok(eduService.listCourses(orgId, gradeId));
    }

    @PostMapping("/course/save")
    public R<EduCourse> saveCourse(@RequestBody EduCourse course) {
        return R.ok(eduService.saveCourse(course));
    }

    @GetMapping("/schedule/list")
    public R<List<EduSchedulePlan>> listSchedules(@RequestParam(required = false) Long orgId,
                                                  @RequestParam(required = false) Long termId,
                                                  @RequestParam(required = false) Long classId) {
        return R.ok(eduService.listSchedules(orgId, termId, classId));
    }

    @PostMapping("/schedule/save")
    public R<EduSchedulePlan> saveSchedule(@RequestBody EduSchedulePlan plan) {
        return R.ok(eduService.saveSchedule(plan));
    }

    @PostMapping("/schedule/change")
    public R<EduScheduleChange> saveChange(@RequestBody EduScheduleChange change) {
        return R.ok(eduService.saveChange(change));
    }

    @GetMapping("/teaching/page")
    public R<PageResult<EduTeachingRecord>> pageTeaching(@RequestParam(defaultValue = "1") long current,
                                                         @RequestParam(defaultValue = "10") long size,
                                                         @RequestParam(required = false) Long orgId,
                                                         @RequestParam(required = false) Long classId) {
        return R.ok(eduService.pageTeaching(current, size, orgId, classId));
    }

    @PostMapping("/teaching/save")
    public R<EduTeachingRecord> saveTeaching(@RequestBody EduTeachingRecord record) {
        return R.ok(eduService.saveTeaching(record));
    }

    @GetMapping("/resource/list")
    public R<List<EduResource>> listResources(@RequestParam(required = false) Long orgId,
                                              @RequestParam(required = false) String subjectCode) {
        return R.ok(eduService.listResources(orgId, subjectCode));
    }

    @PostMapping("/resource/save")
    public R<EduResource> saveResource(@RequestBody EduResource resource) {
        return R.ok(eduService.saveResource(resource));
    }

    @GetMapping("/weak-point/list")
    public R<List<EduWeakPoint>> listWeakPoints(@RequestParam(required = false) Long orgId,
                                                @RequestParam(required = false) Long studentId) {
        return R.ok(eduService.listWeakPoints(orgId, studentId));
    }

    @PostMapping("/weak-point/save")
    public R<EduWeakPoint> saveWeakPoint(@RequestBody EduWeakPoint wp) {
        return R.ok(eduService.saveWeakPoint(wp));
    }

    @GetMapping("/tier/list")
    public R<List<EduTierStudent>> listTiers(@RequestParam(required = false) Long orgId,
                                             @RequestParam(required = false) Long termId) {
        return R.ok(eduService.listTiers(orgId, termId));
    }

    @PostMapping("/tier/save")
    public R<EduTierStudent> saveTier(@RequestBody EduTierStudent tier) {
        return R.ok(eduService.saveTier(tier));
    }
}
