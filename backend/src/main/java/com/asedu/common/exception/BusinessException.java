package com.asedu.common.exception;

import com.asedu.common.api.ResultCode;
import lombok.Getter;

/**
 * 业务异常
 */
@Getter
public class BusinessException extends RuntimeException {

    private final int code;

    public BusinessException(String message) {
        super(message);
        this.code = ResultCode.FAIL.getCode();
    }

    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }

    public BusinessException(ResultCode rc) {
        super(rc.getMsg());
        this.code = rc.getCode();
    }
}
