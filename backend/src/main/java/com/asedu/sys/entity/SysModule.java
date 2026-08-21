package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 功能模块注册表（可插拔模块总清单） —— 对应 db 表 sys_module */
@Data
@TableName("sys_module")
public class SysModule implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String moduleCode;
    private String moduleName;
    private String stageScope;
    private Integer isPlugin;
    private Integer defaultOn;
    private Integer sortNo;
    private String description;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}