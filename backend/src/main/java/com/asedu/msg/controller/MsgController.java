package com.asedu.msg.controller;

import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
import com.asedu.msg.entity.MsgMessage;
import com.asedu.msg.entity.MsgNotice;
import com.asedu.msg.entity.MsgPushTemplate;
import com.asedu.msg.service.MsgService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/** 家校互通（通知/已读回执/一对一消息/推送模板） */
@RestController
@RequestMapping("/api/msg")
@RequiredArgsConstructor
public class MsgController {

    private final MsgService msgService;

    @GetMapping("/notice/page")
    public R<PageResult<MsgNotice>> pageNotice(@RequestParam(defaultValue = "1") long current,
                                               @RequestParam(defaultValue = "10") long size,
                                               @RequestParam(required = false) Long orgId,
                                               @RequestParam(required = false) String title,
                                               @RequestParam(required = false) String noticeType) {
        return R.ok(msgService.pageNotice(current, size, orgId, title, noticeType));
    }

    @PostMapping("/notice/publish")
    public R<MsgNotice> publishNotice(@RequestBody Map<String, Object> body) {
        Long orgId = body.get("orgId") == null ? null : Long.valueOf(String.valueOf(body.get("orgId")));
        MsgNotice notice = new MsgNotice();
        notice.setOrgId(orgId);
        notice.setNoticeType(String.valueOf(body.getOrDefault("noticeType", "notice")));
        notice.setScopeType(String.valueOf(body.getOrDefault("scopeType", "org")));
        notice.setTitle(String.valueOf(body.get("title")));
        notice.setContent(String.valueOf(body.getOrDefault("content", "")));
        notice.setNeedReadBack(body.get("needReadBack") == null ? 1 : Integer.valueOf(String.valueOf(body.get("needReadBack"))));
        @SuppressWarnings("unchecked")
        List<Long> classIds = ((List<Object>) body.getOrDefault("classIds", List.of()))
                .stream().map(o -> Long.valueOf(String.valueOf(o))).toList();
        @SuppressWarnings("unchecked")
        List<Long> userIds = ((List<Object>) body.getOrDefault("userIds", List.of()))
                .stream().map(o -> Long.valueOf(String.valueOf(o))).toList();
        return R.ok(msgService.publishNotice(notice, classIds, userIds));
    }

    @PostMapping("/notice/read")
    public R<Void> markRead(@RequestParam Long noticeId) {
        msgService.markRead(noticeId);
        return R.ok();
    }

    @GetMapping("/message/page")
    public R<PageResult<MsgMessage>> pageMessage(@RequestParam(defaultValue = "1") long current,
                                                 @RequestParam(defaultValue = "10") long size,
                                                 @RequestParam Long receiverId) {
        return R.ok(msgService.pageMessage(current, size, receiverId));
    }

    @PostMapping("/message/send")
    public R<MsgMessage> sendMessage(@RequestBody MsgMessage message) {
        return R.ok(msgService.sendMessage(message));
    }

    @PostMapping("/template/save")
    public R<MsgPushTemplate> saveTemplate(@RequestBody MsgPushTemplate template) {
        return R.ok(msgService.saveTemplate(template));
    }

    @GetMapping("/template/list")
    public R<List<MsgPushTemplate>> listTemplates() {
        return R.ok(msgService.listTemplates());
    }
}