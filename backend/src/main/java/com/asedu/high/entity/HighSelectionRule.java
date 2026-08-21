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

/** 新高考选科规则配置表 —— 对应 db 表 high_selection_rule */
@Data
@TableName("high_selection_rule")
public class HighSelectionRule implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long gradeId;
    private String ruleMode;
    private String validCombos;
    private Integer openStatus;
    private LocalDateTime selectStart;
    private LocalDateTime selectEnd;
    private Integer minStudents;
    private Integer reselectTimes;
    private Integer status;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}