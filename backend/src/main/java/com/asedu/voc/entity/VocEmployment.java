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

/** 职高毕业就业台账表 —— 对应 db 表 voc_employment */
@Data
@TableName("voc_employment")
public class VocEmployment implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Integer graduateYear;
    private String outcomeType;
    private String companyName;
    private String postName;
    private String majorMatch;
    private String furtherSchool;
    private String salaryRange;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}