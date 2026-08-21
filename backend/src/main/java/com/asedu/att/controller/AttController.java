package com.asedu.att.controller;

import com.asedu.att.entity.AttLeave;
import com.asedu.att.entity.AttStudentRecord;
import com.asedu.att.service.AttService;
import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** 考勤管理（学生考勤/请假审批，全学段通用） */
@RestController
@RequestMapping("/api/att")
@RequiredArgsConstructor
public class AttController {

    private final AttService attService;

    @GetMapping("/student/page")
    public R<PageResult<AttStudentRecord>> pageStudentAtt(@RequestParam(defaultValue = "1") long current,
                                                          @RequestParam(defaultValue = "10") long size,
                                                          @RequestParam(required = false) Long orgId,
                                                          @RequestParam(required = false) String keyword,
                                                          @RequestParam(required = false) String attDate,
                                                          @RequestParam(required = false) String status) {
        return R.ok(attService.pageStudentAtt(current, size, orgId, keyword, attDate, status));
    }

    @PostMapping("/student/check-in")
    public R<AttStudentRecord> checkIn(@RequestBody AttStudentRecord record) {
        return R.ok(attService.checkIn(record));
    }

    @GetMapping("/leave/page")
    public R<PageResult<AttLeave>> pageLeave(@RequestParam(defaultValue = "1") long current,
                                             @RequestParam(defaultValue = "10") long size,
                                             @RequestParam(required = false) Long orgId,
                                             @RequestParam(required = false) String approveStatus) {
        return R.ok(attService.pageLeave(current, size, orgId, approveStatus));
    }

    @PostMapping("/leave/apply")
    public R<AttLeave> leaveApply(@RequestBody AttLeave leave) {
        return R.ok(attService.leaveApply(leave));
    }

    @PostMapping("/leave/approve")
    public R<AttLeave> leaveApprove(@RequestParam Long id,
                                    @RequestParam String approveStatus,
                                    @RequestParam(required = false) String remark) {
        return R.ok(attService.leaveApprove(id, approveStatus, remark));
    }
}
