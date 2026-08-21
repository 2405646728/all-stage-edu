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

/** 晨检午检体温监测表 —— 对应 db 表 kind_health_check */
@Data
@TableName("kind_health_check")
public class KindHealthCheck implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private LocalDate checkDate;
    private String checkType;
    private BigDecimal temperature;
    private String mentalState;
    private String hygiene;
    private String symptom;
    private Integer isAbnormal;
    private Long recorderId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}