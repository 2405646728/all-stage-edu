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

/** 课堂教学纪实表 —— 对应 db 表 edu_teaching_record */
@Data
@TableName("edu_teaching_record")
public class EduTeachingRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long planId;
    private Long classId;
    private Long courseId;
    private Long teacherId;
    private LocalDate teachDate;
    private String content;
    private String classPerformance;
    private String attendanceNote;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}