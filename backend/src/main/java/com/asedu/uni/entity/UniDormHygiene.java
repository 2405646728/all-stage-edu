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

/** 宿舍卫生检查表 —— 对应 db 表 uni_dorm_hygiene */
@Data
@TableName("uni_dorm_hygiene")
public class UniDormHygiene implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long roomId;
    private LocalDate checkDate;
    private BigDecimal hygieneScore;
    private String violation;
    private String rectifyNote;
    private Long checkerId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}