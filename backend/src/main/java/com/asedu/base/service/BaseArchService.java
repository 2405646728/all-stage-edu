package com.asedu.base.service;

import com.asedu.base.entity.BaseClass;
import com.asedu.base.entity.BaseGrade;
import com.asedu.base.entity.BaseSchoolYear;
import com.asedu.base.entity.BaseTerm;
import com.asedu.base.mapper.BaseClassMapper;
import com.asedu.base.mapper.BaseGradeMapper;
import com.asedu.base.mapper.BaseSchoolYearMapper;
import com.asedu.base.mapper.BaseTermMapper;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.asedu.sys.entity.SysOrg;
import com.asedu.sys.mapper.SysOrgMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 学年/学期/年级/班级架构服务（学校-院系-专业-年级-班级组织架构）
 */
@Service
@RequiredArgsConstructor
public class BaseArchService {

    private final BaseSchoolYearMapper schoolYearMapper;
    private final BaseTermMapper termMapper;
    private final BaseGradeMapper gradeMapper;
    private final BaseClassMapper classMapper;
    private final SysOrgMapper sysOrgMapper;

    /** 解析机构：超管需显式传 orgId，其余取当前机构 */
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

    // ---------- 学年 ----------
    public List<BaseSchoolYear> listSchoolYears(Long orgId) {
        Long oid = resolveOrgId(orgId);
        return schoolYearMapper.selectList(new LambdaQueryWrapper<BaseSchoolYear>()
                .eq(BaseSchoolYear::getOrgId, oid).orderByDesc(BaseSchoolYear::getStartDate));
    }

    @Transactional
    public BaseSchoolYear saveSchoolYear(BaseSchoolYear entity) {
        entity.setOrgId(resolveOrgId(entity.getOrgId()));
        if (entity.getId() == null) {
            schoolYearMapper.insert(entity);
        } else {
            schoolYearMapper.updateById(entity);
        }
        return entity;
    }

    public void removeSchoolYear(Long id) {
        schoolYearMapper.deleteById(id);
    }

    // ---------- 学期 ----------
    public List<BaseTerm> listTerms(Long orgId, Long schoolYearId) {
        Long oid = resolveOrgId(orgId);
        return termMapper.selectList(new LambdaQueryWrapper<BaseTerm>()
                .eq(BaseTerm::getOrgId, oid)
                .eq(schoolYearId != null, BaseTerm::getSchoolYearId, schoolYearId)
                .orderByAsc(BaseTerm::getTermNo));
    }

    @Transactional
    public BaseTerm saveTerm(BaseTerm entity) {
        entity.setOrgId(resolveOrgId(entity.getOrgId()));
        if (entity.getId() == null) {
            termMapper.insert(entity);
        } else {
            termMapper.updateById(entity);
        }
        return entity;
    }

    // ---------- 年级 ----------
    public List<BaseGrade> listGrades(Long orgId, Long schoolYearId) {
        Long oid = resolveOrgId(orgId);
        return gradeMapper.selectList(new LambdaQueryWrapper<BaseGrade>()
                .eq(BaseGrade::getOrgId, oid)
                .eq(schoolYearId != null, BaseGrade::getSchoolYearId, schoolYearId)
                .orderByAsc(BaseGrade::getGradeNo));
    }

    @Transactional
    public BaseGrade saveGrade(BaseGrade entity) {
        entity.setOrgId(resolveOrgId(entity.getOrgId()));
        if (entity.getId() == null) {
            gradeMapper.insert(entity);
        } else {
            gradeMapper.updateById(entity);
        }
        return entity;
    }

    public void removeGrade(Long id) {
        gradeMapper.deleteById(id);
    }

    // ---------- 班级 ----------
    public List<BaseClass> listClasses(Long orgId, Long gradeId) {
        Long oid = resolveOrgId(orgId);
        return classMapper.selectList(new LambdaQueryWrapper<BaseClass>()
                .eq(BaseClass::getOrgId, oid)
                .eq(gradeId != null, BaseClass::getGradeId, gradeId)
                .orderByAsc(BaseClass::getSortNo).orderByAsc(BaseClass::getClassName));
    }

    @Transactional
    public BaseClass saveClass(BaseClass entity) {
        Long oid = resolveOrgId(entity.getOrgId());
        entity.setOrgId(oid);
        if (entity.getStage() == null || entity.getStage().isBlank()) {
            // 学段自动判定：以机构学段为唯一依据（文档 12.2 冻结规则）
            SysOrg org = sysOrgMapper.selectById(oid);
            if (org == null) {
                throw new BusinessException("机构不存在");
            }
            entity.setStage(org.getStage());
        }
        if (entity.getId() == null) {
            classMapper.insert(entity);
        } else {
            classMapper.updateById(entity);
        }
        return entity;
    }

    public void removeClass(Long id) {
        classMapper.deleteById(id);
    }
}
