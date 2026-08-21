package com.asedu.exam.controller;

import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import com.asedu.exam.entity.ExamPlan;
import com.asedu.exam.entity.ExamScore;
import com.asedu.exam.entity.ExamSubject;
import com.asedu.exam.service.ExamService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 考试与成绩（单元测/月考/期中期末/模考/联考） */
@RestController
@RequestMapping("/api/exam")
@RequiredArgsConstructor
public class ExamController {

    private final ExamService examService;

    @GetMapping("/plan/page")
    public R<PageResult<ExamPlan>> pageExam(@RequestParam(defaultValue = "1") long current,
                                            @RequestParam(defaultValue = "10") long size,
                                            @RequestParam(required = false) Long orgId,
                                            @RequestParam(required = false) String examType,
                                            @RequestParam(required = false) String keyword) {
        return R.ok(examService.pageExam(current, size, orgId, examType, keyword));
    }

    @PostMapping("/plan/save")
    public R<ExamPlan> saveExam(@RequestBody ExamPlan plan) {
        return R.ok(examService.saveExam(plan));
    }

    @GetMapping("/subject/list")
    public R<List<ExamSubject>> listSubjects(@RequestParam Long examId) {
        return R.ok(examService.listSubjects(examId));
    }

    @PostMapping("/subject/save")
    public R<ExamSubject> saveSubject(@RequestBody ExamSubject subject) {
        return R.ok(examService.saveSubject(subject));
    }

    @GetMapping("/score/page")
    public R<PageResult<ExamScore>> pageScore(@RequestParam(defaultValue = "1") long current,
                                              @RequestParam(defaultValue = "10") long size,
                                              @RequestParam(required = false) Long orgId,
                                              @RequestParam(required = false) Long examId,
                                              @RequestParam(required = false) Long subjectId) {
        return R.ok(examService.pageScore(current, size, orgId, examId, subjectId));
    }

    @PostMapping("/score/save")
    public R<ExamScore> saveScore(@RequestBody ExamScore score) {
        return R.ok(examService.saveScore(score));
    }
}
