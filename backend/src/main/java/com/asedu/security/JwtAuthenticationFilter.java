package com.asedu.security;

import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * JWT 认证过滤器：校验 token -> Redis 会话校验 -> 注入 SecurityContext
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String TOKEN_KEY_PREFIX = "asedu:token:";

    private final JwtUtil jwtUtil;
    private final JwtProperties props;
    private final RedisTemplate<String, Object> redisTemplate;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String token = resolveToken(request);
        if (StringUtils.hasText(token) && jwtUtil.validate(token)) {
            Claims claims = jwtUtil.parse(token);
            String redisToken = (String) redisTemplate.opsForValue().get(TOKEN_KEY_PREFIX + claims.getSubject());
            if (token.equals(redisToken)) {
                LoginUser loginUser = jwtUtil.toLoginUser(claims);
                UserContext.set(loginUser);
                List<SimpleGrantedAuthority> authorities =
                        loginUser.getRoles() == null ? List.of()
                                : loginUser.getRoles().stream().map(r -> new SimpleGrantedAuthority("ROLE_" + r)).toList();
                UsernamePasswordAuthenticationToken auth =
                        new UsernamePasswordAuthenticationToken(loginUser, null, authorities);
                auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(auth);
            }
        }
        try {
            chain.doFilter(request, response);
        } finally {
            UserContext.clear();
        }
    }

    private String resolveToken(HttpServletRequest request) {
        String header = request.getHeader(props.getHeader());
        if (StringUtils.hasText(header) && header.startsWith(props.getPrefix())) {
            return header.substring(props.getPrefix().length());
        }
        return null;
    }
}
