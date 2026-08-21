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

/** 课程体系配置表 —— 对应 db 表 edu_course */
@Data
@TableName("edu_course")
public class EduCourse implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String stage;
    private Long gradeId;
    private String subjectCode;
    private String courseName;
    private String courseType;
    private Integer periodsWeek;
    private BigDecimal credit;
    private String assessWay;
    private Long termId;
    private Integer status;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}