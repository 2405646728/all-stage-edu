package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/** 菜单/权限点表（菜单+按钮权限） —— 对应 db 表 sys_menu */
@Data
@TableName("sys_menu")
public class SysMenu implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long parentId;
    private String menuCode;
    private String menuName;
    private String menuType;
    private String stageScope;
    private String routePath;
    private Integer sortNo;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    /** 子菜单（树形结构，非表字段） */
    @TableField(exist = false)
    private List<SysMenu> children;
}