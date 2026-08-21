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

/** 高校学业预警表 —— 对应 db 表 uni_academic_warning */
@Data
@TableName("uni_academic_warning")
public class UniAcademicWarning implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long termId;
    private String warningType;
    private String warningLevel;
    private String content;
    private Long counselorId;
    private Integer status;
    private String handleNote;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}