package com.asedu.config;

import com.asedu.sys.entity.SysMenu;
import com.asedu.sys.entity.SysRole;
import com.asedu.sys.entity.SysRolePermission;
import com.asedu.sys.mapper.SysMenuMapper;
import com.asedu.sys.mapper.SysRoleMapper;
import com.asedu.sys.mapper.SysRolePermissionMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

/**
 * 启动数据初始化：
 * 1) sys_menu 为空时写入平台基础菜单（不改动只读 db 文件，菜单属运行时权限数据）；
 * 2) 为超级管理员角色授予全部菜单权限（权限终审兜底：无审核不生效，内置授权记录 grantedBy=0 平台初始化）。
 * 冻结原则：本初始化仅作用于业务权限表，不触碰冻结文档与 db/*.sql。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements ApplicationRunner {

    private final SysMenuMapper menuMapper;
    private final SysRoleMapper roleMapper;
    private final SysRolePermissionMapper rolePermMapper;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (menuMapper.selectCount(null) != null && menuMapper.selectCount(null) > 0) {
            return;
        }
        log.info("初始化平台基础菜单与超管授权...");
        List<SysMenu> menus = new ArrayList<>();
        menus.add(menu("platform", "平台管控", "dir", "ALL", "", 10, null));
        menus.add(menu("platform_org", "机构管理", "menu", "ALL", "/platform/org", 101, null));
        menus.add(menu("platform_campus", "校区管理", "menu", "ALL", "/platform/campus", 102, null));
        menus.add(menu("platform_module", "模块开关", "menu", "ALL", "/platform/module", 103, null));
        menus.add(menu("platform_dict", "字典管理", "menu", "ALL", "/platform/dict", 104, null));
        menus.add(menu("platform_param", "全局参数", "menu", "ALL", "/platform/param", 105, null));
        menus.add(menu("platform_device", "门禁硬件", "menu", "ALL", "/platform/device", 106, null));
        menus.add(menu("platform_log", "操作日志", "menu", "ALL", "/platform/log", 107, null));
        menus.add(menu("platform_alert", "告警中心", "menu", "ALL", "/platform/alert", 108, null));
        menus.add(menu("platform_version", "版本热补丁", "menu", "ALL", "/platform/version", 109, null));
        menus.add(menu("platform_api", "API网关", "menu", "ALL", "/platform/api", 110, null));

        menus.add(menu("base", "基础档案", "dir", "ALL", "", 20, null));
        menus.add(menu("base_student", "学生管理", "menu", "ALL", "/base/student", 201, null));
        menus.add(menu("base_class", "班级架构", "menu", "ALL", "/base/class", 202, null));
        menus.add(menu("base_teacher", "教师管理", "menu", "ALL", "/base/teacher", 203, null));
        menus.add(menu("base_guardian", "监护人", "menu", "ALL", "/base/guardian", 204, null));

        menus.add(menu("common", "通用业务", "dir", "ALL", "", 30, null));
        menus.add(menu("common_att", "考勤管理", "menu", "ALL", "/att", 301, null));
        menus.add(menu("common_gate", "门禁通行", "menu", "ALL", "/gate", 302, null));
        menus.add(menu("common_msg", "通知消息", "menu", "ALL", "/msg", 303, null));
        menus.add(menu("common_fin", "收费台账", "menu", "ALL", "/fin", 304, null));

        menus.add(menu("stage_kind", "幼儿园专属", "dir", "kindergarten", "", 40, null));
        menus.add(menu("stage_edu", "教务德育", "dir", "primary,junior,senior,vocational", "", 50, null));
        menus.add(menu("stage_senior", "新高考选科走班", "dir", "senior", "", 60, null));
        menus.add(menu("stage_voc", "实训实习就业", "dir", "vocational", "", 70, null));
        menus.add(menu("stage_uni", "高校教务", "dir", "university", "", 80, null));

        // 插入并建立 parentId
        for (SysMenu m : menus) {
            if (m.getParentId() == null) {
                menuMapper.insert(m);
            }
        }
        for (SysMenu m : menus) {
            if (m.getParentId() != null) {
                // parentId 用编码匹配
                SysMenu parent = menuMapper.selectOne(new LambdaQueryWrapper<SysMenu>()
                        .eq(SysMenu::getMenuCode, parentCodeOf(m.getMenuCode())));
                if (parent != null) {
                    m.setParentId(parent.getId());
                }
                menuMapper.insert(m);
            }
        }

        // 超管全量授权（内置初始化授权，grantedBy=0）
        SysRole superRole = roleMapper.selectOne(new LambdaQueryWrapper<SysRole>()
                .eq(SysRole::getRoleCode, "SUPER_ADMIN"));
        if (superRole != null) {
            List<SysMenu> all = menuMapper.selectList(null);
            for (SysMenu m : all) {
                SysRolePermission rp = new SysRolePermission();
                rp.setRoleId(superRole.getId());
                rp.setMenuId(m.getId());
                rp.setPermType("menu");
                rp.setDataScope("all_platform");
                rp.setGrantedBy(0L);
                rolePermMapper.insert(rp);
            }
        }
        log.info("平台基础菜单初始化完成：{} 条", menus.size());
    }

    private String parentCodeOf(String code) {
        // platform_org -> platform ; base_student -> base ; common_att -> common
        int idx = code.lastIndexOf('_');
        if (idx <= 0) {
            return null;
        }
        String parent = code.substring(0, idx);
        if (parent.startsWith("stage")) {
            return null; // stage_* 为顶级 dir，无父级
        }
        return parent;
    }

    private SysMenu menu(String code, String name, String type, String scope, String path, int sort, Long parentId) {
        SysMenu m = new SysMenu();
        m.setMenuCode(code);
        m.setMenuName(name);
        m.setMenuType(type);
        m.setStageScope(scope);
        m.setRoutePath(path);
        m.setSortNo(sort);
        m.setStatus(1);
        m.setParentId(parentId);
        return m;
    }
}
