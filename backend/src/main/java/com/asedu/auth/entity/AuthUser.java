package com.asedu.auth.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 全平台用户账号表 —— 对应 db 表 auth_user
 */
@Data
@TableName("auth_user")
public class AuthUser implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;
    private String passwordHash;
    private String realName;
    /** super_admin/school_admin/teacher/staff/student/parent/visitor */
    private String userType;
    private Long orgId;
    private Long campusId;
    private String stage;
    private Integer gender;
    private String idCard;
    private String phone;
    private String email;
    private String avatar;
    /** 0冻结/1正常/2未激活(待邮箱确认)/3锁定 */
    private Integer status;
    private Integer mustChangePwd;
    private LocalDateTime pwdUpdatedAt;
    private LocalDateTime lastLoginAt;
    private Integer loginFailCount;
    private LocalDateTime lockedUntil;
    private String openChannel;
    private Long openBatchId;
    private String remark;
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
