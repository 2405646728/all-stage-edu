package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** API接入密钥表 —— 对应 db 表 sys_api_secret */
@Data
@TableName("sys_api_secret")
public class SysApiSecret implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long apiId;
    private String appName;
    private String appKey;
    private String appSecret;
    private Integer status;
    private String whitelistIp;
    private LocalDateTime expireAt;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}