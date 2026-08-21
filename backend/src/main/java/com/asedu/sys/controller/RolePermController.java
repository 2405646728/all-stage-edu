package com.asedu.sys.controller;

import com.asedu.common.api.R;
import com.asedu.sys.entity.SysMenu;
import com.asedu.sys.entity.SysRole;
import com.asedu.sys.service.RolePermService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/** 全局角色与权限终审（菜单/按钮/数据三级） */
@RestController
@RequestMapping("/api/sys/perm")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SUPER_ADMIN')")
public class RolePermController {

    private final RolePermService rolePermService;

    @GetMapping("/role/list")
    public R<List<SysRole>> listRoles() {
        return R.ok(rolePermService.listRoles());
    }

    @GetMapping("/menu/tree")
    public R<List<SysMenu>> menuTree() {
        return R.ok(rolePermService.menuTree());
    }

    @GetMapping("/role/menus")
    public R<List<Long>> roleMenuIds(@RequestParam Long roleId) {
        return R.ok(rolePermService.roleMenuIds(roleId));
    }

    @PostMapping("/role/save")
    public R<com.asedu.sys.entity.SysRole> saveRole(@RequestBody com.asedu.sys.entity.SysRole role) {
        return R.ok(rolePermService.saveRole(role));
    }

    @PostMapping("/role/menus/save")
    public R<Void> saveRoleMenus(@RequestBody Map<String, Object> body) {
        Long roleId = Long.valueOf(String.valueOf(body.get("roleId")));
        @SuppressWarnings("unchecked")
        List<Long> menuIds = ((List<Object>) body.getOrDefault("menuIds", List.of()))
                .stream().map(o -> Long.valueOf(String.valueOf(o))).toList();
        rolePermService.saveRoleMenus(roleId, menuIds);
        return R.ok();
    }
}