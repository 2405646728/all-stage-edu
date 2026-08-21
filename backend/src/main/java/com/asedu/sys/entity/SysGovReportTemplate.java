package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 政务数据上报模板表 —— 对应 db 表 sys_gov_report_template */
@Data
@TableName("sys_gov_report_template")
public class SysGovReportTemplate implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String templateCode;
    private String templateName;
    private String target;
    private String stageScope;
    private String reportFrequency;
    private String templateJson;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}