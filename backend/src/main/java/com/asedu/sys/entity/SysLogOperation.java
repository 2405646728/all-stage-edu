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

/** 全量操作日志表 —— 对应 db 表 sys_log_operation */
@Data
@TableName("sys_log_operation")
public class SysLogOperation implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String username;
    private Long orgId;
    private String bizType;
    private String action;
    private String targetTable;
    private Long targetId;
    private String detailBefore;
    private String detailAfter;
    private String ip;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime operatedAt;
}