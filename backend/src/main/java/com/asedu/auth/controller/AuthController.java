package com.asedu.auth.controller;

import com.asedu.auth.dto.LoginDTO;
import com.asedu.auth.service.AuthService;
import com.asedu.auth.vo.LoginVO;
import com.asedu.auth.vo.UserInfoVO;
import com.asedu.common.api.R;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /** 登录 */
    @PostMapping("/login")
    public R<LoginVO> login(@Valid @RequestBody LoginDTO dto) {
        return R.ok(authService.login(dto));
    }

    /** 当前登录用户信息 */
    @GetMapping("/me")
    public R<UserInfoVO> me() {
        return R.ok(authService.me());
    }

    /** 修改密码（首登强制改密/自主改密） */
    @PostMapping("/change-pwd")
    public R<Void> changePassword(@RequestBody com.asedu.auth.dto.ChangePwdDTO dto) {
        authService.changePassword(dto.getOldPassword(), dto.getNewPassword());
        return R.ok();
    }

    /** 登出 */
    @PostMapping("/logout")
    public R<Void> logout() {
        authService.logout();
        return R.ok();
    }
}