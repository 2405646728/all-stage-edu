package com.asedu.kind.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** 幼儿接送记录表（全量溯源+安全预警） —— 对应 db 表 kind_pickup_record */
@Data
@TableName("kind_pickup_record")
public class KindPickupRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long guardianId;
    private Long authId;
    private String pickupName;
    private LocalDateTime pickupTime;
    private String direction;
    private String verifyWay;
    private String verifyResult;
    private Long deviceId;
    private Integer isAlert;
    private String alertNote;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}