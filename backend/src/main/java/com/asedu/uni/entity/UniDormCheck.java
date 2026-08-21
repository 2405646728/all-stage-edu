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

/** 宿舍查寝考勤表 —— 对应 db 表 uni_dorm_check */
@Data
@TableName("uni_dorm_check")
public class UniDormCheck implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long roomId;
    private LocalDate checkDate;
    private String checkType;
    private String status;
    private String note;
    private Integer isAlert;
    private Long checkerId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}