package com.asedu.high.entity;

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

/** 普高毕业升学去向表 —— 对应 db 表 high_graduation_outcome */
@Data
@TableName("high_graduation_outcome")
public class HighGraduationOutcome implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Integer graduateYear;
    private BigDecimal gaokaoTotal;
    private Integer gaokaoRank;
    private String outcomeType;
    private String admittedSchool;
    private String admittedMajor;
    private String batchType;
    private String remark;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}