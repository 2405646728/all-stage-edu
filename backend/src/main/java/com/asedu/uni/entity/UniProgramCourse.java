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

/** 培养方案课程表 —— 对应 db 表 uni_program_course */
@Data
@TableName("uni_program_course")
public class UniProgramCourse implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long programId;
    private String courseCode;
    private String courseName;
    private String courseType;
    private BigDecimal credit;
    private Integer requiredFlag;
    private Integer advisedTerm;
}