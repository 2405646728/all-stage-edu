package com.asedu.sys.controller;

import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import com.asedu.sys.service.SysOrgService;
import com.asedu.sys.vo.OrgVO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.asedu.sys.entity.SysOrg;

@RestController
@RequestMapping("/api/sys/org")
@RequiredArgsConstructor
public class SysOrgController {

    private final SysOrgService sysOrgService;

    /** 机构分页（超管全量/校管仅本机构） */
    @GetMapping("/page")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN','SCHOOL_ADMIN')")
    public R<PageResult<OrgVO>> page(@RequestParam(defaultValue = "1") long current,
                                     @RequestParam(defaultValue = "10") long size,
                                     @RequestParam(required = false) String keyword,
                                     @RequestParam(required = false) String stage,
                                     @RequestParam(required = false) Integer status) {
        return R.ok(sysOrgService.page(current, size, keyword, stage, status));
    }

    /** 当前用户所属机构 */
    @GetMapping("/current")
    public R<OrgVO> current() {
        return R.ok(sysOrgService.currentOrg());
    }

    /** 机构详情 */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN','SCHOOL_ADMIN')")
    public R<OrgVO> detail(@PathVariable Long id) {
        return R.ok(sysOrgService.getById(id));
    }

    /** 机构入驻创建（学段强制绑定） */
    @PostMapping("/create")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public R<SysOrg> create(@RequestBody SysOrg org) {
        return R.ok(sysOrgService.create(org));
    }

    /** 机构信息编辑 */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public R<SysOrg> update(@PathVariable Long id, @RequestBody SysOrg org) {
        return R.ok(sysOrgService.update(id, org));
    }

    /** 机构状态流转（审核/禁用/注销） */
    @PostMapping("/{id}/status")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public R<SysOrg> changeStatus(@PathVariable Long id, @RequestParam int status, @RequestParam(required = false) String remark) {
        return R.ok(sysOrgService.changeStatus(id, status, remark));
    }
}