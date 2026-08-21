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

/** 通知推送范围表 —— 对应 db 表 msg_notice_scope */
@Data
@TableName("msg_notice_scope")
public class MsgNoticeScope implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long noticeId;
    private Long classId;
    private Long userId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}