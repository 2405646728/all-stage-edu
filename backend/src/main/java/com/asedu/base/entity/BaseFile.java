package com.asedu.base.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 统一文件库表 —— db 表 base_file */
@Data
@TableName("base_file")
public class BaseFile implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String bizType;
    private Long bizId;
    private String fileName;
    private String filePath;
    private Long fileSize;
    private String mimeType;
    private Long uploaderId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
