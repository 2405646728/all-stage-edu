package com.asedu.sys.controller;

import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
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
import com.asedu.sys.service.PlatformService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 平台运维（超级管理员专属） */
@RestController
@RequestMapping("/api/sys")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SUPER_ADMIN')")
public class PlatformController {

    private final PlatformService platformService;

    // 校区
    @GetMapping("/campus/list")
    public R<List<SysCampus>> listCampus(@RequestParam Long orgId) {
        return R.ok(platformService.listCampus(orgId));
    }

    @PostMapping("/campus/save")
    public R<SysCampus> saveCampus(@RequestBody SysCampus campus) {
        return R.ok(platformService.saveCampus(campus));
    }

    // 模块与机构开关
    @GetMapping("/module/list")
    public R<List<SysModule>> listModules(@RequestParam(required = false) String stage) {
        return R.ok(platformService.listModules(stage));
    }

    @GetMapping("/module/org-switch/list")
    public R<List<SysOrgModuleSwitch>> listOrgSwitches(@RequestParam Long orgId) {
        return R.ok(platformService.listOrgSwitches(orgId));
    }

    @PostMapping("/module/org-switch/save")
    public R<SysOrgModuleSwitch> saveOrgSwitch(@RequestBody SysOrgModuleSwitch sw) {
        return R.ok(platformService.saveOrgSwitch(sw));
    }

    // 全局参数
    @GetMapping("/param/list")
    public R<List<SysGlobalParam>> listParams(@RequestParam(required = false) String group) {
        return R.ok(platformService.listParams(group));
    }

    @PostMapping("/param/save")
    public R<SysGlobalParam> saveParam(@RequestBody SysGlobalParam param) {
        return R.ok(platformService.saveParam(param));
    }

    // 门禁硬件
    @GetMapping("/device/page")
    public R<PageResult<SysGateDevice>> pageDevice(@RequestParam(defaultValue = "1") long current,
                                                   @RequestParam(defaultValue = "10") long size,
                                                   @RequestParam(required = false) Long orgId,
                                                   @RequestParam(required = false) String keyword,
                                                   @RequestParam(required = false) Integer status) {
        return R.ok(platformService.pageDevice(current, size, orgId, keyword, status));
    }

    @PostMapping("/device/save")
    public R<SysGateDevice> saveDevice(@RequestBody SysGateDevice device) {
        return R.ok(platformService.saveDevice(device));
    }

    // 版本 / 热补丁 / API 网关
    @GetMapping("/version/list")
    public R<List<SysVersion>> listVersions() {
        return R.ok(platformService.listVersions());
    }

    @PostMapping("/version/save")
    public R<SysVersion> saveVersion(@RequestBody SysVersion version) {
        return R.ok(platformService.saveVersion(version));
    }

    @GetMapping("/hotpatch/list")
    public R<List<SysHotpatch>> listHotpatches() {
        return R.ok(platformService.listHotpatches());
    }

    @GetMapping("/api/list")
    public R<List<SysApiGateway>> listApis(@RequestParam(required = false) String keyword) {
        return R.ok(platformService.listApis(keyword));
    }

    // 操作日志
    @GetMapping("/log/operation/page")
    public R<PageResult<SysLogOperation>> pageLog(@RequestParam(defaultValue = "1") long current,
                                                  @RequestParam(defaultValue = "10") long size,
                                                  @RequestParam(required = false) Long orgId,
                                                  @RequestParam(required = false) String username,
                                                  @RequestParam(required = false) String bizType) {
        return R.ok(platformService.pageLog(current, size, orgId, username, bizType));
    }

    // 告警中心
    @GetMapping("/alert/page")
    public R<PageResult<SysAlert>> pageAlert(@RequestParam(defaultValue = "1") long current,
                                             @RequestParam(defaultValue = "10") long size,
                                             @RequestParam(required = false) String level,
                                             @RequestParam(required = false) Integer status) {
        return R.ok(platformService.pageAlert(current, size, level, status));
    }

    @PostMapping("/alert/handle")
    public R<SysAlert> handleAlert(@RequestParam Long id, @RequestParam(required = false) String remark) {
        return R.ok(platformService.handleAlert(id, remark));
    }

    // IP 黑白名单
    @GetMapping("/ip-rule/list")
    public R<List<SysIpRule>> listIpRules(@RequestParam(required = false) String ruleType) {
        return R.ok(platformService.listIpRules(ruleType));
    }

    @PostMapping("/ip-rule/save")
    public R<SysIpRule> saveIpRule(@RequestBody SysIpRule rule) {
        return R.ok(platformService.saveIpRule(rule));
    }

    @DeleteMapping("/ip-rule/{id}")
    public R<Void> deleteIpRule(@PathVariable Long id) {
        platformService.deleteIpRule(id);
        return R.ok();
    }

    // 登录日志
    @GetMapping("/log/login/page")
    public R<PageResult<SysLogLogin>> pageLoginLog(@RequestParam(defaultValue = "1") long current,
                                                   @RequestParam(defaultValue = "10") long size,
                                                   @RequestParam(required = false) String username,
                                                   @RequestParam(required = false) Integer result) {
        return R.ok(platformService.pageLoginLog(current, size, username, result));
    }

    // 备份记录
    @GetMapping("/backup/list")
    public R<List<SysBackupRecord>> listBackups() {
        return R.ok(platformService.listBackups());
    }

    @PostMapping("/backup/save")
    public R<SysBackupRecord> saveBackup(@RequestBody SysBackupRecord record) {
        return R.ok(platformService.saveBackup(record));
    }

    // 政务上报模板
    @GetMapping("/gov/list")
    public R<List<SysGovReportTemplate>> listGovTemplates() {
        return R.ok(platformService.listGovTemplates());
    }

    @PostMapping("/gov/save")
    public R<SysGovReportTemplate> saveGovTemplate(@RequestBody SysGovReportTemplate template) {
        return R.ok(platformService.saveGovTemplate(template));
    }

    // 版本灰度
    @GetMapping("/version-org/list")
    public R<List<SysVersionOrg>> listVersionOrgs(@RequestParam(required = false) Long versionId) {
        return R.ok(platformService.listVersionOrgs(versionId));
    }

    @PostMapping("/version-org/save")
    public R<SysVersionOrg> saveVersionOrg(@RequestBody SysVersionOrg vo) {
        return R.ok(platformService.saveVersionOrg(vo));
    }
}