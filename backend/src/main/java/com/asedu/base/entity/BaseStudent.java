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

/** 学生主档表（全学段统一底座）—— db 表 base_student */
@Data
@TableName("base_student")
public class BaseStudent implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long campusId;
    private String stage;
    /** 学号/园号（机构内唯一） */
    private String studentNo;
    private Long userId;
    private String name;
    /** 0未知/1男/2女 */
    private Integer gender;
    private LocalDate birthDate;
    /** 身份证号（应用层加密存储） */
    private String idCard;
    private String nation;
    private String nativePlace;
    private String household;
    private String address;
    private String photo;
    private LocalDate admitDate;
    private String admitBatch;
    /** normal在读/suspended休学/left离园(校)/graduated毕业/withdrawn退学 */
    private String studyStatus;
    /** 0走读/1寄宿 */
    private Integer boarder;
    private Long currentClassId;
    private String specialNote;
    private String sourceDesc;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    private Long updatedBy;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
    @TableLogic
    private Integer isDeleted;
    private LocalDateTime deletedAt;
}
