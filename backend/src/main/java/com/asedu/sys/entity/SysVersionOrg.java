package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 版本机构灰度发布表 —— 对应 db 表 sys_version_org */
@Data
@TableName("sys_version_org")
public class SysVersionOrg implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long versionId;
    private Long orgId;
    private String grayStatus;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}