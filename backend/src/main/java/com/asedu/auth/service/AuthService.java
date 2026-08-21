package com.asedu.auth.service;

import com.asedu.auth.dto.LoginDTO;
import com.asedu.auth.entity.AuthUser;
import com.asedu.auth.entity.AuthUserRole;
import com.asedu.auth.mapper.AuthUserMapper;
import com.asedu.auth.mapper.AuthUserRoleMapper;
import com.asedu.auth.vo.LoginVO;
import com.asedu.auth.vo.UserInfoVO;
import com.asedu.common.api.ResultCode;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.JwtProperties;
import com.asedu.security.JwtUtil;
import com.asedu.security.LoginUser;
import com.asedu.security.UserContext;
import com.asedu.sys.entity.SysOrg;
import com.asedu.sys.entity.SysRole;
import com.asedu.sys.mapper.SysOrgMapper;
import com.asedu.sys.mapper.SysRoleMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * 认证服务：登录/当前用户/登出（会话 Redis 存储，与 sys_global_param.token_expire_minutes 对齐）
 */
@Service
@RequiredArgsConstructor
public class AuthService {

    private static final String TOKEN_KEY_PREFIX = "asedu:token:";

    private final AuthUserMapper authUserMapper;
    private final AuthUserRoleMapper authUserRoleMapper;
    private final SysRoleMapper sysRoleMapper;
    private final SysOrgMapper sysOrgMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final JwtProperties jwtProperties;
    private final RedisTemplate<String, Object> redisTemplate;

    public LoginVO login(LoginDTO dto) {
        // 输入加固：去除首尾空格（避免复制粘贴带入空格导致登录失败）
        String username = dto.getUsername() == null ? "" : dto.getUsername().trim();
        String password = dto.getPassword() == null ? "" : dto.getPassword().trim();
        AuthUser user = authUserMapper.selectOne(new LambdaQueryWrapper<AuthUser>()
                .eq(AuthUser::getUsername, username)
                .eq(AuthUser::getIsDeleted, 0));
        if (user == null || !passwordEncoder.matches(password, user.getPasswordHash())) {
            // 占位密码未初始化亦视为登录失败
            throw new BusinessException(ResultCode.LOGIN_FAIL);
        }
        checkStatus(user);

        // 角色
        List<String> roles = loadRoles(user.getId());
        // 机构信息（平台超管无机构）
        SysOrg org = user.getOrgId() == null ? null : sysOrgMapper.selectById(user.getOrgId());
        if (org != null && org.getStatus() != null && org.getStatus() != 1) {
            throw new BusinessException(ResultCode.ORG_DISABLED);
        }

        LoginUser loginUser = new LoginUser(
                user.getId(), user.getUsername(), user.getRealName(), user.getUserType(),
                user.getOrgId(), user.getStage(), user.getCampusId(),
                user.getMustChangePwd() != null && user.getMustChangePwd() == 1, roles);
        String token = jwtUtil.generate(loginUser);

        // Redis 会话（单端登录：同用户新登录覆盖旧 token）
        redisTemplate.opsForValue().set(TOKEN_KEY_PREFIX + user.getId(), token,
                jwtProperties.getExpireSeconds(), TimeUnit.SECONDS);

        // 更新最近登录时间
        AuthUser update = new AuthUser();
        update.setId(user.getId());
        update.setLastLoginAt(LocalDateTime.now());
        update.setLoginFailCount(0);
        authUserMapper.updateById(update);

        return LoginVO.builder()
                .token(token)
                .user(toUserInfoVO(user, org, roles))
                .build();
    }

    public UserInfoVO me() {
        LoginUser lu = UserContext.get();
        if (lu == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED);
        }
        AuthUser user = authUserMapper.selectById(lu.getId());
        SysOrg org = user.getOrgId() == null ? null : sysOrgMapper.selectById(user.getOrgId());
        return toUserInfoVO(user, org, lu.getRoles());
    }

    /** 修改密码（首登强制改密 + 自主改密；校验旧密码与新密码复杂度） */
    @org.springframework.transaction.annotation.Transactional
    public void changePassword(String oldPassword, String newPassword) {
        LoginUser lu = UserContext.get();
        if (lu == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED);
        }
        AuthUser user = authUserMapper.selectById(lu.getId());
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        if (oldPassword == null || oldPassword.isBlank()
                || !passwordEncoder.matches(oldPassword.trim(), user.getPasswordHash())) {
            throw new BusinessException("原密码不正确");
        }
        if (newPassword == null || newPassword.trim().length() < 8) {
            throw new BusinessException("新密码长度不能少于8位");
        }
        if (newPassword.trim().equals(oldPassword.trim())) {
            throw new BusinessException("新密码不能与原密码相同");
        }
        AuthUser update = new AuthUser();
        update.setId(user.getId());
        update.setPasswordHash(passwordEncoder.encode(newPassword.trim()));
        update.setMustChangePwd(0);
        update.setPwdUpdatedAt(LocalDateTime.now());
        authUserMapper.updateById(update);
        // 改密后踢出旧会话，强制重新登录
        redisTemplate.delete(TOKEN_KEY_PREFIX + user.getId());
    }

    public void logout() {
        LoginUser lu = UserContext.get();
        if (lu != null) {
            redisTemplate.delete(TOKEN_KEY_PREFIX + lu.getId());
        }
    }

    private void checkStatus(AuthUser user) {
        if (user.getStatus() == null || user.getStatus() == 0) {
            throw new BusinessException(ResultCode.ACCOUNT_DISABLED);
        }
        if (user.getStatus() == 2) {
            throw new BusinessException(ResultCode.ACCOUNT_UNACTIVATED);
        }
        if (user.getStatus() == 3) {
            throw new BusinessException(ResultCode.ACCOUNT_DISABLED);
        }
    }

    private List<String> loadRoles(Long userId) {
        List<Long> roleIds = authUserRoleMapper.selectList(
                        new LambdaQueryWrapper<AuthUserRole>()
                                .eq(AuthUserRole::getUserId, userId)
                                .eq(AuthUserRole::getStatus, 1))
                .stream().map(AuthUserRole::getRoleId).toList();
        if (roleIds.isEmpty()) {
            return List.of();
        }
        return sysRoleMapper.selectBatchIds(roleIds).stream().map(SysRole::getRoleCode).toList();
    }

    private UserInfoVO toUserInfoVO(AuthUser user, SysOrg org, List<String> roles) {
        return UserInfoVO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .realName(user.getRealName())
                .userType(user.getUserType())
                .orgId(user.getOrgId())
                .orgName(org == null ? null : org.getOrgName())
                .stage(user.getStage())
                .campusId(user.getCampusId())
                .avatar(user.getAvatar())
                .phone(user.getPhone())
                .email(user.getEmail())
                .mustChangePwd(user.getMustChangePwd() != null && user.getMustChangePwd() == 1)
                .roles(roles)
                .build();
    }
}