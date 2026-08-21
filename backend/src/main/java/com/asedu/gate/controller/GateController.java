package com.asedu.gate.controller;

import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import com.asedu.gate.entity.GateAlert;
import com.asedu.gate.entity.GatePassRecord;
import com.asedu.gate.entity.GatePermission;
import com.asedu.gate.entity.GateVisitor;
import com.asedu.gate.service.GateService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 门禁安防（全量通行溯源/权限/预警/访客） */
@RestController
@RequestMapping("/api/gate")
@RequiredArgsConstructor
public class GateController {

    private final GateService gateService;

    @GetMapping("/pass/page")
    public R<PageResult<GatePassRecord>> pagePass(@RequestParam(defaultValue = "1") long current,
                                                  @RequestParam(defaultValue = "10") long size,
                                                  @RequestParam(required = false) Long orgId,
                                                  @RequestParam(required = false) String keyword,
                                                  @RequestParam(required = false) String passDate,
                                                  @RequestParam(required = false) String result) {
        return R.ok(gateService.pagePass(current, size, orgId, keyword, passDate, result));
    }

    @PostMapping("/pass/record")
    public R<GatePassRecord> recordPass(@RequestBody GatePassRecord record) {
        return R.ok(gateService.recordPass(record));
    }

    @GetMapping("/permission/list")
    public R<List<GatePermission>> listPermission(@RequestParam(required = false) Long orgId,
                                                  @RequestParam(required = false) String personType) {
        return R.ok(gateService.listPermission(orgId, personType));
    }

    @PostMapping("/permission/save")
    public R<GatePermission> savePermission(@RequestBody GatePermission permission) {
        return R.ok(gateService.savePermission(permission));
    }

    @GetMapping("/alert/page")
    public R<PageResult<GateAlert>> pageAlert(@RequestParam(defaultValue = "1") long current,
                                              @RequestParam(defaultValue = "10") long size,
                                              @RequestParam(required = false) Long orgId,
                                              @RequestParam(required = false) Integer status) {
        return R.ok(gateService.pageAlert(current, size, orgId, status));
    }

    @PostMapping("/alert/handle")
    public R<GateAlert> handleAlert(@RequestParam Long id, @RequestParam(required = false) String note) {
        return R.ok(gateService.handleAlert(id, note));
    }

    @GetMapping("/visitor/page")
    public R<PageResult<GateVisitor>> pageVisitor(@RequestParam(defaultValue = "1") long current,
                                                  @RequestParam(defaultValue = "10") long size,
                                                  @RequestParam(required = false) Long orgId) {
        return R.ok(gateService.pageVisitor(current, size, orgId));
    }

    @PostMapping("/visitor/save")
    public R<GateVisitor> saveVisitor(@RequestBody GateVisitor visitor) {
        return R.ok(gateService.saveVisitor(visitor));
    }
}
