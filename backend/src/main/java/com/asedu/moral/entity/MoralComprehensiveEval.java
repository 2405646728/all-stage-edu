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

/** 学生综合素质评价表 —— 对应 db 表 moral_comprehensive_eval */
@Data
@TableName("moral_comprehensive_eval")
public class MoralComprehensiveEval implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long termId;
    private String evalStandard;
    private BigDecimal moralityScore;
    private BigDecimal studyScore;
    private BigDecimal healthScore;
    private BigDecimal artScore;
    private BigDecimal practiceScore;
    private BigDecimal extraScore;
    private BigDecimal totalScore;
    private String comment;
    private String evalStatus;
    private Long evaluatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}