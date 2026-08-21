package com.asedu.uni.entity;

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

/** 高校课程成绩表 —— 对应 db 表 uni_score */
@Data
@TableName("uni_score")
public class UniScore implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long offerId;
    private Long termId;
    private BigDecimal usualScore;
    private BigDecimal examScore;
    private BigDecimal practiceScore;
    private BigDecimal totalScore;
    private BigDecimal gradePoint;
    private BigDecimal credit;
    private String status;
    private String reviewStatus;
    private Long entryBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}