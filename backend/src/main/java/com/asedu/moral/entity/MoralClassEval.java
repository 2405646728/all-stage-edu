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

/** 班级量化考核表 —— 对应 db 表 moral_class_eval */
@Data
@TableName("moral_class_eval")
public class MoralClassEval implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long classId;
    private String evalPeriod;
    private LocalDate periodStart;
    private LocalDate periodEnd;
    private BigDecimal disciplineScore;
    private BigDecimal hygieneScore;
    private BigDecimal attendanceScore;
    private BigDecimal activityScore;
    private BigDecimal studyStyleScore;
    private BigDecimal totalScore;
    private Integer rankNo;
    private String remark;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}