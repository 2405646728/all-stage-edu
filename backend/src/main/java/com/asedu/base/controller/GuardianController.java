package com.asedu.base.controller;

import com.asedu.base.entity.BaseGuardian;
import com.asedu.base.entity.BaseStudentGuardian;
import com.asedu.base.service.GuardianService;
import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 监护人绑定（多监护人/紧急联系人/接送授权白名单） */
@RestController
@RequestMapping("/api/base/guardian")
@RequiredArgsConstructor
public class GuardianController {

    private final GuardianService guardianService;

    @GetMapping("/page")
    public R<PageResult<BaseGuardian>> page(@RequestParam(defaultValue = "1") long current,
                                            @RequestParam(defaultValue = "10") long size,
                                            @RequestParam(required = false) Long orgId,
                                            @RequestParam(required = false) String keyword) {
        return R.ok(guardianService.page(current, size, orgId, keyword));
    }

    @PostMapping("/save")
    public R<BaseGuardian> save(@RequestBody BaseGuardian guardian) {
        return R.ok(guardianService.save(guardian));
    }

    @PostMapping("/bind")
    public R<BaseStudentGuardian> bind(@RequestParam(required = false) Long orgId,
                                       @RequestParam Long studentId,
                                       @RequestParam Long guardianId,
                                       @RequestParam(required = false) Integer isPrimary,
                                       @RequestParam(required = false) Integer canPickup) {
        return R.ok(guardianService.bindStudent(orgId, studentId, guardianId, isPrimary, canPickup));
    }

    @GetMapping("/list-by-student")
    public R<List<BaseGuardian>> listByStudent(@RequestParam(required = false) Long orgId, @RequestParam Long studentId) {
        return R.ok(guardianService.listByStudent(orgId, studentId));
    }

    @DeleteMapping("/unbind")
    public R<Void> unbind(@RequestParam Long studentId, @RequestParam Long guardianId) {
        guardianService.unbindStudent(studentId, guardianId);
        return R.ok();
    }
}
