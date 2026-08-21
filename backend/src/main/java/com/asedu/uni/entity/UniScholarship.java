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

/** 奖学金评优表 —— 对应 db 表 uni_scholarship */
@Data
@TableName("uni_scholarship")
public class UniScholarship implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String projectName;
    private String projectLevel;
    private Long studentId;
    private Long schoolYearId;
    private BigDecimal amount;
    private String awardFile;
    private String status;
    private LocalDateTime publicAt;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}