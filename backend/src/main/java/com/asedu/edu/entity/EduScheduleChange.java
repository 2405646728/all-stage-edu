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

/** 调课代课补课登记表 —— 对应 db 表 edu_schedule_change */
@Data
@TableName("edu_schedule_change")
public class EduScheduleChange implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String changeType;
    private Long planId;
    private Integer fromWeekday;
    private Integer fromSection;
    private LocalDate toDate;
    private Integer toWeekday;
    private Integer toSection;
    private String reason;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}