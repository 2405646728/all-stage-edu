package com.asedu.kind.entity;

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

/** 每日餐食公示表 —— 对应 db 表 kind_meal */
@Data
@TableName("kind_meal")
public class KindMeal implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private LocalDate mealDate;
    private String mealType;
    private String menuContent;
    private String photo;
    private String nutritionNote;
    private String tabooNote;
    private Long publisherId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}