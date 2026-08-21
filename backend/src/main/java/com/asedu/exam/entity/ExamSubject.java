package com.asedu.exam.entity;

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

/** 考试科目配置表 —— 对应 db 表 exam_subject */
@Data
@TableName("exam_subject")
public class ExamSubject implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long examId;
    private String subjectCode;
    private BigDecimal fullScore;
    private BigDecimal weight;
    private LocalDate examDate;
}