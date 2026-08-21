package com.asedu.sys.service;

import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.asedu.sys.entity.SysAlert;
import com.asedu.sys.entity.SysBackupRecord;
import com.asedu.sys.entity.SysGovReportTemplate;
import com.asedu.sys.entity.SysIpRule;
import com.asedu.sys.entity.SysLogLogin;
import com.asedu.sys.entity.SysVersionOrg;
import com.asedu.sys.entity.SysApiGateway;
import com.asedu.sys.entity.SysCampus;
import com.asedu.sys.entity.SysGateDevice;
import com.asedu.sys.entity.SysGlobalParam;
import com.asedu.sys.entity.SysHotpatch;
import com.asedu.sys.entity.SysLogOperation;
import com.asedu.sys.entity.SysModule;
import com.asedu.sys.entity.SysOrgModuleSwitch;
import com.asedu.sys.entity.SysVersion;
import com.asedu.sys.mapper.SysAlertMapper;
import com.asedu.sys.mapper.SysBackupRecordMapper;
import com.asedu.sys.mapper.SysGovReportTemplateMapper;
import com.asedu.sys.mapper.SysIpRuleMapper;
import com.asedu.sys.mapper.SysLogLoginMapper;
import com.asedu.sys.mapper.SysVersionOrgMapper;
import com.asedu.sys.mapper.SysApiGatewayMapper;
import com.asedu.sys.mapper.SysCampusMapper;
import com.asedu.sys.mapper.SysGateDeviceMapper;
import com.asedu.sys.mapper.SysGlobalParamMapper;
import com.asedu.sys.mapper.SysHotpatchMapper;
import com.asedu.sys.mapper.SysLogOperationMapper;
import com.asedu.sys.mapper.SysModuleMapper;
import com.asedu.sys.mapper.SysOrgModuleSwitchMapper;
import com.asedu.sys.mapper.SysVersionMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 平台运维服务（超级管理员专属）：校区/模块开关/全局参数/门禁硬件/
 * 版本迭代/热补丁/API网关/操作日志/告警中心
 */
@Service
@RequiredArgsConstructor
public class PlatformService {

    private final SysCampusMapper campusMapper;
    private final SysModuleMapper moduleMapper;
    private final SysOrgModuleSwitchMapper switchMapper;
    private final SysGlobalParamMapper paramMapper;
    private final SysGateDeviceMapper deviceMapper;
    private final SysVersionMapper versionMapper;
    private final SysHotpatchMapper hotpatchMapper;
    private final SysApiGatewayMapper apiMapper;
    private final SysLogOperationMapper logMapper;
    private final SysAlertMapper alertMapper;
    private final SysIpRuleMapper ipRuleMapper;
    private final SysLogLoginMapper loginLogMapper;
    private final SysBackupRecordMapper backupMapper;
    private final SysGovReportTemplateMapper govMapper;
    private final SysVersionOrgMapper versionOrgMapper;

    // ---------- 校区 ----------
    public List<SysCampus> listCampus(Long orgId) {
        return campusMapper.selectList(new LambdaQueryWrapper<SysCampus>()
                .eq(SysCampus::getOrgId, orgId).orderByAsc(SysCampus::getCampusCode));
    }

    @Transactional
    public SysCampus saveCampus(SysCampus campus) {
        if (campus.getId() == null) {
            campusMapper.insert(campus);
        } else {
            campusMapper.updateById(campus);
        }
        return campus;
    }

    // ---------- 模块与机构开关 ----------
    public List<SysModule> listModules(String stage) {
        LambdaQueryWrapper<SysModule> qw = new LambdaQueryWrapper<>();
        if (stage != null && !stage.isBlank()) {
            qw.and(w -> w.eq(SysModule::getStageScope, "ALL").or().like(SysModule::getStageScope, stage));
        }
        qw.orderByAsc(SysModule::getSortNo);
        return moduleMapper.selectList(qw);
    }

    public List<SysOrgModuleSwitch> listOrgSwitches(Long orgId) {
        return switchMapper.selectList(new LambdaQueryWrapper<SysOrgModuleSwitch>()
                .eq(SysOrgModuleSwitch::getOrgId, orgId));
    }

    @Transactional
    public SysOrgModuleSwitch saveOrgSwitch(SysOrgModuleSwitch sw) {
        // 幂等 upsert：按 (orgId, moduleCode) 唯一键复用记录，避免重复插入
        if (sw.getId() == null) {
            SysOrgModuleSwitch exist = switchMapper.selectOne(new LambdaQueryWrapper<SysOrgModuleSwitch>()
                    .eq(SysOrgModuleSwitch::getOrgId, sw.getOrgId())
                    .eq(SysOrgModuleSwitch::getModuleCode, sw.getModuleCode())
                    .last("LIMIT 1"));
            if (exist != null) {
                sw.setId(exist.getId());
            }
        }
        sw.setUpdatedBy(UserContext.userId());
        if (sw.getId() == null) {
            switchMapper.insert(sw);
        } else {
            switchMapper.updateById(sw);
        }
        return sw;
    }

    // ---------- 全局参数 ----------
    public List<SysGlobalParam> listParams(String group) {
        return paramMapper.selectList(new LambdaQueryWrapper<SysGlobalParam>()
                .eq(group != null && !group.isBlank(), SysGlobalParam::getParamGroup, group)
                .orderByAsc(SysGlobalParam::getParamGroup).orderByAsc(SysGlobalParam::getParamKey));
    }

    @Transactional
    public SysGlobalParam saveParam(SysGlobalParam param) {
        param.setUpdatedBy(UserContext.userId());
        if (param.getId() == null) {
            paramMapper.insert(param);
        } else {
            paramMapper.updateById(param);
        }
        return param;
    }

    // ---------- 门禁硬件 ----------
    public PageResult<SysGateDevice> pageDevice(long current, long size, Long orgId, String keyword, Integer status) {
        LambdaQueryWrapper<SysGateDevice> qw = new LambdaQueryWrapper<>();
        if (orgId != null) {
            qw.eq(SysGateDevice::getOrgId, orgId);
        }
        if (status != null) {
            qw.eq(SysGateDevice::getStatus, status);
        }
        if (keyword != null && !keyword.isBlank()) {
            qw.and(w -> w.like(SysGateDevice::getDeviceName, keyword).or().like(SysGateDevice::getDeviceCode, keyword));
        }
        qw.orderByDesc(SysGateDevice::getCreatedAt);
        return PageResult.of(deviceMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public SysGateDevice saveDevice(SysGateDevice device) {
        if (device.getId() == null) {
            deviceMapper.insert(device);
        } else {
            deviceMapper.updateById(device);
        }
        return device;
    }

    // ---------- 版本 / 热补丁 / API 网关 ----------
    public List<SysVersion> listVersions() {
        return versionMapper.selectList(new LambdaQueryWrapper<SysVersion>().orderByDesc(SysVersion::getCreatedAt));
    }

    @Transactional
    public SysVersion saveVersion(SysVersion version) {
        if (version.getId() == null) {
            versionMapper.insert(version);
        } else {
            versionMapper.updateById(version);
        }
        return version;
    }

    public List<SysHotpatch> listHotpatches() {
        return hotpatchMapper.selectList(new LambdaQueryWrapper<SysHotpatch>().orderByDesc(SysHotpatch::getCreatedAt));
    }

    public List<SysApiGateway> listApis(String keyword) {
        LambdaQueryWrapper<SysApiGateway> qw = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            qw.and(w -> w.like(SysApiGateway::getApiName, keyword).or().like(SysApiGateway::getApiPath, keyword));
        }
        qw.orderByAsc(SysApiGateway::getApiCode);
        return apiMapper.selectList(qw);
    }

    // ---------- 操作日志（永久留存可溯源） ----------
    public PageResult<SysLogOperation> pageLog(long current, long size, Long orgId, String username, String bizType) {
        LambdaQueryWrapper<SysLogOperation> qw = new LambdaQueryWrapper<>();
        if (orgId != null) {
            qw.eq(SysLogOperation::getOrgId, orgId);
        }
        if (username != null && !username.isBlank()) {
            qw.like(SysLogOperation::getUsername, username);
        }
        if (bizType != null && !bizType.isBlank()) {
            qw.eq(SysLogOperation::getBizType, bizType);
        }
        qw.orderByDesc(SysLogOperation::getOperatedAt);
        return PageResult.of(logMapper.selectPage(new Page<>(current, size), qw));
    }

    // ---------- 告警中心 ----------
    public PageResult<SysAlert> pageAlert(long current, long size, String level, Integer status) {
        LambdaQueryWrapper<SysAlert> qw = new LambdaQueryWrapper<>();
        if (level != null && !level.isBlank()) {
            qw.eq(SysAlert::getAlertLevel, level);
        }
        if (status != null) {
            qw.eq(SysAlert::getStatus, status);
        }
        qw.orderByDesc(SysAlert::getOccurredAt);
        return PageResult.of(alertMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public SysAlert handleAlert(Long id, String remark) {
        SysAlert alert = alertMapper.selectById(id);
        if (alert == null) {
            throw new BusinessException("告警不存在");
        }
        alert.setStatus(2);
        alert.setHandledBy(UserContext.userId());
        alert.setHandledAt(LocalDateTime.now());
        alert.setHandleRemark(remark == null ? "" : remark);
        alertMapper.updateById(alert);
        return alert;
    }

    // ---------- IP 黑白名单（恶意访问拦截，文档 1.3.2-3） ----------
    public List<SysIpRule> listIpRules(String ruleType) {
        return ipRuleMapper.selectList(new LambdaQueryWrapper<SysIpRule>()
                .eq(ruleType != null && !ruleType.isBlank(), SysIpRule::getRuleType, ruleType)
                .orderByAsc(SysIpRule::getRuleType));
    }

    @Transactional
    public SysIpRule saveIpRule(SysIpRule rule) {
        rule.setCreatedBy(UserContext.userId());
        if (rule.getId() == null) {
            ipRuleMapper.insert(rule);
        } else {
            ipRuleMapper.updateById(rule);
        }
        return rule;
    }

    @Transactional
    public void deleteIpRule(Long id) {
        ipRuleMapper.deleteById(id);
    }

    // ---------- 登录日志（审计溯源） ----------
    public PageResult<SysLogLogin> pageLoginLog(long current, long size, String username, Integer result) {
        LambdaQueryWrapper<SysLogLogin> qw = new LambdaQueryWrapper<>();
        if (username != null && !username.isBlank()) {
            qw.like(SysLogLogin::getUsername, username);
        }
        if (result != null) {
            qw.eq(SysLogLogin::getLoginResult, result);
        }
        qw.orderByDesc(SysLogLogin::getLoginAt);
        return PageResult.of(loginLogMapper.selectPage(new Page<>(current, size), qw));
    }

    // ---------- 数据备份记录（运维能力，文档 1.3.4-2） ----------
    public List<SysBackupRecord> listBackups() {
        return backupMapper.selectList(new LambdaQueryWrapper<SysBackupRecord>()
                .orderByDesc(SysBackupRecord::getStartedAt));
    }

    @Transactional
    public SysBackupRecord saveBackup(SysBackupRecord record) {
        record.setOperatorId(UserContext.userId());
        if (record.getId() == null) {
            backupMapper.insert(record);
        } else {
            backupMapper.updateById(record);
        }
        return record;
    }

    // ---------- 政务上报模板（教育局/教育厅对接，文档 1.3.5-3） ----------
    public List<SysGovReportTemplate> listGovTemplates() {
        return govMapper.selectList(new LambdaQueryWrapper<SysGovReportTemplate>()
                .orderByAsc(SysGovReportTemplate::getTemplateCode));
    }

    @Transactional
    public SysGovReportTemplate saveGovTemplate(SysGovReportTemplate template) {
        if (template.getId() == null) {
            govMapper.insert(template);
        } else {
            govMapper.updateById(template);
        }
        return template;
    }

    // ---------- 版本灰度发布（文档 1.3.6-3） ----------
    public List<SysVersionOrg> listVersionOrgs(Long versionId) {
        return versionOrgMapper.selectList(new LambdaQueryWrapper<SysVersionOrg>()
                .eq(versionId != null, SysVersionOrg::getVersionId, versionId));
    }

    @Transactional
    public SysVersionOrg saveVersionOrg(SysVersionOrg vo) {
        if (vo.getId() == null) {
            versionOrgMapper.insert(vo);
        } else {
            versionOrgMapper.updateById(vo);
        }
        return vo;
    }
}