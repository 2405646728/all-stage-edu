package com.asedu.controller;

import com.asedu.common.api.R;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class SystemHealthController {

    @GetMapping("/health")
    public R<Map<String, Object>> health() {
        return R.ok(Map.of("status", "UP", "time", LocalDateTime.now().toString()));
    }
}