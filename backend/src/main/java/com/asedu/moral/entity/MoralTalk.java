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

/** 学生谈心谈话心理跟进表 —— 对应 db 表 moral_talk */
@Data
@TableName("moral_talk")
public class MoralTalk implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private String talkType;
    private String talkContent;
    private String studentState;
    private String followPlan;
    private String improveNote;
    private Integer isKeyStudent;
    private Long talkerId;
    private LocalDateTime talkedAt;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}