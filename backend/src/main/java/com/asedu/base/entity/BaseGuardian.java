package com.asedu.base.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 监护人表 —— db 表 base_guardian */
@Data
@TableName("base_guardian")
public class BaseGuardian implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String name;
    private String phone;
    /** father父亲/mother母亲/grandfather祖父/grandmother祖母/other其他 */
    private String relation;
    private Integer isEmergency;
    private String workInfo;
    /** 证件号（应用层加密存储） */
    private String idCard;
    /** 人脸特征值（密文存储） */
    private String faceFeature;
    private Long userId;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
    @TableLogic
    private Integer isDeleted;
}
