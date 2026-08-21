package com.asedu.fin.controller;

import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import com.asedu.fin.entity.FinBill;
import com.asedu.fin.entity.FinFeeItem;
import com.asedu.fin.entity.FinFeeStandard;
import com.asedu.fin.entity.FinLedgerLog;
import com.asedu.fin.entity.FinPayment;
import com.asedu.fin.entity.FinReduction;
import com.asedu.fin.service.FinService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.List;

/** 收费台账（独立财务闭环，与业务日志隔离审计） */
@RestController
@RequestMapping("/api/fin")
@RequiredArgsConstructor
public class FinController {

    private final FinService finService;

    @GetMapping("/item/list")
    public R<List<FinFeeItem>> listFeeItems(@RequestParam(required = false) Long orgId) {
        return R.ok(finService.listFeeItems(orgId));
    }

    @PostMapping("/item/save")
    public R<FinFeeItem> saveFeeItem(@RequestBody FinFeeItem item) {
        return R.ok(finService.saveFeeItem(item));
    }

    @GetMapping("/standard/list")
    public R<List<FinFeeStandard>> listStandards(@RequestParam(required = false) Long orgId,
                                                 @RequestParam(required = false) Long feeItemId) {
        return R.ok(finService.listStandards(orgId, feeItemId));
    }

    @GetMapping("/bill/page")
    public R<PageResult<FinBill>> pageBill(@RequestParam(defaultValue = "1") long current,
                                           @RequestParam(defaultValue = "10") long size,
                                           @RequestParam(required = false) Long orgId,
                                           @RequestParam(required = false) String keyword,
                                           @RequestParam(required = false) String billStatus) {
        return R.ok(finService.pageBill(current, size, orgId, keyword, billStatus));
    }

    @PostMapping("/bill/generate")
    public R<FinBill> generateBill(@RequestParam(required = false) Long orgId,
                                   @RequestParam Long feeItemId,
                                   @RequestParam Long studentId,
                                   @RequestParam(required = false) BigDecimal amount,
                                   @RequestParam(required = false) Long schoolYearId,
                                   @RequestParam(required = false) Long termId) {
        return R.ok(finService.generateBill(orgId, feeItemId, studentId, amount, schoolYearId, termId));
    }

    @PostMapping("/payment/create")
    public R<FinPayment> createPayment(@RequestBody FinPayment payment) {
        return R.ok(finService.createPayment(payment));
    }

    @PostMapping("/reduction/save")
    public R<FinReduction> saveReduction(@RequestBody FinReduction reduction) {
        return R.ok(finService.saveReduction(reduction));
    }

    @GetMapping("/payment/by-bill")
    public R<List<FinPayment>> paymentsByBill(@RequestParam Long billId) {
        return R.ok(finService.paymentsByBill(billId));
    }

    @GetMapping("/ledger/page")
    public R<PageResult<FinLedgerLog>> pageLedger(@RequestParam(defaultValue = "1") long current,
                                                  @RequestParam(defaultValue = "10") long size,
                                                  @RequestParam(required = false) Long orgId) {
        return R.ok(finService.pageLedger(current, size, orgId));
    }
}