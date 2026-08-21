package com.asedu.security;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;

/**
 * 登录用户信息（JWT claims + 上下文载体）
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginUser implements Serializable {

    private Long id;
    private String username;
    private String realName;
    private String userType;      // super_admin/school_admin/teacher/staff/student/parent/visitor
    private Long orgId;
    private String stage;         // 学段（机构判定，超管为 null）
    private Long campusId;
    private Boolean mustChangePwd;
    private List<String> roles;   // 角色编码
}
