package com.asedu.msg.entity;

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

/** 一对一消息表 —— 对应 db 表 msg_message */
@Data
@TableName("msg_message")
public class MsgMessage implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long senderId;
    private Long receiverId;
    private Long studentId;
    private String msgType;
    private String content;
    private String fileUrl;
    private Integer isRead;
    private LocalDateTime readAt;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}