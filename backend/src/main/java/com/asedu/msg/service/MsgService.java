package com.asedu.msg.service;

import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.msg.entity.MsgMessage;
import com.asedu.msg.entity.MsgNotice;
import com.asedu.msg.entity.MsgNoticeRead;
import com.asedu.msg.entity.MsgNoticeScope;
import com.asedu.msg.entity.MsgPushTemplate;
import com.asedu.msg.mapper.MsgMessageMapper;
import com.asedu.msg.mapper.MsgNoticeMapper;
import com.asedu.msg.mapper.MsgNoticeReadMapper;
import com.asedu.msg.mapper.MsgNoticeScopeMapper;
import com.asedu.msg.mapper.MsgPushTemplateMapper;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 家校互通服务：通知发布（全园/班级分层/定向）+ 已读回执 + 一对一消息
 */
@Service
@RequiredArgsConstructor
public class MsgService {

    private final MsgNoticeMapper noticeMapper;
    private final MsgNoticeScopeMapper scopeMapper;
    private final MsgNoticeReadMapper readMapper;
    private final MsgMessageMapper messageMapper;
    private final MsgPushTemplateMapper templateMapper;

    private Long resolveOrgId(Long orgId) {
        if (UserContext.isSuperAdmin()) {
            if (orgId == null) {
                throw new BusinessException("平台超级管理员操作机构数据必须指定 orgId");
            }
            return orgId;
        }
        Long mine = UserContext.orgId();
        if (mine == null) {
            throw new BusinessException("当前账号未绑定机构");
        }
        return mine;
    }

    // ---------- 通知 ----------
    public PageResult<MsgNotice> pageNotice(long current, long size, Long orgId, String title, String noticeType) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<MsgNotice> qw = new LambdaQueryWrapper<MsgNotice>()
                .eq(MsgNotice::getOrgId, oid)
                .eq(noticeType != null && !noticeType.isBlank(), MsgNotice::getNoticeType, noticeType)
                .like(title != null && !title.isBlank(), MsgNotice::getTitle, title)
                .orderByDesc(MsgNotice::getPublishedAt);
        return PageResult.of(noticeMapper.selectPage(new Page<>(current, size), qw));
    }

    /** 发布通知（org/class/person 分层） */
    @Transactional
    public MsgNotice publishNotice(MsgNotice notice, List<Long> classIds, List<Long> userIds) {
        Long oid = resolveOrgId(notice.getOrgId());
        notice.setOrgId(oid);
        notice.setPublisherId(UserContext.userId());
        notice.setPublishedAt(LocalDateTime.now());
        notice.setPublishStatus("published");
        noticeMapper.insert(notice);
        if (classIds != null) {
            for (Long cid : classIds) {
                MsgNoticeScope scope = new MsgNoticeScope();
                scope.setNoticeId(notice.getId());
                scope.setClassId(cid);
                scopeMapper.insert(scope);
            }
        }
        if (userIds != null) {
            for (Long uid : userIds) {
                MsgNoticeScope scope = new MsgNoticeScope();
                scope.setNoticeId(notice.getId());
                scope.setUserId(uid);
                scopeMapper.insert(scope);
            }
        }
        return notice;
    }

    /** 已读回执 */
    @Transactional
    public void markRead(Long noticeId) {
        Long uid = UserContext.userId();
        MsgNoticeRead read = new MsgNoticeRead();
        read.setNoticeId(noticeId);
        read.setUserId(uid);
        readMapper.insert(read);
    }

    public long readCount(Long noticeId) {
        return readMapper.selectCount(new LambdaQueryWrapper<MsgNoticeRead>()
                .eq(MsgNoticeRead::getNoticeId, noticeId));
    }

    // ---------- 一对一消息 ----------
    public PageResult<MsgMessage> pageMessage(long current, long size, Long receiverId) {
        LambdaQueryWrapper<MsgMessage> qw = new LambdaQueryWrapper<MsgMessage>()
                .eq(MsgMessage::getReceiverId, receiverId)
                .orderByDesc(MsgMessage::getCreatedAt);
        return PageResult.of(messageMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public MsgMessage sendMessage(MsgMessage message) {
        Long oid = resolveOrgId(message.getOrgId());
        message.setOrgId(oid);
        message.setSenderId(UserContext.userId());
        message.setIsRead(0);
        messageMapper.insert(message);
        return message;
    }

    // ---------- 推送模板 ----------
    public List<MsgPushTemplate> listTemplates() {
        return templateMapper.selectList(new LambdaQueryWrapper<MsgPushTemplate>()
                .orderByAsc(MsgPushTemplate::getTemplateCode));
    }

    @org.springframework.transaction.annotation.Transactional
    public MsgPushTemplate saveTemplate(MsgPushTemplate template) {
        if (template.getId() == null) {
            templateMapper.insert(template);
        } else {
            templateMapper.updateById(template);
        }
        return template;
    }
}