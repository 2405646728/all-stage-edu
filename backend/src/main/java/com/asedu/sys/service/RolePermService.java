package com.asedu.sys.service;

import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.asedu.sys.entity.SysMenu;
import com.asedu.sys.entity.SysRole;
import com.asedu.sys.entity.SysRolePermission;
import com.asedu.sys.mapper.SysMenuMapper;
import com.asedu.sys.mapper.SysRoleMapper;
import com.asedu.sys.mapper.SysRolePermissionMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

/**
 * 菜单/按钮/数据三级权限（文档 12.4 权限颗粒度管控）
 */
@Service
@RequiredArgsConstructor
public class RolePermService {

    private final SysMenuMapper menuMapper;
    private final SysRoleMapper roleMapper;
    private final SysRolePermissionMapper rolePermMapper;

    public List<SysRole> listRoles() {
        return roleMapper.selectList(new LambdaQueryWrapper<SysRole>().orderByAsc(SysRole::getRoleLevel));
    }

    /** 菜单树 */
    public List<SysMenu> menuTree() {
        List<SysMenu> all = menuMapper.selectList(new LambdaQueryWrapper<SysMenu>()
                .orderByAsc(SysMenu::getSortNo));
        List<SysMenu> roots = new ArrayList<>();
        for (SysMenu m : all) {
            if (m.getParentId() == null || m.getParentId() == 0) {
                roots.add(m);
            }
        }
        for (SysMenu root : roots) {
            root.setChildren(childrenOf(all, root.getId()));
        }
        return roots;
    }

    private List<SysMenu> childrenOf(List<SysMenu> all, Long parentId) {
        List<SysMenu> list = new ArrayList<>();
        for (SysMenu m : all) {
            if (parentId.equals(m.getParentId())) {
                m.setChildren(childrenOf(all, m.getId()));
                list.add(m);
            }
        }
        return list;
    }

    /** 角色新增/编辑（内置角色仅可编辑描述） */
    @org.springframework.transaction.annotation.Transactional
    public SysRole saveRole(SysRole role) {
        if (role.getRoleCode() == null || role.getRoleCode().isBlank()) {
            throw new BusinessException("角色编码不能为空");
        }
        if (role.getId() == null) {
            Long dup = roleMapper.selectCount(new LambdaQueryWrapper<SysRole>()
                    .eq(SysRole::getRoleCode, role.getRoleCode()));
            if (dup != null && dup > 0) {
                throw new BusinessException("角色编码已存在");
            }
            role.setIsBuiltin(0);
            role.setCreatedBy(UserContext.userId());
            roleMapper.insert(role);
        } else {
            SysRole exist = roleMapper.selectById(role.getId());
            if (exist == null) {
                throw new BusinessException("角色不存在");
            }
            role.setRoleCode(exist.getRoleCode());
            role.setIsBuiltin(exist.getIsBuiltin());
            roleMapper.updateById(role);
        }
        return role;
    }

    public List<Long> roleMenuIds(Long roleId) {
        return rolePermMapper.selectList(new LambdaQueryWrapper<SysRolePermission>()
                        .eq(SysRolePermission::getRoleId, roleId))
                .stream().map(SysRolePermission::getMenuId).toList();
    }

    /** 角色授权保存（权限终审留痕：grantedBy 记录授权人） */
    @Transactional
    public void saveRoleMenus(Long roleId, List<Long> menuIds) {
        if (roleMapper.selectById(roleId) == null) {
            throw new BusinessException("角色不存在");
        }
        rolePermMapper.delete(new LambdaQueryWrapper<SysRolePermission>()
                .eq(SysRolePermission::getRoleId, roleId));
        if (menuIds != null) {
            for (Long menuId : menuIds) {
                SysRolePermission rp = new SysRolePermission();
                rp.setRoleId(roleId);
                rp.setMenuId(menuId);
                rp.setPermType("menu");
                rp.setDataScope(roleMapper.selectById(roleId).getRoleLevel() == 1 ? "all_platform" : "all_org");
                rp.setGrantedBy(UserContext.userId());
                rolePermMapper.insert(rp);
            }
        }
    }
}