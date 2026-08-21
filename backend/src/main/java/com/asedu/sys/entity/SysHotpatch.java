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

/** 热补丁记录表 —— 对应 db 表 sys_hotpatch */
@Data
@TableName("sys_hotpatch")
public class SysHotpatch implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String patchCode;
    private String moduleCode;
    private String patchContent;
    private String fixDesc;
    private String compareBefore;
    private String compareAfter;
    private String status;
    private Long appliedBy;
    private LocalDateTime appliedAt;
    private LocalDateTime verifiedAt;
    private LocalDateTime rollbackAt;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}