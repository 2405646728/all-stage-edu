package com.asedu.sys.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 政务上报字段映射表 —— 对应 db 表 sys_gov_report_field */
@Data
@TableName("sys_gov_report_field")
public class SysGovReportField implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long templateId;
    private String sourceTable;
    private String sourceColumn;
    private String targetField;
    private String transformRule;
    private Integer sortNo;
}