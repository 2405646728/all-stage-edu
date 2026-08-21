package com.asedu.high.service;

import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.high.entity.HighGaokaoPrep;
import com.asedu.high.entity.HighGraduationOutcome;
import com.asedu.high.entity.HighScoreConversion;
import com.asedu.high.entity.HighSelectionChoice;
import com.asedu.high.entity.HighSelectionRule;
import com.asedu.high.entity.HighTierClass;
import com.asedu.high.entity.HighWalkClassMember;
import com.asedu.high.mapper.HighGaokaoPrepMapper;
import com.asedu.high.mapper.HighGraduationOutcomeMapper;
import com.asedu.high.mapper.HighScoreConversionMapper;
import com.asedu.high.mapper.HighSelectionChoiceMapper;
import com.asedu.high.mapper.HighSelectionRuleMapper;
import com.asedu.high.mapper.HighTierClassMapper;
import com.asedu.high.mapper.HighWalkClassMemberMapper;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 普高专属服务：新高考选科规则/学生选科/分层走班/赋分/高考备考/升学去向
 */
@Service
@RequiredArgsConstructor
public class HighService {

    private final HighSelectionRuleMapper ruleMapper;
    private final HighSelectionChoiceMapper choiceMapper;
    private final HighTierClassMapper tierClassMapper;
    private final HighWalkClassMemberMapper walkMemberMapper;
    private final HighScoreConversionMapper conversionMapper;
    private final HighGaokaoPrepMapper prepMapper;
    private final HighGraduationOutcomeMapper outcomeMapper;

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

    // ---------- 选科规则 ----------
    public List<HighSelectionRule> listRules(Long orgId, Long gradeId) {
        Long oid = resolveOrgId(orgId);
        return ruleMapper.selectList(new LambdaQueryWrapper<HighSelectionRule>()
                .eq(HighSelectionRule::getOrgId, oid)
                .eq(gradeId != null, HighSelectionRule::getGradeId, gradeId));
    }

    @Transactional
    public HighSelectionRule saveRule(HighSelectionRule rule) {
        rule.setOrgId(resolveOrgId(rule.getOrgId()));
        rule.setCreatedBy(UserContext.userId());
        if (rule.getId() == null) {
            ruleMapper.insert(rule);
        } else {
            ruleMapper.updateById(rule);
        }
        return rule;
    }

    // ---------- 学生选科（自主选科 + 班主任审核确认） ----------
    public PageResult<HighSelectionChoice> pageChoice(long current, long size, Long orgId, Long studentId, String status) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<HighSelectionChoice> qw = new LambdaQueryWrapper<HighSelectionChoice>()
                .eq(HighSelectionChoice::getOrgId, oid)
                .eq(studentId != null, HighSelectionChoice::getStudentId, studentId)
                .eq(status != null && !status.isBlank(), HighSelectionChoice::getStatus, status)
                .orderByDesc(HighSelectionChoice::getCreatedAt);
        return PageResult.of(choiceMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public HighSelectionChoice saveChoice(HighSelectionChoice choice) {
        choice.setOrgId(resolveOrgId(choice.getOrgId()));
        if (choice.getChoiceRound() == null) {
            choice.setChoiceRound(1);
        }
        if (choice.getStatus() == null || choice.getStatus().isBlank()) {
            choice.setStatus("pending");
        }
        if (choice.getId() == null) {
            choiceMapper.insert(choice);
        } else {
            choiceMapper.updateById(choice);
        }
        return choice;
    }

    /** 班主任审核确认（选科合规性校验/锁定最终结果） */
    @Transactional
    public HighSelectionChoice auditChoice(Long id, String status, String remark) {
        HighSelectionChoice choice = choiceMapper.selectById(id);
        if (choice == null) {
            throw new BusinessException("选科记录不存在");
        }
        choice.setStatus(status);
        choice.setAuditBy(UserContext.userId());
        choice.setAuditAt(LocalDateTime.now());
        choice.setAuditRemark(remark == null ? "" : remark);
        choiceMapper.updateById(choice);
        return choice;
    }

    // ---------- 分层走班 ----------
    public List<HighTierClass> listTierClasses(Long orgId, Long termId) {
        Long oid = resolveOrgId(orgId);
        return tierClassMapper.selectList(new LambdaQueryWrapper<HighTierClass>()
                .eq(HighTierClass::getOrgId, oid)
                .eq(termId != null, HighTierClass::getTermId, termId));
    }

    @Transactional
    public HighTierClass saveTierClass(HighTierClass tier) {
        tier.setOrgId(resolveOrgId(tier.getOrgId()));
        tier.setOperatorId(UserContext.userId());
        if (tier.getId() == null) {
            tierClassMapper.insert(tier);
        } else {
            tierClassMapper.updateById(tier);
        }
        return tier;
    }

    public List<HighWalkClassMember> listWalkMembers(Long orgId, Long walkClassId) {
        Long oid = resolveOrgId(orgId);
        return walkMemberMapper.selectList(new LambdaQueryWrapper<HighWalkClassMember>()
                .eq(HighWalkClassMember::getOrgId, oid)
                .eq(walkClassId != null, HighWalkClassMember::getWalkClassId, walkClassId)
                .eq(HighWalkClassMember::getStatus, 1));
    }

    @Transactional
    public HighWalkClassMember saveWalkMember(HighWalkClassMember member) {
        member.setOrgId(resolveOrgId(member.getOrgId()));
        member.setOperatorId(UserContext.userId());
        if (member.getStatus() == null) {
            member.setStatus(1);
        }
        if (member.getId() == null) {
            walkMemberMapper.insert(member);
        } else {
            walkMemberMapper.updateById(member);
        }
        return member;
    }

    // ---------- 赋分规则 ----------
    public List<HighScoreConversion> listConversions(Long orgId, String subjectCode) {
        Long oid = resolveOrgId(orgId);
        return conversionMapper.selectList(new LambdaQueryWrapper<HighScoreConversion>()
                .eq(HighScoreConversion::getOrgId, oid)
                .eq(subjectCode != null && !subjectCode.isBlank(), HighScoreConversion::getSubjectCode, subjectCode)
                .orderByAsc(HighScoreConversion::getGradeBand));
    }

    @Transactional
    public HighScoreConversion saveConversion(HighScoreConversion conv) {
        conv.setOrgId(resolveOrgId(conv.getOrgId()));
        if (conv.getId() == null) {
            conversionMapper.insert(conv);
        } else {
            conversionMapper.updateById(conv);
        }
        return conv;
    }

    // ---------- 高考备考台账 ----------
    public List<HighGaokaoPrep> listPrep(Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        return prepMapper.selectList(new LambdaQueryWrapper<HighGaokaoPrep>()
                .eq(HighGaokaoPrep::getOrgId, oid)
                .eq(studentId != null, HighGaokaoPrep::getStudentId, studentId));
    }

    @Transactional
    public HighGaokaoPrep savePrep(HighGaokaoPrep prep) {
        prep.setOrgId(resolveOrgId(prep.getOrgId()));
        prep.setOperatorId(UserContext.userId());
        if (prep.getPrepStatus() == null || prep.getPrepStatus().isBlank()) {
            prep.setPrepStatus("preparing");
        }
        if (prep.getId() == null) {
            prepMapper.insert(prep);
        } else {
            prepMapper.updateById(prep);
        }
        return prep;
    }

    // ---------- 毕业升学去向 ----------
    public List<HighGraduationOutcome> listOutcomes(Long orgId, Integer graduateYear) {
        Long oid = resolveOrgId(orgId);
        return outcomeMapper.selectList(new LambdaQueryWrapper<HighGraduationOutcome>()
                .eq(HighGraduationOutcome::getOrgId, oid)
                .eq(graduateYear != null, HighGraduationOutcome::getGraduateYear, graduateYear));
    }

    @Transactional
    public HighGraduationOutcome saveOutcome(HighGraduationOutcome outcome) {
        outcome.setOrgId(resolveOrgId(outcome.getOrgId()));
        outcome.setOperatorId(UserContext.userId());
        if (outcome.getId() == null) {
            outcomeMapper.insert(outcome);
        } else {
            outcomeMapper.updateById(outcome);
        }
        return outcome;
    }
}
