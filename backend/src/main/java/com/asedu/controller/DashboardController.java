package com.asedu.controller;

import com.asedu.common.api.R;
import com.asedu.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/** 数据看板（平台/学校双维度） */
@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/platform")
    public R<Map<String, Object>> platform() {
        return R.ok(dashboardService.platform());
    }

    @GetMapping("/school")
    public R<Map<String, Object>> school() {
        return R.ok(dashboardService.school());
    }
}
