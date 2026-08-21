package com.asedu.security;

/**
 * 当前登录用户上下文（请求线程内）
 */
public final class UserContext {

    private static final ThreadLocal<LoginUser> HOLDER = new ThreadLocal<>();

    private UserContext() {
    }

    public static void set(LoginUser user) {
        HOLDER.set(user);
    }

    public static LoginUser get() {
        return HOLDER.get();
    }

    public static Long userId() {
        LoginUser u = HOLDER.get();
        return u == null ? null : u.getId();
    }

    public static Long orgId() {
        LoginUser u = HOLDER.get();
        return u == null ? null : u.getOrgId();
    }

    public static boolean isSuperAdmin() {
        LoginUser u = HOLDER.get();
        return u != null && "super_admin".equals(u.getUserType());
    }

    public static void clear() {
        HOLDER.remove();
    }
}
