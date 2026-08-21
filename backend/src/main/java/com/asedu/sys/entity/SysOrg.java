package com.asedu.sys.entity;

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

/**
 * 平台入驻机构表（学段判定唯一依据，单机构固定单学段）—— 对应 db 表 sys_org
 */
@Data
@TableName("sys_org")
public class SysOrg implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String orgCode;
    private String orgName;
    /** 学段：kindergarten/primary/junior/senior/vocational/university */
    private String stage;
    private String schoolType;
    private String province;
    private String city;
    private String district;
    private String address;
    private String legalPerson;
    private String contactName;
    private String contactPhone;
    /** 0待审核/1正常/2禁用/3注销 */
    private Integer status;
    private LocalDate serviceStart;
    private LocalDate serviceEnd;
    private String auditRemark;
    private Long auditBy;
    private LocalDateTime auditAt;
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
