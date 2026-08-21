package com.asedu.base.service;

import com.asedu.base.entity.BaseStudentHealth;
import com.asedu.base.mapper.BaseStudentHealthMapper;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 学生健康档案服务（隐私数据加密隔离存储，权限严格受控：管理员/班主任/校医）
 */
@Service
@RequiredArgsConstructor
public class HealthService {

    private final BaseStudentHealthMapper healthMapper;

    public BaseStudentHealth getByStudentId(Long studentId) {
        return healthMapper.selectOne(new LambdaQueryWrapper<BaseStudentHealth>()
                .eq(BaseStudentHealth::getStudentId, studentId).last("LIMIT 1"));
    }

    @Transactional
    public BaseStudentHealth save(BaseStudentHealth health) {
        if (health.getStudentId() == null) {
            throw new BusinessException("studentId 不能为空");
        }
        BaseStudentHealth exist = getByStudentId(health.getStudentId());
        health.setUpdatedBy(UserContext.userId());
        if (exist == null) {
            health.setId(null);
            healthMapper.insert(health);
        } else {
            health.setId(exist.getId());
            healthMapper.updateById(health);
        }
        return getByStudentId(health.getStudentId());
    }
}
