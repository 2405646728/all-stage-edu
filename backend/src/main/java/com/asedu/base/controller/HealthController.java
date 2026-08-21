package com.asedu.base.controller;

import com.asedu.base.entity.BaseStudentHealth;
import com.asedu.base.service.HealthService;
import com.asedu.common.api.R;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** 学生健康档案（过敏/病史/禁忌，加密隔离） */
@RestController
@RequestMapping("/api/base/health")
@RequiredArgsConstructor
public class HealthController {

    private final HealthService healthService;

    @GetMapping("/get")
    public R<BaseStudentHealth> get(@RequestParam Long studentId) {
        return R.ok(healthService.getByStudentId(studentId));
    }

    @PostMapping("/save")
    public R<BaseStudentHealth> save(@RequestBody BaseStudentHealth health) {
        return R.ok(healthService.save(health));
    }
}
