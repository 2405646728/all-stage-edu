package com.asedu.base.controller;

import com.asedu.base.dto.ClassAssignDTO;
import com.asedu.base.dto.EnrollmentChangeDTO;
import com.asedu.base.dto.StudentSaveDTO;
import com.asedu.base.entity.BaseClassStudent;
import com.asedu.base.entity.BaseStudent;
import com.asedu.base.entity.BaseStudentStatusChange;
import com.asedu.base.service.StudentService;
import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** 学生主档/学籍/异动/分班（全学段统一数据底座） */
@RestController
@RequestMapping("/api/base/student")
@RequiredArgsConstructor
public class StudentController {

    private final StudentService studentService;

    @GetMapping("/page")
    public R<PageResult<BaseStudent>> page(@RequestParam(defaultValue = "1") long current,
                                           @RequestParam(defaultValue = "10") long size,
                                           @RequestParam(required = false) Long orgId,
                                           @RequestParam(required = false) String keyword,
                                           @RequestParam(required = false) Long gradeId,
                                           @RequestParam(required = false) Long classId,
                                           @RequestParam(required = false) String studyStatus) {
        return R.ok(studentService.page(current, size, orgId, keyword, gradeId, classId, studyStatus));
    }

    @GetMapping("/{id}")
    public R<BaseStudent> detail(@PathVariable Long id) {
        return R.ok(studentService.detail(id));
    }

    @PostMapping("/create")
    public R<BaseStudent> create(@Valid @RequestBody StudentSaveDTO dto) {
        return R.ok(studentService.create(dto));
    }

    @PutMapping("/{id}")
    public R<BaseStudent> update(@PathVariable Long id, @Valid @RequestBody StudentSaveDTO dto) {
        return R.ok(studentService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public R<Void> remove(@PathVariable Long id) {
        studentService.remove(id);
        return R.ok();
    }

    /** 学籍异动登记（休学/转出/毕业等全流程，台账留痕） */
    @PostMapping("/enroll-change")
    public R<BaseStudentStatusChange> enrollmentChange(@Valid @RequestBody EnrollmentChangeDTO dto) {
        return R.ok(studentService.enrollmentChange(dto));
    }

    /** 学籍异动台账分页 */
    @GetMapping("/status-change/page")
    public R<PageResult<BaseStudentStatusChange>> pageStatusChange(@RequestParam(defaultValue = "1") long current,
                                                                   @RequestParam(defaultValue = "10") long size,
                                                                   @RequestParam(required = false) Long orgId,
                                                                   @RequestParam(required = false) Long studentId) {
        return R.ok(studentService.pageStatusChange(current, size, orgId, studentId));
    }

    /** 分班记录分页（历史可追溯） */
    @GetMapping("/class-student/page")
    public R<PageResult<BaseClassStudent>> pageClassStudent(@RequestParam(defaultValue = "1") long current,
                                                            @RequestParam(defaultValue = "10") long size,
                                                            @RequestParam(required = false) Long orgId,
                                                            @RequestParam(required = false) Long studentId,
                                                            @RequestParam(required = false) Long classId) {
        return R.ok(studentService.pageClassStudent(current, size, orgId, studentId, classId));
    }

    /** 分班/调班（智能分班/手动微调/插班/升班） */
    @PostMapping("/assign-class")
    public R<Void> assignClass(@Valid @RequestBody ClassAssignDTO dto) {
        studentService.assignClass(dto, null);
        return R.ok();
    }
}