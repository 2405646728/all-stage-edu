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

/** 校园安全巡查隐患整改表 —— 对应 db 表 kind_safety_inspect */
@Data
@TableName("kind_safety_inspect")
public class KindSafetyInspect implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String inspectType;
    private String hazardDesc;
    private String location;
    private String riskLevel;
    private Long rectifyOwnerId;
    private LocalDate rectifyDeadline;
    private String rectifyEvidence;
    private String status;
    private Long reviewBy;
    private LocalDateTime reviewAt;
    private Long reporterId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}