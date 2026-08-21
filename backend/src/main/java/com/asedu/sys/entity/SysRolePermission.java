package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 角色权限表（三级颗粒度） —— 对应 db 表 sys_role_permission */
@Data
@TableName("sys_role_permission")
public class SysRolePermission implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long roleId;
    private Long menuId;
    private String permType;
    private String dataScope;
    private Long grantedBy;
    private LocalDateTime grantedAt;
}