package com.asedu.auth.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 账号批量开通明细表 —— 对应 db 表 auth_open_item */
@Data
@TableName("auth_open_item")
public class AuthOpenItem implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long batchId;
    private Integer rowNo;
    private String username;
    private String realName;
    private String userType;
    private Long orgId;
    private String scopeDesc;
    private String phone;
    private String email;
    private String rawData;
    private String result;
    private String failReason;
    private Long userId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}