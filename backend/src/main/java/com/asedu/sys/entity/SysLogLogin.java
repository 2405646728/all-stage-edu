package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 登录日志表 —— 对应 db 表 sys_log_login */
@Data
@TableName("sys_log_login")
public class SysLogLogin implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String username;
    private Long orgId;
    private String loginType;
    private Integer loginResult;
    private String failReason;
    private String ip;
    private String userAgent;
    private String deviceInfo;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime loginAt;
}