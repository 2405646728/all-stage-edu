package com.asedu.att.entity;

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

/** 学生考勤明细表（刷卡/刷脸/人工补录） —— 对应 db 表 att_student_record */
@Data
@TableName("att_student_record")
public class AttStudentRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long classId;
    private LocalDate attDate;
    private String attendScene;
    private LocalDateTime signInTime;
    private LocalDateTime signOutTime;
    private Integer stayMinutes;
    private String signInWay;
    private String signOutWay;
    private Long deviceId;
    private String deviceName;
    private String location;
    private String status;
    private String remark;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}