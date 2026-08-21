package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 统一API网关接口表 —— 对应 db 表 sys_api_gateway */
@Data
@TableName("sys_api_gateway")
public class SysApiGateway implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String apiCode;
    private String apiName;
    private String apiPath;
    private String apiMethod;
    private Integer status;
    private Integer rateLimit;
    private Integer needSign;
    private String description;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}