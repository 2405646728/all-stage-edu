package com.asedu.common.api;

import lombok.Data;

import java.io.Serializable;

/**
 * 统一响应结构
 */
@Data
public class R<T> implements Serializable {

    private int code;
    private String msg;
    private T data;

    public static <T> R<T> ok() {
        return build(ResultCode.SUCCESS.getCode(), ResultCode.SUCCESS.getMsg(), null);
    }

    public static <T> R<T> ok(T data) {
        return build(ResultCode.SUCCESS.getCode(), ResultCode.SUCCESS.getMsg(), data);
    }

    public static <T> R<T> fail(String msg) {
        return build(ResultCode.FAIL.getCode(), msg, null);
    }

    public static <T> R<T> fail(ResultCode rc) {
        return build(rc.getCode(), rc.getMsg(), null);
    }

    public static <T> R<T> fail(int code, String msg) {
        return build(code, msg, null);
    }

    public static <T> R<T> build(int code, String msg, T data) {
        R<T> r = new R<>();
        r.setCode(code);
        r.setMsg(msg);
        r.setData(data);
        return r;
    }
}
