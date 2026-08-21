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

/** 教职工表 —— db 表 base_teacher */
@Data
@TableName("base_teacher")
public class BaseTeacher implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long campusId;
    private String stage;
    /** 工号（机构内唯一） */
    private String staffNo;
    private Long userId;
    private String name;
    private Integer gender;
    private String phone;
    private String idCard;
    private String education;
    private String title;
    private LocalDate hireDate;
    /** active在职/leave休假/resigned离职/retired退休 */
    private String workStatus;
    /** internal校内/external校外 */
    private String externalType;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
    @TableLogic
    private Integer isDeleted;
}
