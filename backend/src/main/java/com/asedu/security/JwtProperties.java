package com.asedu.security;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * JWT 配置（application.yml: asedu.jwt）
 */
@Data
@ConfigurationProperties(prefix = "asedu.jwt")
public class JwtProperties {

    /** HS256 密钥 */
    private String secret;

    /** 有效期（秒） */
    private long expireSeconds = 7200;

    /** 请求头名称 */
    private String header = "Authorization";

    /** 前缀 */
    private String prefix = "Bearer ";
}
