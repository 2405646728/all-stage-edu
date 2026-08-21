package com.asedu.sys.service;

import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.asedu.sys.entity.SysOrg;
import com.asedu.sys.mapper.SysOrgMapper;
import com.asedu.sys.vo.OrgVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

/**
 * 机构服务（数据隔离：校管仅可见本机构，超管可见全部）
 */
@Service
@RequiredArgsConstructor
public class SysOrgService {

    private final SysOrgMapper sysOrgMapper;

    public PageResult<OrgVO> page(long current, long size, String keyword, String stage, Integer status) {
        LambdaQueryWrapper<SysOrg> qw = new LambdaQueryWrapper<>();
        // 数据隔离：非超管只能查本机构
        if (!UserContext.isSuperAdmin()) {
            qw.eq(SysOrg::getId, UserContext.orgId());
        }
        if (keyword != null && !keyword.isBlank()) {
            qw.and(w -> w.like(SysOrg::getOrgName, keyword).or().like(SysOrg::getOrgCode, keyword));
        }
        if (stage != null && !stage.isBlank()) {
            qw.eq(SysOrg::getStage, stage);
        }
        if (status != null) {
            qw.eq(SysOrg::getStatus, status);
        }
        qw.orderByDesc(SysOrg::getCreatedAt);
        Page<SysOrg> page = sysOrgMapper.selectPage(new Page<>(current, size), qw);
        PageResult<OrgVO> result = new PageResult<>();
        result.setTotal(page.getTotal());
        result.setPages(page.getPages());
        result.setCurrent(page.getCurrent());
        result.setSize(page.getSize());
        result.setRecords(page.getRecords().stream().map(this::toVO).toList());
        return result;
    }

    public OrgVO currentOrg() {
        Long orgId = UserContext.orgId();
        if (orgId == null) {
            throw new BusinessException("平台超级管理员无绑定机构");
        }
        return toVO(sysOrgMapper.selectById(orgId));
    }

    public OrgVO getById(Long id) {
        return toVO(sysOrgMapper.selectById(id));
    }

    /** 机构入驻创建（强制绑定唯一学段；状态默认待审核） */
    @org.springframework.transaction.annotation.Transactional
    public SysOrg create(SysOrg org) {
        if (org.getOrgCode() == null || org.getOrgCode().isBlank()) {
            throw new BusinessException("机构编码不能为空");
        }
        if (org.getStage() == null || org.getStage().isBlank()) {
            throw new BusinessException("学段不能为空（单机构单学段冻结规则）");
        }
        Long dup = sysOrgMapper.selectCount(new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<SysOrg>()
                .eq(SysOrg::getOrgCode, org.getOrgCode()));
        if (dup != null && dup > 0) {
            throw new BusinessException("机构编码已存在：" + org.getOrgCode());
        }
        if (org.getStatus() == null) {
            org.setStatus(0); // 待审核
        }
        org.setCreatedBy(UserContext.userId());
        sysOrgMapper.insert(org);
        return org;
    }

    /** 机构信息编辑 */
    @org.springframework.transaction.annotation.Transactional
    public SysOrg update(Long id, SysOrg org) {
        SysOrg exist = sysOrgMapper.selectById(id);
        if (exist == null) {
            throw new BusinessException("机构不存在");
        }
        org.setId(id);
        org.setCreatedBy(null);
        org.setCreatedAt(null);
        org.setUpdatedBy(UserContext.userId());
        sysOrgMapper.updateById(org);
        return sysOrgMapper.selectById(id);
    }

    /** 机构状态流转：审核通过/禁用/注销（全生命周期管控，操作留痕） */
    @org.springframework.transaction.annotation.Transactional
    public SysOrg changeStatus(Long id, int status, String remark) {
        SysOrg exist = sysOrgMapper.selectById(id);
        if (exist == null) {
            throw new BusinessException("机构不存在");
        }
        SysOrg update = new SysOrg();
        update.setId(id);
        update.setStatus(status);
        update.setAuditRemark(remark);
        update.setAuditBy(UserContext.userId());
        update.setAuditAt(java.time.LocalDateTime.now());
        update.setUpdatedBy(UserContext.userId());
        sysOrgMapper.updateById(update);
        return sysOrgMapper.selectById(id);
    }

    private OrgVO toVO(SysOrg org) {
        if (org == null) {
            return null;
        }
        OrgVO vo = new OrgVO();
        BeanUtils.copyProperties(org, vo);
        return vo;
    }
}