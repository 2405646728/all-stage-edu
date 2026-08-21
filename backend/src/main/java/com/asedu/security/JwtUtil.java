package com.asedu.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.List;

/**
 * JWT 工具（HS256）
 */
@Component
public class JwtUtil {

    private final JwtProperties props;
    private final SecretKey key;

    public JwtUtil(JwtProperties props) {
        this.props = props;
        this.key = Keys.hmacShaKeyFor(props.getSecret().getBytes(StandardCharsets.UTF_8));
    }

    public String generate(LoginUser user) {
        long now = System.currentTimeMillis();
        return Jwts.builder()
                .subject(String.valueOf(user.getId()))
                .claim("username", user.getUsername())
                .claim("realName", user.getRealName())
                .claim("userType", user.getUserType())
                .claim("orgId", user.getOrgId())
                .claim("stage", user.getStage())
                .claim("campusId", user.getCampusId())
                .claim("mustChangePwd", user.getMustChangePwd())
                .claim("roles", user.getRoles() == null ? List.of() : user.getRoles())
                .issuedAt(new Date(now))
                .expiration(new Date(now + props.getExpireSeconds() * 1000))
                .signWith(key)
                .compact();
    }

    public Claims parse(String token) {
        return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
    }

    public boolean validate(String token) {
        try {
            parse(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public LoginUser toLoginUser(Claims claims) {
        List<String> roles = claims.get("roles", List.class);
        return new LoginUser(
                Long.valueOf(claims.getSubject()),
                claims.get("username", String.class),
                claims.get("realName", String.class),
                claims.get("userType", String.class),
                claims.get("orgId", Long.class),
                claims.get("stage", String.class),
                claims.get("campusId", Long.class),
                claims.get("mustChangePwd", Boolean.class),
                roles
        );
    }
}
