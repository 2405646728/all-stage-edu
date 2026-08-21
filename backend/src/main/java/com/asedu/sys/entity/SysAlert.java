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

/** 智能异常告警表 —— 对应 db 表 sys_alert */
@Data
@TableName("sys_alert")
public class SysAlert implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String alertLevel;
    private String alertType;
    private String moduleCode;
    private String title;
    private String content;
    private String traceText;
    private Long userId;
    private Long orgId;
    private Integer status;
    private Long handledBy;
    private LocalDateTime handledAt;
    private String handleRemark;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime occurredAt;
}