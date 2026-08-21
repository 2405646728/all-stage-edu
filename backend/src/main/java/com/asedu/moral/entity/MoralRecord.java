package com.asedu.moral.entity;

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

/** 日常德育奖惩登记表 —— 对应 db 表 moral_record */
@Data
@TableName("moral_record")
public class MoralRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long classId;
    private String recordType;
    private String dimension;
    private BigDecimal score;
    private String reason;
    private String evidenceFile;
    private String handleResult;
    private String punishLevel;
    private Integer revokeStatus;
    private LocalDateTime revokeAt;
    private Long recorderId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime occurredAt;
}