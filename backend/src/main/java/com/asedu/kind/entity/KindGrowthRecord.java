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

/** 幼儿成长动态表 —— 对应 db 表 kind_growth_record */
@Data
@TableName("kind_growth_record")
public class KindGrowthRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long classId;
    private String recordType;
    private String title;
    private String content;
    private String mediaFiles;
    private Long publisherId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}