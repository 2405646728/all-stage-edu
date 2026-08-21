package com.asedu.kind.controller;

import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import com.asedu.kind.entity.KindActivityRecord;
import com.asedu.kind.entity.KindGrowthRecord;
import com.asedu.kind.entity.KindHealthAbnormal;
import com.asedu.kind.entity.KindHealthCheck;
import com.asedu.kind.entity.KindMeal;
import com.asedu.kind.entity.KindNapRecord;
import com.asedu.kind.entity.KindPickupAuthorization;
import com.asedu.kind.entity.KindPickupRecord;
import com.asedu.kind.entity.KindSafetyInspect;
import com.asedu.kind.service.KindService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 幼儿园专属模块（接送/餐食/午休活动成长/晨午检/异常健康/安全巡查） */
@RestController
@RequestMapping("/api/kind")
@RequiredArgsConstructor
public class KindController {

    private final KindService kindService;

    // ---- 接送 ----
    @GetMapping("/pickup-auth/list")
    public R<List<KindPickupAuthorization>> listPickupAuth(@RequestParam(required = false) Long orgId,
                                                           @RequestParam(required = false) Long studentId,
                                                           @RequestParam(required = false) String pickupType) {
        return R.ok(kindService.listPickupAuth(orgId, studentId, pickupType));
    }

    @PostMapping("/pickup-auth/save")
    public R<KindPickupAuthorization> savePickupAuth(@RequestBody KindPickupAuthorization auth) {
        return R.ok(kindService.savePickupAuth(auth));
    }

    @PostMapping("/pickup-auth/approve")
    public R<KindPickupAuthorization> approvePickupAuth(@RequestParam Long id, @RequestParam String approveStatus) {
        return R.ok(kindService.approvePickupAuth(id, approveStatus));
    }

    @GetMapping("/pickup-record/page")
    public R<PageResult<KindPickupRecord>> pagePickupRecord(@RequestParam(defaultValue = "1") long current,
                                                           @RequestParam(defaultValue = "10") long size,
                                                           @RequestParam(required = false) Long orgId,
                                                           @RequestParam(required = false) String keyword) {
        return R.ok(kindService.pagePickupRecord(current, size, orgId, keyword));
    }

    @PostMapping("/pickup-record/save")
    public R<KindPickupRecord> recordPickup(@RequestBody KindPickupRecord record) {
        return R.ok(kindService.recordPickup(record));
    }

    // ---- 餐食 ----
    @GetMapping("/meal/list")
    public R<List<KindMeal>> listMeal(@RequestParam(required = false) Long orgId,
                                      @RequestParam(required = false) String mealDate) {
        return R.ok(kindService.listMeal(orgId, mealDate));
    }

    @PostMapping("/meal/save")
    public R<KindMeal> saveMeal(@RequestBody KindMeal meal) {
        return R.ok(kindService.saveMeal(meal));
    }

    // ---- 午休/活动/成长 ----
    @PostMapping("/nap/save")
    public R<KindNapRecord> saveNap(@RequestBody KindNapRecord nap) {
        return R.ok(kindService.saveNap(nap));
    }

    @GetMapping("/activity/list")
    public R<List<KindActivityRecord>> listActivity(@RequestParam(required = false) Long orgId,
                                                    @RequestParam(required = false) Long classId) {
        return R.ok(kindService.listActivity(orgId, classId));
    }

    @PostMapping("/activity/save")
    public R<KindActivityRecord> saveActivity(@RequestBody KindActivityRecord record) {
        return R.ok(kindService.saveActivity(record));
    }

    @GetMapping("/growth/page")
    public R<PageResult<KindGrowthRecord>> pageGrowth(@RequestParam(defaultValue = "1") long current,
                                                      @RequestParam(defaultValue = "10") long size,
                                                      @RequestParam(required = false) Long orgId,
                                                      @RequestParam(required = false) Long studentId) {
        return R.ok(kindService.pageGrowth(current, size, orgId, studentId));
    }

    @PostMapping("/growth/save")
    public R<KindGrowthRecord> saveGrowth(@RequestBody KindGrowthRecord record) {
        return R.ok(kindService.saveGrowth(record));
    }

    // ---- 晨午检/异常健康/巡查 ----
    @GetMapping("/health-check/list")
    public R<List<KindHealthCheck>> listHealthCheck(@RequestParam(required = false) Long orgId,
                                                    @RequestParam(required = false) String checkDate,
                                                    @RequestParam(required = false) Integer isAbnormal) {
        return R.ok(kindService.listHealthCheck(orgId, checkDate, isAbnormal));
    }

    @PostMapping("/health-check/save")
    public R<KindHealthCheck> saveHealthCheck(@RequestBody KindHealthCheck check) {
        return R.ok(kindService.saveHealthCheck(check));
    }

    @GetMapping("/health-abnormal/list")
    public R<List<KindHealthAbnormal>> listHealthAbnormal(@RequestParam(required = false) Long orgId,
                                                          @RequestParam(required = false) String status) {
        return R.ok(kindService.listHealthAbnormal(orgId, status));
    }

    @PostMapping("/health-abnormal/save")
    public R<KindHealthAbnormal> saveHealthAbnormal(@RequestBody KindHealthAbnormal abnormal) {
        return R.ok(kindService.saveHealthAbnormal(abnormal));
    }

    @GetMapping("/inspect/list")
    public R<List<KindSafetyInspect>> listInspect(@RequestParam(required = false) Long orgId,
                                                  @RequestParam(required = false) String status) {
        return R.ok(kindService.listInspect(orgId, status));
    }

    @PostMapping("/inspect/save")
    public R<KindSafetyInspect> saveInspect(@RequestBody KindSafetyInspect inspect) {
        return R.ok(kindService.saveInspect(inspect));
    }
}
