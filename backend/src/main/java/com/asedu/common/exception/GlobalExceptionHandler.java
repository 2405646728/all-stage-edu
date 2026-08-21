package com.asedu.common.exception;

import com.asedu.common.api.R;
import com.asedu.common.api.ResultCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public R<Void> handleBusiness(BusinessException e) {
        log.warn("业务异常: code={}, msg={}", e.getCode(), e.getMessage());
        return R.fail(e.getCode(), e.getMessage());
    }

    @ExceptionHandler({MethodArgumentNotValidException.class, BindException.class})
    public R<Void> handleValid(BindException e) {
        FieldError fe = e.getBindingResult().getFieldError();
        String msg = fe == null ? ResultCode.PARAM_ERROR.getMsg() : fe.getField() + " " + fe.getDefaultMessage();
        return R.fail(ResultCode.PARAM_ERROR.getCode(), msg);
    }

    @ExceptionHandler({HttpMessageNotReadableException.class, MissingServletRequestParameterException.class})
    public R<Void> handleParam(Exception e) {
        return R.fail(ResultCode.PARAM_ERROR.getCode(), "请求参数格式错误: " + e.getMessage());
    }

    @ExceptionHandler(BadCredentialsException.class)
    public R<Void> handleBadCredentials(BadCredentialsException e) {
        return R.fail(ResultCode.LOGIN_FAIL);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public R<Void> handleAccessDenied(AccessDeniedException e) {
        return R.fail(ResultCode.FORBIDDEN);
    }

    @ExceptionHandler(Exception.class)
    public R<Void> handleOther(Exception e) {
        log.error("系统异常", e);
        return R.fail(ResultCode.FAIL.getCode(), "系统繁忙，请稍后重试");
    }
}
