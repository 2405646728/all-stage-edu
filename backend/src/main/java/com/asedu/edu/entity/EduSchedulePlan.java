package com.asedu.edu.entity;

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

/** 课表条目表 —— 对应 db 表 edu_schedule_plan */
@Data
@TableName("edu_schedule_plan")
public class EduSchedulePlan implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long termId;
    private Long classId;
    private Long courseId;
    private Long teacherId;
    private String room;
    private Integer weekday;
    private Integer sectionNo;
    private Integer startWeek;
    private Integer endWeek;
    private String scheduleType;
    private Long originPlanId;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}