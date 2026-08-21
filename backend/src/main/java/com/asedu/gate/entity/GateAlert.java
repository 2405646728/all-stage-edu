package com.asedu.gate.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** 门禁安防预警表 —— 对应 db 表 gate_alert */
@Data
@TableName("gate_alert")
public class GateAlert implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long passRecordId;
    private String alertType;
    private String alertLevel;
    private String content;
    private String notifyTarget;
    private Integer status;
    private Long handledBy;
    private LocalDateTime handledAt;
    private String handleNote;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}