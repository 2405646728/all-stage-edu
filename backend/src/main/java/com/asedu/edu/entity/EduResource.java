package com.asedu.edu.entity;

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

/** 校本教学资源库表 —— 对应 db 表 edu_resource */
@Data
@TableName("edu_resource")
public class EduResource implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String resourceType;
    private String subjectCode;
    private Long gradeId;
    private Long classId;
    private Long termId;
    private String title;
    private String fileUrl;
    private String shareScope;
    private Long uploaderId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}