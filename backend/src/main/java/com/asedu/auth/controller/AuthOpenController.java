package com.asedu.auth.controller;

import com.asedu.auth.entity.AuthEmailInvite;
import com.asedu.auth.entity.AuthOpenBatch;
import com.asedu.auth.entity.AuthOpenItem;
import com.asedu.auth.entity.AuthUser;
import com.asedu.auth.service.AuthOpenService;
import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/** 账号便捷开通（五大模式，文档 12.5） */
@RestController
@RequestMapping("/api/auth/open")
@RequiredArgsConstructor
public class AuthOpenController {

    private final AuthOpenService authOpenService;

    /** 批量开通（excel/class_batch/sync/manual） */
    @PostMapping("/batch")
    public R<AuthOpenBatch> createBatch(@RequestBody Map<String, Object> body) {
        Long orgId = Long.valueOf(String.valueOf(body.get("orgId")));
        String openMode = String.valueOf(body.getOrDefault("openMode", "excel"));
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> rows = (List<Map<String, Object>>) body.getOrDefault("rows", List.of());
        return R.ok(authOpenService.createBatch(orgId, openMode, rows));
    }

    @GetMapping("/batch/page")
    public R<PageResult<AuthOpenBatch>> pageBatch(@RequestParam(defaultValue = "1") long current,
                                                  @RequestParam(defaultValue = "10") long size,
                                                  @RequestParam Long orgId) {
        return R.ok(authOpenService.pageBatch(current, size, orgId));
    }

    @GetMapping("/batch/items")
    public R<List<AuthOpenItem>> listItems(@RequestParam Long batchId) {
        return R.ok(authOpenService.listItems(batchId));
    }

    /** 邮箱推送一键开通 */
    @PostMapping("/invite")
    public R<AuthEmailInvite> createInvite(@RequestBody Map<String, Object> body) {
        return R.ok(authOpenService.createInvite(
                Long.valueOf(String.valueOf(body.get("orgId"))),
                String.valueOf(body.get("email")),
                String.valueOf(body.getOrDefault("realName", "")),
                String.valueOf(body.getOrDefault("userType", "student")),
                String.valueOf(body.getOrDefault("scopeDesc", ""))));
    }

    /** 用户确认开通（邮件一键确认） */
    @PostMapping("/invite/confirm")
    public R<AuthUser> confirmInvite(@RequestParam String token) {
        return R.ok(authOpenService.confirmInvite(token));
    }

    @GetMapping("/invite/page")
    public R<PageResult<AuthEmailInvite>> pageInvites(@RequestParam(defaultValue = "1") long current,
                                                      @RequestParam(defaultValue = "10") long size,
                                                      @RequestParam Long orgId) {
        return R.ok(authOpenService.pageInvites(current, size, orgId));
    }
}
