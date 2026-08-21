package com.asedu.common.api;

import lombok.Getter;

/**
 * 统一返回码（与前端约定）
 */
@Getter
public enum ResultCode {

    SUCCESS(200, "操作成功"),
    FAIL(500, "操作失败"),
    UNAUTHORIZED(401, "未登录或登录已过期"),
    FORBIDDEN(403, "无权限访问"),
    NOT_FOUND(404, "资源不存在"),
    PARAM_ERROR(400, "参数错误"),
    LOGIN_FAIL(1001, "账号或密码错误"),
    ACCOUNT_DISABLED(1002, "账号已被冻结"),
    ACCOUNT_UNACTIVATED(1003, "账号未激活"),
    MUST_CHANGE_PWD(1004, "首次登录必须修改密码"),
    ORG_DISABLED(1101, "机构已停用或服务过期");

    private final int code;
    private final String msg;

    ResultCode(int code, String msg) {
        this.code = code;
        this.msg = msg;
    }
}
