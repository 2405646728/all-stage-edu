package com.asedu.moral.service;

import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.moral.entity.MoralActivity;
import com.asedu.moral.entity.MoralClassEval;
import com.asedu.moral.entity.MoralComprehensiveEval;
import com.asedu.moral.entity.MoralRecord;
import com.asedu.moral.entity.MoralScoreRule;
import com.asedu.moral.entity.MoralTalk;
import com.asedu.moral.mapper.MoralActivityMapper;
import com.asedu.moral.mapper.MoralClassEvalMapper;
import com.asedu.moral.mapper.MoralComprehensiveEvalMapper;
import com.asedu.moral.mapper.MoralRecordMapper;
import com.asedu.moral.mapper.MoralScoreRuleMapper;
import com.asedu.moral.mapper.MoralTalkMapper;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 德育服务：奖惩积分/班级量化考核/德育活动/谈心心理/综合素质评价
 */
@Service
@RequiredArgsConstructor
public class MoralService {

    private final MoralScoreRuleMapper ruleMapper;
    private final MoralRecordMapper recordMapper;
    private final MoralClassEvalMapper classEvalMapper;
    private final MoralActivityMapper activityMapper;
    private final MoralTalkMapper talkMapper;
    private final MoralComprehensiveEvalMapper evalMapper;

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

    // ---------- 评分规则 / 奖惩记录 ----------
    public List<MoralScoreRule> listRules(Long orgId) {
        Long oid = resolveOrgId(orgId);
        return ruleMapper.selectList(new LambdaQueryWrapper<MoralScoreRule>()
                .eq(MoralScoreRule::getOrgId, oid).orderByAsc(MoralScoreRule::getDimension));
    }

    @Transactional
    public MoralScoreRule saveRule(MoralScoreRule rule) {
        rule.setOrgId(resolveOrgId(rule.getOrgId()));
        rule.setCreatedBy(UserContext.userId());
        if (rule.getId() == null) {
            ruleMapper.insert(rule);
        } else {
            ruleMapper.updateById(rule);
        }
        return rule;
    }

    public PageResult<MoralRecord> pageRecord(long current, long size, Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<MoralRecord> qw = new LambdaQueryWrapper<MoralRecord>()
                .eq(MoralRecord::getOrgId, oid)
                .eq(studentId != null, MoralRecord::getStudentId, studentId)
                .orderByDesc(MoralRecord::getOccurredAt);
        return PageResult.of(recordMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public MoralRecord saveRecord(MoralRecord record) {
        record.setOrgId(resolveOrgId(record.getOrgId()));
        record.setRecorderId(UserContext.userId());
        if (record.getId() == null) {
            recordMapper.insert(record);
        } else {
            recordMapper.updateById(record);
        }
        return record;
    }

    // ---------- 班级量化考核 ----------
    public List<MoralClassEval> listClassEval(Long orgId, Long classId, String evalPeriod) {
        Long oid = resolveOrgId(orgId);
        return classEvalMapper.selectList(new LambdaQueryWrapper<MoralClassEval>()
                .eq(MoralClassEval::getOrgId, oid)
                .eq(classId != null, MoralClassEval::getClassId, classId)
                .eq(evalPeriod != null && !evalPeriod.isBlank(), MoralClassEval::getEvalPeriod, evalPeriod)
                .orderByDesc(MoralClassEval::getPeriodEnd));
    }

    @Transactional
    public MoralClassEval saveClassEval(MoralClassEval eval) {
        eval.setOrgId(resolveOrgId(eval.getOrgId()));
        eval.setOperatorId(UserContext.userId());
        if (eval.getId() == null) {
            classEvalMapper.insert(eval);
        } else {
            classEvalMapper.updateById(eval);
        }
        return eval;
    }

    // ---------- 德育活动 ----------
    public List<MoralActivity> listActivity(Long orgId, Long classId) {
        Long oid = resolveOrgId(orgId);
        return activityMapper.selectList(new LambdaQueryWrapper<MoralActivity>()
                .eq(MoralActivity::getOrgId, oid)
                .eq(classId != null, MoralActivity::getClassId, classId)
                .orderByDesc(MoralActivity::getActivityDate));
    }

    @Transactional
    public MoralActivity saveActivity(MoralActivity activity) {
        activity.setOrgId(resolveOrgId(activity.getOrgId()));
        activity.setRecorderId(UserContext.userId());
        if (activity.getId() == null) {
            activityMapper.insert(activity);
        } else {
            activityMapper.updateById(activity);
        }
        return activity;
    }

    // ---------- 谈心心理 ----------
    public List<MoralTalk> listTalk(Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        return talkMapper.selectList(new LambdaQueryWrapper<MoralTalk>()
                .eq(MoralTalk::getOrgId, oid)
                .eq(studentId != null, MoralTalk::getStudentId, studentId)
                .orderByDesc(MoralTalk::getTalkedAt));
    }

    @Transactional
    public MoralTalk saveTalk(MoralTalk talk) {
        talk.setOrgId(resolveOrgId(talk.getOrgId()));
        talk.setTalkerId(UserContext.userId());
        if (talk.getId() == null) {
            talkMapper.insert(talk);
        } else {
            talkMapper.updateById(talk);
        }
        return talk;
    }

    // ---------- 综合素质评价 ----------
    public List<MoralComprehensiveEval> listEval(Long orgId, Long studentId, Long termId) {
        Long oid = resolveOrgId(orgId);
        return evalMapper.selectList(new LambdaQueryWrapper<MoralComprehensiveEval>()
                .eq(MoralComprehensiveEval::getOrgId, oid)
                .eq(studentId != null, MoralComprehensiveEval::getStudentId, studentId)
                .eq(termId != null, MoralComprehensiveEval::getTermId, termId)
                .orderByDesc(MoralComprehensiveEval::getCreatedAt));
    }

    @Transactional
    public MoralComprehensiveEval saveEval(MoralComprehensiveEval eval) {
        eval.setOrgId(resolveOrgId(eval.getOrgId()));
        eval.setEvaluatorId(UserContext.userId());
        if (eval.getId() == null) {
            evalMapper.insert(eval);
        } else {
            evalMapper.updateById(eval);
        }
        return eval;
    }
}
