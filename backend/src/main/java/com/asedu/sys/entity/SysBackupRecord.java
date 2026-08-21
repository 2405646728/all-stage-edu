package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 数据备份与恢复记录表 —— 对应 db 表 sys_backup_record */
@Data
@TableName("sys_backup_record")
public class SysBackupRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String backupType;
    private String backupMode;
    private String targetDesc;
    private String filePath;
    private Long fileSize;
    private String status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime startedAt;
    private LocalDateTime finishedAt;
    private LocalDateTime restoredAt;
    private Long operatorId;
    private String remark;
}