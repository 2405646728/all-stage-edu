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

/** 通知已读回执表 —— 对应 db 表 msg_notice_read */
@Data
@TableName("msg_notice_read")
public class MsgNoticeRead implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long noticeId;
    private Long userId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime readAt;
}