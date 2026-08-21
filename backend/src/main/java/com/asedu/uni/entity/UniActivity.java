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

/** 高校活动记录表 —— 对应 db 表 uni_activity */
@Data
@TableName("uni_activity")
public class UniActivity implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long clubId;
    private String activityType;
    private String title;
    private String content;
    private LocalDate activityDate;
    private String evidenceFile;
    private Long recorderId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}