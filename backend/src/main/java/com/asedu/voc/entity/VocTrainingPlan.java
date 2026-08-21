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

/** 实训计划表 —— 对应 db 表 voc_training_plan */
@Data
@TableName("voc_training_plan")
public class VocTrainingPlan implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long termId;
    private Long classId;
    private Long majorId;
    private String projectName;
    private String content;
    private Long teacherId;
    private Long siteId;
    private LocalDate startDate;
    private LocalDate endDate;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}