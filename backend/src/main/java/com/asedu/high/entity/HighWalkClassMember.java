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

/** 走班教学班成员表 —— 对应 db 表 high_walk_class_member */
@Data
@TableName("high_walk_class_member")
public class HighWalkClassMember implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long walkClassId;
    private Long studentId;
    private String subjectCode;
    private Long termId;
    private Integer status;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}