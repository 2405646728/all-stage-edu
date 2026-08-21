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

/** 顶岗实习打卡表 —— 对应 db 表 voc_internship_checkin */
@Data
@TableName("voc_internship_checkin")
public class VocInternshipCheckin implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long internshipId;
    private LocalDate checkinDate;
    private LocalDateTime checkinTime;
    private String location;
    private String checkinWay;
    private String status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}