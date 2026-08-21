package com.asedu.high.entity;

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

/** 高考备考台账表 —— 对应 db 表 high_gaokao_prep */
@Data
@TableName("high_gaokao_prep")
public class HighGaokaoPrep implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long schoolYearId;
    private String prepPlan;
    private String targetSchool;
    private String aspirationType;
    private String volunteerInfo;
    private String registerQualify;
    private String graduateCreditCheck;
    private String mockSummary;
    private String prepStatus;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}