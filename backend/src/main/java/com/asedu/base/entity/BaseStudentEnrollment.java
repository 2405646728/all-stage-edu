package com.asedu.base.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** 学籍表 —— db 表 base_student_enrollment */
@Data
@TableName("base_student_enrollment")
public class BaseStudentEnrollment implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    /** 学籍号（全局唯一） */
    private String enrollNo;
    private String stage;
    private Integer schoolingYears;
    private LocalDate enrollDate;
    private String enrollBatch;
    private Long currentGradeId;
    private Long currentClassId;
    /** normal在读/在园/suspended休学/transferred_out转出/graduated毕业/withdrawn退学/deregistered注销 */
    private String enrollStatus;
    private LocalDate graduateAt;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
