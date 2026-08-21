package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 角色表（金字塔六级角色权限体系）—— 对应 db 表 sys_role
 */
@Data
@TableName("sys_role")
public class SysRole implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String roleCode;
    private String roleName;
    /** 1超级开发者管理员/2学校校级管理员/3教职工班主任/4学生/5家长/6访客 */
    private Integer roleLevel;
    private Integer isBuiltin;
    private String scope;
    private String description;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
