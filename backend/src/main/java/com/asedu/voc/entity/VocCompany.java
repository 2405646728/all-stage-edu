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

/** 校企合作单位备案表 —— 对应 db 表 voc_company */
@Data
@TableName("voc_company")
public class VocCompany implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String companyName;
    private String qualification;
    private String coopProject;
    private String postDesc;
    private String mentorName;
    private String mentorPhone;
    private LocalDate coopStart;
    private LocalDate coopEnd;
    private Integer status;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}