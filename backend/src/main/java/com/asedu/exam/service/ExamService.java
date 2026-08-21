package com.asedu.exam.service;

import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.exam.entity.ExamPlan;
import com.asedu.exam.entity.ExamScore;
import com.asedu.exam.entity.ExamSubject;
import com.asedu.exam.mapper.ExamPlanMapper;
import com.asedu.exam.mapper.ExamScoreMapper;
import com.asedu.exam.mapper.ExamSubjectMapper;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 考试与成绩服务：考试建档/科目配置/成绩录入（分数统计、排名、等级换算）
 */
@Service
@RequiredArgsConstructor
public class ExamService {

    private final ExamPlanMapper planMapper;
    private final ExamSubjectMapper subjectMapper;
    private final ExamScoreMapper scoreMapper;

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

    // ---------- 考试 ----------
    public PageResult<ExamPlan> pageExam(long current, long size, Long orgId, String examType, String keyword) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<ExamPlan> qw = new LambdaQueryWrapper<ExamPlan>()
                .eq(ExamPlan::getOrgId, oid)
                .eq(examType != null && !examType.isBlank(), ExamPlan::getExamType, examType)
                .like(keyword != null && !keyword.isBlank(), ExamPlan::getExamName, keyword)
                .orderByDesc(ExamPlan::getExamDate);
        return PageResult.of(planMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public ExamPlan saveExam(ExamPlan plan) {
        plan.setOrgId(resolveOrgId(plan.getOrgId()));
        plan.setCreatedBy(UserContext.userId());
        if (plan.getStatus() == null || plan.getStatus().isBlank()) {
            plan.setStatus("draft");
        }
        if (plan.getId() == null) {
            planMapper.insert(plan);
        } else {
            planMapper.updateById(plan);
        }
        return plan;
    }

    // ---------- 考试科目 ----------
    public List<ExamSubject> listSubjects(Long examId) {
        return subjectMapper.selectList(new LambdaQueryWrapper<ExamSubject>()
                .eq(ExamSubject::getExamId, examId));
    }

    @Transactional
    public ExamSubject saveSubject(ExamSubject subject) {
        if (subject.getId() == null) {
            subjectMapper.insert(subject);
        } else {
            subjectMapper.updateById(subject);
        }
        return subject;
    }

    // ---------- 成绩 ----------
    public PageResult<ExamScore> pageScore(long current, long size, Long orgId, Long examId, Long subjectId) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<ExamScore> qw = new LambdaQueryWrapper<ExamScore>()
                .eq(ExamScore::getOrgId, oid)
                .eq(examId != null, ExamScore::getExamId, examId)
                .eq(subjectId != null, ExamScore::getExamSubjectId, subjectId)
                .orderByDesc(ExamScore::getScore);
        return PageResult.of(scoreMapper.selectPage(new Page<>(current, size), qw));
    }

    /** 成绩录入（同一学生同一科目唯一，重复录入则更新） */
    @Transactional
    public ExamScore saveScore(ExamScore score) {
        score.setOrgId(resolveOrgId(score.getOrgId()));
        score.setEntryBy(UserContext.userId());
        if (score.getId() == null) {
            ExamScore exist = scoreMapper.selectOne(new LambdaQueryWrapper<ExamScore>()
                    .eq(ExamScore::getExamSubjectId, score.getExamSubjectId())
                    .eq(ExamScore::getStudentId, score.getStudentId())
                    .last("LIMIT 1"));
            if (exist != null) {
                score.setId(exist.getId());
            }
        }
        if (score.getId() == null) {
            scoreMapper.insert(score);
        } else {
            scoreMapper.updateById(score);
        }
        return score;
    }
}
