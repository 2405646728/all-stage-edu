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

/** 学生选科表 —— 对应 db 表 high_selection_choice */
@Data
@TableName("high_selection_choice")
public class HighSelectionChoice implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long ruleId;
    private String comboCode;
    private String comboDetail;
    private Integer choiceRound;
    private String status;
    private Long auditBy;
    private LocalDateTime auditAt;
    private String auditRemark;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}