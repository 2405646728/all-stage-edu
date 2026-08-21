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

/** 开课表 —— 对应 db 表 uni_course_offer */
@Data
@TableName("uni_course_offer")
public class UniCourseOffer implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long termId;
    private Long programCourseId;
    private String courseNo;
    private Long teacherId;
    private Integer capacity;
    private Integer selectedCount;
    private LocalDateTime selectStart;
    private LocalDateTime selectEnd;
    private Integer classHours;
    private String room;
    private String status;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}