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

/** 学生选课表 —— 对应 db 表 uni_course_select */
@Data
@TableName("uni_course_select")
public class UniCourseSelect implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long offerId;
    private Long termId;
    private String selectStatus;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime selectTime;
    private LocalDateTime dropTime;
    private Long operatorId;
}