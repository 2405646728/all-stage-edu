package com.asedu.auth.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户角色绑定表 —— 对应 db 表 auth_user_role
 */
@Data
@TableName("auth_user_role")
public class AuthUserRole implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;
    private Long roleId;
    private Long orgId;
    private Long scopeId;
    private Long grantedBy;
    private LocalDateTime grantedAt;
    private Integer status;
}
