package com.asedu.gate.service;

import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.asedu.gate.entity.GateAlert;
import com.asedu.gate.entity.GatePassRecord;
import com.asedu.gate.entity.GatePermission;
import com.asedu.gate.entity.GateVisitor;
import com.asedu.gate.mapper.GateAlertMapper;
import com.asedu.gate.mapper.GatePassRecordMapper;
import com.asedu.gate.mapper.GatePermissionMapper;
import com.asedu.gate.mapper.GateVisitorMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * 门禁安防服务：通行记录全量溯源/通行权限配置/陌生拦截预警/访客预约
 */
@Service
@RequiredArgsConstructor
public class GateService {

    private final GatePassRecordMapper passMapper;
    private final GatePermissionMapper permissionMapper;
    private final GateAlertMapper alertMapper;
    private final GateVisitorMapper visitorMapper;

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

    // ---------- 通行记录（全量溯源） ----------
    public PageResult<GatePassRecord> pagePass(long current, long size, Long orgId, String keyword,
                                               String passDate, String result) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<GatePassRecord> qw = new LambdaQueryWrapper<GatePassRecord>()
                .eq(GatePassRecord::getOrgId, oid)
                .eq(result != null && !result.isBlank(), GatePassRecord::getResult, result)
                .eq(passDate != null && !passDate.isBlank(), GatePassRecord::getPassTime, passDate);
        if (keyword != null && !keyword.isBlank()) {
            qw.and(w -> w.like(GatePassRecord::getPersonName, keyword).or().like(GatePassRecord::getDeviceName, keyword));
        }
        qw.orderByDesc(GatePassRecord::getPassTime);
        return PageResult.of(passMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public GatePassRecord recordPass(GatePassRecord record) {
        Long oid = resolveOrgId(record.getOrgId());
        record.setOrgId(oid);
        if (record.getResult() == null || record.getResult().isBlank()) {
            record.setResult("valid");
        }
        passMapper.insert(record);
        return record;
    }

    // ---------- 通行权限 ----------
    public java.util.List<GatePermission> listPermission(Long orgId, String personType) {
        Long oid = resolveOrgId(orgId);
        return permissionMapper.selectList(new LambdaQueryWrapper<GatePermission>()
                .eq(GatePermission::getOrgId, oid)
                .eq(personType != null && !personType.isBlank(), GatePermission::getPersonType, personType)
                .orderByDesc(GatePermission::getCreatedAt));
    }

    @Transactional
    public GatePermission savePermission(GatePermission permission) {
        permission.setOrgId(resolveOrgId(permission.getOrgId()));
        permission.setOperatorId(UserContext.userId());
        if (permission.getId() == null) {
            permissionMapper.insert(permission);
        } else {
            permissionMapper.updateById(permission);
        }
        return permission;
    }

    // ---------- 预警 ----------
    public PageResult<GateAlert> pageAlert(long current, long size, Long orgId, Integer status) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<GateAlert> qw = new LambdaQueryWrapper<GateAlert>()
                .eq(GateAlert::getOrgId, oid)
                .eq(status != null, GateAlert::getStatus, status)
                .orderByDesc(GateAlert::getCreatedAt);
        return PageResult.of(alertMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public GateAlert handleAlert(Long id, String note) {
        GateAlert alert = alertMapper.selectById(id);
        if (alert == null) {
            throw new BusinessException("预警不存在");
        }
        alert.setStatus(1);
        alert.setHandledBy(UserContext.userId());
        alert.setHandledAt(LocalDateTime.now());
        alert.setHandleNote(note == null ? "" : note);
        alertMapper.updateById(alert);
        return alert;
    }

    // ---------- 访客 ----------
    public PageResult<GateVisitor> pageVisitor(long current, long size, Long orgId) {
        Long oid = resolveOrgId(orgId);
        return PageResult.of(visitorMapper.selectPage(new Page<>(current, size),
                new LambdaQueryWrapper<GateVisitor>().eq(GateVisitor::getOrgId, oid)
                        .orderByDesc(GateVisitor::getCreatedAt)));
    }

    @Transactional
    public GateVisitor saveVisitor(GateVisitor visitor) {
        visitor.setOrgId(resolveOrgId(visitor.getOrgId()));
        if (visitor.getApproveStatus() == null || visitor.getApproveStatus().isBlank()) {
            visitor.setApproveStatus("pending");
        }
        if (visitor.getId() == null) {
            visitorMapper.insert(visitor);
        } else {
            visitorMapper.updateById(visitor);
        }
        return visitor;
    }
}
