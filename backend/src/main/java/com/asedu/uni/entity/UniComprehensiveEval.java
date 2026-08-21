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

/** 高校综合素质测评表 —— 对应 db 表 uni_comprehensive_eval */
@Data
@TableName("uni_comprehensive_eval")
public class UniComprehensiveEval implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long schoolYearId;
    private BigDecimal studyScore;
    private BigDecimal moralScore;
    private BigDecimal innovationScore;
    private BigDecimal sportScore;
    private BigDecimal volunteerScore;
    private BigDecimal practiceScore;
    private BigDecimal totalScore;
    private Integer rankNo;
    private String auditStatus;
    private Long auditBy;
    private LocalDateTime auditAt;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}