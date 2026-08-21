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

/** 推送日志表 —— 对应 db 表 msg_push_log */
@Data
@TableName("msg_push_log")
public class MsgPushLog implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String templateCode;
    private String channel;
    private String bizType;
    private Long bizId;
    private Long receiverId;
    private String receiverDesc;
    private String title;
    private String content;
    private String status;
    private String failReason;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime sentAt;
}