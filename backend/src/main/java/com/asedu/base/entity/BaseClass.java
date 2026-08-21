package com.asedu.base.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** 班级表（行政班/教学班/分层班/实训班）—— db 表 base_class */
@Data
@TableName("base_class")
public class BaseClass implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long campusId;
    private String stage;
    private Long gradeId;
    private Long departmentId;
    private Long majorId;
    private String className;
    /** normal行政班/walk走班教学班/tier分层班/training实训班 */
    private String classType;
    private Integer classCapacity;
    private LocalDate openDate;
    /** 0归档(闲置班级)/1启用 */
    private Integer status;
    private Integer sortNo;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
    @TableLogic
    private Integer isDeleted;
}
