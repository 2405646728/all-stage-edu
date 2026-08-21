package com.asedu.moral.entity;

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

/** 德育活动与社会实践表 —— 对应 db 表 moral_activity */
@Data
@TableName("moral_activity")
public class MoralActivity implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long classId;
    private String activityType;
    private String title;
    private String content;
    private String evidenceFile;
    private LocalDate activityDate;
    private String performance;
    private Long recorderId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}