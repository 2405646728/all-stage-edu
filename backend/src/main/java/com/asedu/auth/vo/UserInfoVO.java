package com.asedu.auth.vo;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class UserInfoVO {

    private Long id;
    private String username;
    private String realName;
    private String userType;
    private Long orgId;
    private String orgName;
    private String stage;
    private Long campusId;
    private String avatar;
    private String phone;
    private String email;
    private Boolean mustChangePwd;
    private List<String> roles;
}
