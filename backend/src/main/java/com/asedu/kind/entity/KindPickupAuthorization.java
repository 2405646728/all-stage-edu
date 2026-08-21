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

/** 幼儿接送授权表（固定/临时接送白名单） —— 对应 db 表 kind_pickup_authorization */
@Data
@TableName("kind_pickup_authorization")
public class KindPickupAuthorization implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long guardianId;
    private String pickupType;
    private String tempName;
    private String tempPhone;
    private String tempIdCard;
    private String tempPhoto;
    private LocalDateTime validFrom;
    private LocalDateTime validUntil;
    private Long applyBy;
    private String approveStatus;
    private Long approveBy;
    private LocalDateTime approveAt;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}