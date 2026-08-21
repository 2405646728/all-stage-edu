package com.asedu.auth.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 账号批量开通批次表 —— 对应 db 表 auth_open_batch */
@Data
@TableName("auth_open_batch")
public class AuthOpenBatch implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String batchNo;
    private String openMode;
    private Integer totalCount;
    private Integer successCount;
    private Integer failCount;
    private String status;
    private String errorFile;
    private Long revokedBy;
    private LocalDateTime revokedAt;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}