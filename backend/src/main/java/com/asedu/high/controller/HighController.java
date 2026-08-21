package com.asedu.high.controller;

import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import com.asedu.high.entity.HighGaokaoPrep;
import com.asedu.high.entity.HighGraduationOutcome;
import com.asedu.high.entity.HighScoreConversion;
import com.asedu.high.entity.HighSelectionChoice;
import com.asedu.high.entity.HighSelectionRule;
import com.asedu.high.entity.HighTierClass;
import com.asedu.high.entity.HighWalkClassMember;
import com.asedu.high.service.HighService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 普高专属（新高考选科走班/分层/赋分/高考备考/升学） */
@RestController
@RequestMapping("/api/high")
@RequiredArgsConstructor
public class HighController {

    private final HighService highService;

    @GetMapping("/rule/list")
    public R<List<HighSelectionRule>> listRules(@RequestParam(required = false) Long orgId,
                                                @RequestParam(required = false) Long gradeId) {
        return R.ok(highService.listRules(orgId, gradeId));
    }

    @PostMapping("/rule/save")
    public R<HighSelectionRule> saveRule(@RequestBody HighSelectionRule rule) {
        return R.ok(highService.saveRule(rule));
    }

    @GetMapping("/choice/page")
    public R<PageResult<HighSelectionChoice>> pageChoice(@RequestParam(defaultValue = "1") long current,
                                                         @RequestParam(defaultValue = "10") long size,
                                                         @RequestParam(required = false) Long orgId,
                                                         @RequestParam(required = false) Long studentId,
                                                         @RequestParam(required = false) String status) {
        return R.ok(highService.pageChoice(current, size, orgId, studentId, status));
    }

    @PostMapping("/choice/save")
    public R<HighSelectionChoice> saveChoice(@RequestBody HighSelectionChoice choice) {
        return R.ok(highService.saveChoice(choice));
    }

    @PostMapping("/choice/audit")
    public R<HighSelectionChoice> auditChoice(@RequestParam Long id, @RequestParam String status,
                                              @RequestParam(required = false) String remark) {
        return R.ok(highService.auditChoice(id, status, remark));
    }

    @GetMapping("/tier-class/list")
    public R<List<HighTierClass>> listTierClasses(@RequestParam(required = false) Long orgId,
                                                  @RequestParam(required = false) Long termId) {
        return R.ok(highService.listTierClasses(orgId, termId));
    }

    @PostMapping("/tier-class/save")
    public R<HighTierClass> saveTierClass(@RequestBody HighTierClass tier) {
        return R.ok(highService.saveTierClass(tier));
    }

    @GetMapping("/walk-member/list")
    public R<List<HighWalkClassMember>> listWalkMembers(@RequestParam(required = false) Long orgId,
                                                        @RequestParam(required = false) Long walkClassId) {
        return R.ok(highService.listWalkMembers(orgId, walkClassId));
    }

    @PostMapping("/walk-member/save")
    public R<HighWalkClassMember> saveWalkMember(@RequestBody HighWalkClassMember member) {
        return R.ok(highService.saveWalkMember(member));
    }

    @GetMapping("/conversion/list")
    public R<List<HighScoreConversion>> listConversions(@RequestParam(required = false) Long orgId,
                                                        @RequestParam(required = false) String subjectCode) {
        return R.ok(highService.listConversions(orgId, subjectCode));
    }

    @PostMapping("/conversion/save")
    public R<HighScoreConversion> saveConversion(@RequestBody HighScoreConversion conv) {
        return R.ok(highService.saveConversion(conv));
    }

    @GetMapping("/prep/list")
    public R<List<HighGaokaoPrep>> listPrep(@RequestParam(required = false) Long orgId,
                                            @RequestParam(required = false) Long studentId) {
        return R.ok(highService.listPrep(orgId, studentId));
    }

    @PostMapping("/prep/save")
    public R<HighGaokaoPrep> savePrep(@RequestBody HighGaokaoPrep prep) {
        return R.ok(highService.savePrep(prep));
    }

    @GetMapping("/outcome/list")
    public R<List<HighGraduationOutcome>> listOutcomes(@RequestParam(required = false) Long orgId,
                                                       @RequestParam(required = false) Integer graduateYear) {
        return R.ok(highService.listOutcomes(orgId, graduateYear));
    }

    @PostMapping("/outcome/save")
    public R<HighGraduationOutcome> saveOutcome(@RequestBody HighGraduationOutcome outcome) {
        return R.ok(highService.saveOutcome(outcome));
    }
}
