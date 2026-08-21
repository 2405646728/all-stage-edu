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

/** 考试成绩表 —— 对应 db 表 exam_score */
@Data
@TableName("exam_score")
public class ExamScore implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long examId;
    private Long examSubjectId;
    private Long studentId;
    private Long classId;
    private BigDecimal score;
    private String gradeLevel;
    private Integer classRank;
    private Integer gradeRank;
    private Integer isAbsent;
    private String remark;
    private Long entryBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}