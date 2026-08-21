package com.asedu.auth.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 邮箱推送一键开通表 —— 对应 db 表 auth_email_invite */
@Data
@TableName("auth_email_invite")
public class AuthEmailInvite implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long batchId;
    private Long orgId;
    private String email;
    private String realName;
    private String userType;
    private String scopeDesc;
    private String inviteToken;
    private String mailContent;
    private String status;
    private LocalDateTime pushAt;
    private LocalDateTime confirmAt;
    private Long userId;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}