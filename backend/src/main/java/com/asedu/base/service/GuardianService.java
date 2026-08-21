package com.asedu.base.service;

import com.asedu.base.entity.BaseGuardian;
import com.asedu.base.entity.BaseStudentGuardian;
import com.asedu.base.mapper.BaseGuardianMapper;
import com.asedu.base.mapper.BaseStudentGuardianMapper;
import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 监护人服务：多监护人绑定（第一/次要、紧急联系人、接送授权白名单数据源）
 */
@Service
@RequiredArgsConstructor
public class GuardianService {

    private final BaseGuardianMapper guardianMapper;
    private final BaseStudentGuardianMapper sgMapper;

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

    public PageResult<BaseGuardian> page(long current, long size, Long orgId, String keyword) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<BaseGuardian> qw = new LambdaQueryWrapper<BaseGuardian>()
                .eq(BaseGuardian::getOrgId, oid);
        if (keyword != null && !keyword.isBlank()) {
            qw.and(w -> w.like(BaseGuardian::getName, keyword).or().like(BaseGuardian::getPhone, keyword));
        }
        qw.orderByDesc(BaseGuardian::getCreatedAt);
        return PageResult.of(guardianMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public BaseGuardian save(BaseGuardian guardian) {
        guardian.setOrgId(resolveOrgId(guardian.getOrgId()));
        if (guardian.getId() == null) {
            guardianMapper.insert(guardian);
        } else {
            guardianMapper.updateById(guardian);
        }
        return guardian;
    }

    /** 绑定学生-监护人（多子女关联、主次监护人、接送授权） */
    @Transactional
    public BaseStudentGuardian bindStudent(Long orgId, Long studentId, Long guardianId,
                                           Integer isPrimary, Integer canPickup) {
        Long oid = resolveOrgId(orgId);
        BaseStudentGuardian sg = new BaseStudentGuardian();
        sg.setOrgId(oid);
        sg.setStudentId(studentId);
        sg.setGuardianId(guardianId);
        sg.setIsPrimary(isPrimary == null ? 0 : isPrimary);
        sg.setCanPickup(canPickup == null ? 0 : canPickup);
        sg.setBindStatus(1);
        sg.setBoundAt(LocalDateTime.now());
        sg.setOperatorId(UserContext.userId());
        sgMapper.insert(sg);
        return sg;
    }

    public List<BaseGuardian> listByStudent(Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        List<Long> ids = sgMapper.selectList(new LambdaQueryWrapper<BaseStudentGuardian>()
                        .eq(BaseStudentGuardian::getOrgId, oid)
                        .eq(BaseStudentGuardian::getStudentId, studentId)
                        .eq(BaseStudentGuardian::getBindStatus, 1))
                .stream().map(BaseStudentGuardian::getGuardianId).toList();
        if (ids.isEmpty()) {
            return List.of();
        }
        return guardianMapper.selectBatchIds(ids);
    }

    /** 解绑 */
    @Transactional
    public void unbindStudent(Long studentId, Long guardianId) {
        sgMapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<BaseStudentGuardian>()
                .eq(BaseStudentGuardian::getStudentId, studentId)
                .eq(BaseStudentGuardian::getGuardianId, guardianId)
                .eq(BaseStudentGuardian::getBindStatus, 1)
                .set(BaseStudentGuardian::getBindStatus, 0)
                .set(BaseStudentGuardian::getUnboundAt, LocalDateTime.now())
                .set(BaseStudentGuardian::getOperatorId, UserContext.userId()));
    }
}
