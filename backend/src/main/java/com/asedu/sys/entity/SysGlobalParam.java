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

/** 全局底层参数配置表 —— 对应 db 表 sys_global_param */
@Data
@TableName("sys_global_param")
public class SysGlobalParam implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String paramGroup;
    private String paramKey;
    private String paramValue;
    private String valueType;
    private Integer isPlatformOnly;
    private String description;
    private Long updatedBy;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}