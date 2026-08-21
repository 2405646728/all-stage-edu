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

/** 校园活动记录表 —— 对应 db 表 kind_activity_record */
@Data
@TableName("kind_activity_record")
public class KindActivityRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long classId;
    private String activityType;
    private String title;
    private String content;
    private String mediaFiles;
    private LocalDate activityDate;
    private Long publisherId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}