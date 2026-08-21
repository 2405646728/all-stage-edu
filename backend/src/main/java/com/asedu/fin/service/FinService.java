package com.asedu.fin.service;

import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.fin.entity.FinBill;
import com.asedu.fin.entity.FinFeeItem;
import com.asedu.fin.entity.FinFeeStandard;
import com.asedu.fin.entity.FinLedgerLog;
import com.asedu.fin.entity.FinPayment;
import com.asedu.fin.entity.FinReduction;
import com.asedu.fin.mapper.FinBillMapper;
import com.asedu.fin.mapper.FinFeeItemMapper;
import com.asedu.fin.mapper.FinFeeStandardMapper;
import com.asedu.fin.mapper.FinLedgerLogMapper;
import com.asedu.fin.mapper.FinPaymentMapper;
import com.asedu.fin.mapper.FinReductionMapper;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 收费台账服务（独立财务闭环）：项目配置/标准/账单/缴费/减免/财务日志
 */
@Service
@RequiredArgsConstructor
public class FinService {

    private final FinFeeItemMapper itemMapper;
    private final FinFeeStandardMapper standardMapper;
    private final FinBillMapper billMapper;
    private final FinPaymentMapper paymentMapper;
    private final FinReductionMapper reductionMapper;
    private final FinLedgerLogMapper ledgerMapper;

    private Long resolveOrgId(Long orgId) {
        if (UserContext.isSuperAdmin()) {
            if (orgId == null) {
                throw new BusinessException("平台超级管理员操作机构数据必须指定 orgId");
            }
            return orgId;
        }
        Long mine = UserContext.orgId();
        if (mine == null) {
            throw new BusinessException("当前账号未绑定机构");
        }
        return mine;
    }

    // ---------- 收费项目 ----------
    public List<FinFeeItem> listFeeItems(Long orgId) {
        Long oid = resolveOrgId(orgId);
        return itemMapper.selectList(new LambdaQueryWrapper<FinFeeItem>()
                .eq(FinFeeItem::getOrgId, oid).orderByAsc(FinFeeItem::getItemCode));
    }

    @Transactional
    public FinFeeItem saveFeeItem(FinFeeItem item) {
        item.setOrgId(resolveOrgId(item.getOrgId()));
        item.setCreatedBy(UserContext.userId());
        if (item.getId() == null) {
            itemMapper.insert(item);
        } else {
            itemMapper.updateById(item);
        }
        return item;
    }

    public List<FinFeeStandard> listStandards(Long orgId, Long feeItemId) {
        Long oid = resolveOrgId(orgId);
        return standardMapper.selectList(new LambdaQueryWrapper<FinFeeStandard>()
                .eq(FinFeeStandard::getOrgId, oid)
                .eq(feeItemId != null, FinFeeStandard::getFeeItemId, feeItemId)
                .orderByDesc(FinFeeStandard::getCreatedAt));
    }

    // ---------- 账单 ----------
    public PageResult<FinBill> pageBill(long current, long size, Long orgId, String keyword, String billStatus) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<FinBill> qw = new LambdaQueryWrapper<FinBill>()
                .eq(FinBill::getOrgId, oid)
                .eq(billStatus != null && !billStatus.isBlank(), FinBill::getBillStatus, billStatus);
        if (keyword != null && !keyword.isBlank()) {
            qw.and(w -> w.like(FinBill::getBillNo, keyword).or()
                    .inSql(FinBill::getStudentId, "SELECT id FROM base_student WHERE org_id=" + oid + " AND name LIKE '%" + keyword + "%'"));
        }
        qw.orderByDesc(FinBill::getCreatedAt);
        return PageResult.of(billMapper.selectPage(new Page<>(current, size), qw));
    }

    /** 生成账单（按收费项目+学生，支持批量传学生ID列表） */
    @Transactional
    public FinBill generateBill(Long orgId, Long feeItemId, Long studentId, BigDecimal amount, Long schoolYearId, Long termId) {
        Long oid = resolveOrgId(orgId);
        FinFeeItem item = itemMapper.selectById(feeItemId);
        if (item == null) {
            throw new BusinessException("收费项目不存在");
        }
        FinBill bill = new FinBill();
        bill.setOrgId(oid);
        bill.setBillNo("B-" + orgCodeOf(oid) + "-" + System.currentTimeMillis() % 1000000);
        bill.setStudentId(studentId);
        bill.setFeeItemId(feeItemId);
        bill.setSchoolYearId(schoolYearId);
        bill.setTermId(termId);
        bill.setBillAmount(amount == null ? item.getDefaultAmount() : amount);
        bill.setReducedAmount(BigDecimal.ZERO);
        bill.setPaidAmount(BigDecimal.ZERO);
        bill.setBillStatus("unpaid");
        bill.setCreatedBy(UserContext.userId());
        billMapper.insert(bill);
        writeLedger(oid, "create", "fin_bill", bill.getId(), bill.getBillNo(), null, bill.getBillAmount(), "生成账单");
        return bill;
    }

    private String orgCodeOf(Long orgId) {
        return "ORG" + orgId;
    }

    // ---------- 缴费 ----------
    @Transactional
    public FinPayment createPayment(FinPayment payment) {
        Long oid = resolveOrgId(payment.getOrgId());
        payment.setOrgId(oid);
        FinBill bill = billMapper.selectById(payment.getBillId());
        if (bill == null) {
            throw new BusinessException("账单不存在");
        }
        payment.setOperatorId(UserContext.userId());
        paymentMapper.insert(payment);

        // 更新账单已缴金额与状态
        BigDecimal newPaid = bill.getPaidAmount() == null ? payment.getPayAmount() : bill.getPaidAmount().add(payment.getPayAmount());
        bill.setPaidAmount(newPaid);
        BigDecimal remain = bill.getBillAmount().subtract(bill.getReducedAmount() == null ? BigDecimal.ZERO : bill.getReducedAmount());
        if (newPaid.compareTo(remain) >= 0) {
            bill.setBillStatus("paid");
        } else if (newPaid.compareTo(BigDecimal.ZERO) > 0) {
            bill.setBillStatus("partial");
        }
        billMapper.updateById(bill);
        writeLedger(oid, "offset", "fin_bill", bill.getId(), bill.getBillNo(),
                bill.getPaidAmount().subtract(payment.getPayAmount()), newPaid, "缴费入账");
        return payment;
    }

    // ---------- 减免抵扣 ----------
    @Transactional
    public FinReduction saveReduction(FinReduction reduction) {
        Long oid = resolveOrgId(reduction.getOrgId());
        reduction.setOrgId(oid);
        reduction.setOperatorId(UserContext.userId());
        if (reduction.getAuditStatus() == null || reduction.getAuditStatus().isBlank()) {
            reduction.setAuditStatus("approved");
        }
        reductionMapper.insert(reduction);
        if (reduction.getBillId() != null) {
            FinBill bill = billMapper.selectById(reduction.getBillId());
            if (bill != null) {
                BigDecimal reduced = bill.getReducedAmount() == null ? BigDecimal.ZERO : bill.getReducedAmount();
                bill.setReducedAmount(reduced.add(reduction.getReduceAmount()));
                billMapper.updateById(bill);
                writeLedger(oid, "reduce", "fin_bill", bill.getId(), bill.getBillNo(),
                        reduced, bill.getReducedAmount(), "减免抵扣：" + reduction.getReduceType());
            }
        }
        return reduction;
    }

    // ---------- 缴费流水 ----------
    public List<FinPayment> paymentsByBill(Long billId) {
        return paymentMapper.selectList(new LambdaQueryWrapper<FinPayment>()
                .eq(FinPayment::getBillId, billId)
                .orderByDesc(FinPayment::getCreatedAt));
    }

    // ---------- 财务日志 ----------
    public PageResult<FinLedgerLog> pageLedger(long current, long size, Long orgId) {
        Long oid = resolveOrgId(orgId);
        return PageResult.of(ledgerMapper.selectPage(new Page<>(current, size),
                new LambdaQueryWrapper<FinLedgerLog>().eq(FinLedgerLog::getOrgId, oid)
                        .orderByDesc(FinLedgerLog::getCreatedAt)));
    }

    private void writeLedger(Long orgId, String action, String table, Long targetId, String billNo,
                             BigDecimal before, BigDecimal after, String detail) {
        FinLedgerLog log = new FinLedgerLog();
        log.setOrgId(orgId);
        log.setAction(action);
        log.setTargetTable(table);
        log.setTargetId(targetId);
        log.setBillNo(billNo == null ? "" : billNo);
        log.setAmountBefore(before);
        log.setAmountAfter(after);
        log.setDetail(detail);
        log.setOperatorId(UserContext.userId());
        log.setOperatorName(UserContext.get() == null ? "" : UserContext.get().getUsername());
        ledgerMapper.insert(log);
    }
}