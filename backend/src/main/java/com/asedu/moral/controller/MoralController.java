package com.asedu.moral.controller;

import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import com.asedu.moral.entity.MoralActivity;
import com.asedu.moral.entity.MoralClassEval;
import com.asedu.moral.entity.MoralComprehensiveEval;
import com.asedu.moral.entity.MoralRecord;
import com.asedu.moral.entity.MoralScoreRule;
import com.asedu.moral.entity.MoralTalk;
import com.asedu.moral.service.MoralService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 德育与综评（奖惩积分/班级考核/活动/谈心/五维综评） */
@RestController
@RequestMapping("/api/moral")
@RequiredArgsConstructor
public class MoralController {

    private final MoralService moralService;

    @GetMapping("/rule/list")
    public R<List<MoralScoreRule>> listRules(@RequestParam(required = false) Long orgId) {
        return R.ok(moralService.listRules(orgId));
    }

    @PostMapping("/rule/save")
    public R<MoralScoreRule> saveRule(@RequestBody MoralScoreRule rule) {
        return R.ok(moralService.saveRule(rule));
    }

    @GetMapping("/record/page")
    public R<PageResult<MoralRecord>> pageRecord(@RequestParam(defaultValue = "1") long current,
                                                 @RequestParam(defaultValue = "10") long size,
                                                 @RequestParam(required = false) Long orgId,
                                                 @RequestParam(required = false) Long studentId) {
        return R.ok(moralService.pageRecord(current, size, orgId, studentId));
    }

    @PostMapping("/record/save")
    public R<MoralRecord> saveRecord(@RequestBody MoralRecord record) {
        return R.ok(moralService.saveRecord(record));
    }

    @GetMapping("/class-eval/list")
    public R<List<MoralClassEval>> listClassEval(@RequestParam(required = false) Long orgId,
                                                 @RequestParam(required = false) Long classId,
                                                 @RequestParam(required = false) String evalPeriod) {
        return R.ok(moralService.listClassEval(orgId, classId, evalPeriod));
    }

    @PostMapping("/class-eval/save")
    public R<MoralClassEval> saveClassEval(@RequestBody MoralClassEval eval) {
        return R.ok(moralService.saveClassEval(eval));
    }

    @GetMapping("/activity/list")
    public R<List<MoralActivity>> listActivity(@RequestParam(required = false) Long orgId,
                                               @RequestParam(required = false) Long classId) {
        return R.ok(moralService.listActivity(orgId, classId));
    }

    @PostMapping("/activity/save")
    public R<MoralActivity> saveActivity(@RequestBody MoralActivity activity) {
        return R.ok(moralService.saveActivity(activity));
    }

    @GetMapping("/talk/list")
    public R<List<MoralTalk>> listTalk(@RequestParam(required = false) Long orgId,
                                       @RequestParam(required = false) Long studentId) {
        return R.ok(moralService.listTalk(orgId, studentId));
    }

    @PostMapping("/talk/save")
    public R<MoralTalk> saveTalk(@RequestBody MoralTalk talk) {
        return R.ok(moralService.saveTalk(talk));
    }

    @GetMapping("/eval/list")
    public R<List<MoralComprehensiveEval>> listEval(@RequestParam(required = false) Long orgId,
                                                    @RequestParam(required = false) Long studentId,
                                                    @RequestParam(required = false) Long termId) {
        return R.ok(moralService.listEval(orgId, studentId, termId));
    }

    @PostMapping("/eval/save")
    public R<MoralComprehensiveEval> saveEval(@RequestBody MoralComprehensiveEval eval) {
        return R.ok(moralService.saveEval(eval));
    }
}
