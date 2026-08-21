package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 接口调用日志表 —— 对应 db 表 sys_log_api */
@Data
@TableName("sys_log_api")
public class SysLogApi implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String apiCode;
    private String apiPath;
    private String method;
    private Long orgId;
    private Long userId;
    private String requestParam;
    private Integer responseCode;
    private Integer costMs;
    private String ip;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime calledAt;
}