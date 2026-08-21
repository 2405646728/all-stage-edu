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

/** 幼儿午休记录表 —— 对应 db 表 kind_nap_record */
@Data
@TableName("kind_nap_record")
public class KindNapRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private LocalDate napDate;
    private Integer sleepMinutes;
    private String napStatus;
    private String performance;
    private Long recorderId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}