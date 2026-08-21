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

/** 系统版本迭代表 —— 对应 db 表 sys_version */
@Data
@TableName("sys_version")
public class SysVersion implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String versionNo;
    private String versionName;
    private String releaseNote;
    private Integer isHotpatch;
    private String releaseType;
    private String status;
    private Long publishedBy;
    private LocalDateTime publishedAt;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}