package com.asedu.base.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 学生健康档案表（隐私数据单独加密隔离）—— db 表 base_student_health */
@Data
@TableName("base_student_health")
public class BaseStudentHealth implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private String allergyHistory;
    private String diseaseHistory;
    private String surgeryHistory;
    private String constitutionNote;
    private String dietTaboo;
    private String sportTaboo;
    private String psychologyNote;
    private String sleepNote;
    private String trainingTaboo;
    private String bloodType;
    private BigDecimal heightCm;
    private BigDecimal weightKg;
    private Long updatedBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
