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

/** 全局字典项表（学段差异化渲染） —— 对应 db 表 sys_dict_item */
@Data
@TableName("sys_dict_item")
public class SysDictItem implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String typeCode;
    private String itemCode;
    private String itemName;
    private String stage;
    private Integer sortNo;
    private String extraJson;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}