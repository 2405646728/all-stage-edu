package com.asedu.voc.entity;

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

/** 实习周报月报表 —— 对应 db 表 voc_internship_report */
@Data
@TableName("voc_internship_report")
public class VocInternshipReport implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long internshipId;
    private String reportType;
    private String reportPeriod;
    private String content;
    private Long reviewerId;
    private String reviewNote;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime submittedAt;
}