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

/** 门禁通行记录表（全量溯源） —— 对应 db 表 gate_pass_record */
@Data
@TableName("gate_pass_record")
public class GatePassRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String personType;
    private Long personId;
    private String personName;
    private Long deviceId;
    private String deviceName;
    private LocalDateTime passTime;
    private String direction;
    private String passWay;
    private String result;
    private String failReason;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}