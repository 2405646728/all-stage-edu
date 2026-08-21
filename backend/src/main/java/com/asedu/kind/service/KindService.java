package com.asedu.kind.service;

import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.kind.entity.KindActivityRecord;
import com.asedu.kind.entity.KindGrowthRecord;
import com.asedu.kind.entity.KindHealthAbnormal;
import com.asedu.kind.entity.KindHealthCheck;
import com.asedu.kind.entity.KindMeal;
import com.asedu.kind.entity.KindNapRecord;
import com.asedu.kind.entity.KindPickupAuthorization;
import com.asedu.kind.entity.KindPickupRecord;
import com.asedu.kind.entity.KindSafetyInspect;
import com.asedu.kind.mapper.KindActivityRecordMapper;
import com.asedu.kind.mapper.KindGrowthRecordMapper;
import com.asedu.kind.mapper.KindHealthAbnormalMapper;
import com.asedu.kind.mapper.KindHealthCheckMapper;
import com.asedu.kind.mapper.KindMealMapper;
import com.asedu.kind.mapper.KindNapRecordMapper;
import com.asedu.kind.mapper.KindPickupAuthorizationMapper;
import com.asedu.kind.mapper.KindPickupRecordMapper;
import com.asedu.kind.mapper.KindSafetyInspectMapper;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 幼儿园专属服务：接送安全管理/餐食公示/成长纪实/晨午检/安全巡查
 * 对应文档 5.2.2 / 5.2.3 / 5.2.4
 */
@Service
@RequiredArgsConstructor
public class KindService {

    private final KindPickupAuthorizationMapper pickupAuthMapper;
    private final KindPickupRecordMapper pickupRecordMapper;
    private final KindMealMapper mealMapper;
    private final KindNapRecordMapper napMapper;
    private final KindActivityRecordMapper activityMapper;
    private final KindGrowthRecordMapper growthMapper;
    private final KindHealthCheckMapper healthCheckMapper;
    private final KindHealthAbnormalMapper healthAbnormalMapper;
    private final KindSafetyInspectMapper inspectMapper;

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

    // ---------- 接送授权（固定白名单 + 临时授权，班主任核验） ----------
    public List<KindPickupAuthorization> listPickupAuth(Long orgId, Long studentId, String pickupType) {
        Long oid = resolveOrgId(orgId);
        return pickupAuthMapper.selectList(new LambdaQueryWrapper<KindPickupAuthorization>()
                .eq(KindPickupAuthorization::getOrgId, oid)
                .eq(studentId != null, KindPickupAuthorization::getStudentId, studentId)
                .eq(pickupType != null && !pickupType.isBlank(), KindPickupAuthorization::getPickupType, pickupType)
                .orderByDesc(KindPickupAuthorization::getCreatedAt));
    }

    @Transactional
    public KindPickupAuthorization savePickupAuth(KindPickupAuthorization auth) {
        Long oid = resolveOrgId(auth.getOrgId());
        auth.setOrgId(oid);
        auth.setApplyBy(UserContext.userId());
        if (auth.getApproveStatus() == null || auth.getApproveStatus().isBlank()) {
            auth.setApproveStatus("pending");
        }
        if (auth.getId() == null) {
            pickupAuthMapper.insert(auth);
        } else {
            pickupAuthMapper.updateById(auth);
        }
        return auth;
    }

    /** 班主任核验授权（临时接送需人工核验留存） */
    @Transactional
    public KindPickupAuthorization approvePickupAuth(Long id, String approveStatus) {
        KindPickupAuthorization auth = pickupAuthMapper.selectById(id);
        if (auth == null) {
            throw new BusinessException("接送授权不存在");
        }
        auth.setApproveStatus(approveStatus);
        auth.setApproveBy(UserContext.userId());
        auth.setApproveAt(java.time.LocalDateTime.now());
        pickupAuthMapper.updateById(auth);
        return auth;
    }

    // ---------- 接送记录（全量溯源 + 超时未接预警） ----------
    public PageResult<KindPickupRecord> pagePickupRecord(long current, long size, Long orgId, String keyword) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<KindPickupRecord> qw = new LambdaQueryWrapper<KindPickupRecord>()
                .eq(KindPickupRecord::getOrgId, oid);
        if (keyword != null && !keyword.isBlank()) {
            qw.and(w -> w.like(KindPickupRecord::getPickupName, keyword).or()
                    .inSql(KindPickupRecord::getStudentId,
                            "SELECT id FROM base_student WHERE org_id=" + oid + " AND name LIKE '%" + keyword + "%'"));
        }
        qw.orderByDesc(KindPickupRecord::getPickupTime);
        return PageResult.of(pickupRecordMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public KindPickupRecord recordPickup(KindPickupRecord record) {
        Long oid = resolveOrgId(record.getOrgId());
        record.setOrgId(oid);
        record.setOperatorId(UserContext.userId());
        if (record.getVerifyResult() == null || record.getVerifyResult().isBlank()) {
            record.setVerifyResult("manual_verify");
        }
        if (record.getIsAlert() == null) {
            record.setIsAlert(0);
        }
        pickupRecordMapper.insert(record);
        return record;
    }

    // ---------- 餐食公示 ----------
    public List<KindMeal> listMeal(Long orgId, String mealDate) {
        Long oid = resolveOrgId(orgId);
        return mealMapper.selectList(new LambdaQueryWrapper<KindMeal>()
                .eq(KindMeal::getOrgId, oid)
                .eq(mealDate != null && !mealDate.isBlank(), KindMeal::getMealDate, mealDate)
                .orderByAsc(KindMeal::getMealDate).orderByAsc(KindMeal::getMealType));
    }

    @Transactional
    public KindMeal saveMeal(KindMeal meal) {
        meal.setOrgId(resolveOrgId(meal.getOrgId()));
        meal.setPublisherId(UserContext.userId());
        if (meal.getId() == null) {
            mealMapper.insert(meal);
        } else {
            mealMapper.updateById(meal);
        }
        return meal;
    }

    // ---------- 午休 / 活动 / 成长纪实 ----------
    @Transactional
    public KindNapRecord saveNap(KindNapRecord nap) {
        nap.setOrgId(resolveOrgId(nap.getOrgId()));
        nap.setRecorderId(UserContext.userId());
        if (nap.getId() == null) {
            napMapper.insert(nap);
        } else {
            napMapper.updateById(nap);
        }
        return nap;
    }

    public List<KindActivityRecord> listActivity(Long orgId, Long classId) {
        Long oid = resolveOrgId(orgId);
        return activityMapper.selectList(new LambdaQueryWrapper<KindActivityRecord>()
                .eq(KindActivityRecord::getOrgId, oid)
                .eq(classId != null, KindActivityRecord::getClassId, classId)
                .orderByDesc(KindActivityRecord::getActivityDate));
    }

    @Transactional
    public KindActivityRecord saveActivity(KindActivityRecord record) {
        record.setOrgId(resolveOrgId(record.getOrgId()));
        record.setPublisherId(UserContext.userId());
        if (record.getId() == null) {
            activityMapper.insert(record);
        } else {
            activityMapper.updateById(record);
        }
        return record;
    }

    public PageResult<KindGrowthRecord> pageGrowth(long current, long size, Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<KindGrowthRecord> qw = new LambdaQueryWrapper<KindGrowthRecord>()
                .eq(KindGrowthRecord::getOrgId, oid)
                .eq(studentId != null, KindGrowthRecord::getStudentId, studentId)
                .orderByDesc(KindGrowthRecord::getCreatedAt);
        return PageResult.of(growthMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public KindGrowthRecord saveGrowth(KindGrowthRecord record) {
        record.setOrgId(resolveOrgId(record.getOrgId()));
        record.setPublisherId(UserContext.userId());
        if (record.getId() == null) {
            growthMapper.insert(record);
        } else {
            growthMapper.updateById(record);
        }
        return record;
    }

    // ---------- 晨午检 / 异常健康 / 安全巡查 ----------
    public List<KindHealthCheck> listHealthCheck(Long orgId, String checkDate, Integer isAbnormal) {
        Long oid = resolveOrgId(orgId);
        return healthCheckMapper.selectList(new LambdaQueryWrapper<KindHealthCheck>()
                .eq(KindHealthCheck::getOrgId, oid)
                .eq(checkDate != null && !checkDate.isBlank(), KindHealthCheck::getCheckDate, checkDate)
                .eq(isAbnormal != null, KindHealthCheck::getIsAbnormal, isAbnormal)
                .orderByDesc(KindHealthCheck::getCheckDate));
    }

    @Transactional
    public KindHealthCheck saveHealthCheck(KindHealthCheck check) {
        check.setOrgId(resolveOrgId(check.getOrgId()));
        check.setRecorderId(UserContext.userId());
        if (check.getIsAbnormal() == null) {
            check.setIsAbnormal(0);
        }
        if (check.getId() == null) {
            healthCheckMapper.insert(check);
        } else {
            healthCheckMapper.updateById(check);
        }
        return check;
    }

    public List<KindHealthAbnormal> listHealthAbnormal(Long orgId, String status) {
        Long oid = resolveOrgId(orgId);
        return healthAbnormalMapper.selectList(new LambdaQueryWrapper<KindHealthAbnormal>()
                .eq(KindHealthAbnormal::getOrgId, oid)
                .eq(status != null && !status.isBlank(), KindHealthAbnormal::getStatus, status)
                .orderByDesc(KindHealthAbnormal::getOccurredAt));
    }

    @Transactional
    public KindHealthAbnormal saveHealthAbnormal(KindHealthAbnormal abnormal) {
        abnormal.setOrgId(resolveOrgId(abnormal.getOrgId()));
        abnormal.setReporterId(UserContext.userId());
        if (abnormal.getStatus() == null || abnormal.getStatus().isBlank()) {
            abnormal.setStatus("open");
        }
        if (abnormal.getId() == null) {
            healthAbnormalMapper.insert(abnormal);
        } else {
            healthAbnormalMapper.updateById(abnormal);
        }
        return abnormal;
    }

    public List<KindSafetyInspect> listInspect(Long orgId, String status) {
        Long oid = resolveOrgId(orgId);
        return inspectMapper.selectList(new LambdaQueryWrapper<KindSafetyInspect>()
                .eq(KindSafetyInspect::getOrgId, oid)
                .eq(status != null && !status.isBlank(), KindSafetyInspect::getStatus, status)
                .orderByDesc(KindSafetyInspect::getCreatedAt));
    }

    @Transactional
    public KindSafetyInspect saveInspect(KindSafetyInspect inspect) {
        inspect.setOrgId(resolveOrgId(inspect.getOrgId()));
        inspect.setReporterId(UserContext.userId());
        if (inspect.getStatus() == null || inspect.getStatus().isBlank()) {
            inspect.setStatus("reported");
        }
        if (inspect.getId() == null) {
            inspectMapper.insert(inspect);
        } else {
            inspectMapper.updateById(inspect);
        }
        return inspect;
    }
}
