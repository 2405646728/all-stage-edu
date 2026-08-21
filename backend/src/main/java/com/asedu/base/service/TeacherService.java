package com.asedu.base.service;

import com.asedu.base.entity.BaseTeacher;
import com.asedu.base.entity.BaseTeacherPost;
import com.asedu.base.mapper.BaseTeacherMapper;
import com.asedu.base.mapper.BaseTeacherPostMapper;
import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 师资服务：主档 CRUD + 岗位绑定（一人多岗/一岗多人，岗位联动权限）
 */
@Service
@RequiredArgsConstructor
public class TeacherService {

    private final BaseTeacherMapper teacherMapper;
    private final BaseTeacherPostMapper postMapper;

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

    public PageResult<BaseTeacher> page(long current, long size, Long orgId, String keyword, String workStatus) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<BaseTeacher> qw = new LambdaQueryWrapper<BaseTeacher>()
                .eq(BaseTeacher::getOrgId, oid)
                .eq(workStatus != null && !workStatus.isBlank(), BaseTeacher::getWorkStatus, workStatus);
        if (keyword != null && !keyword.isBlank()) {
            qw.and(w -> w.like(BaseTeacher::getName, keyword)
                    .or().like(BaseTeacher::getStaffNo, keyword)
                    .or().like(BaseTeacher::getPhone, keyword));
        }
        qw.orderByDesc(BaseTeacher::getCreatedAt);
        return PageResult.of(teacherMapper.selectPage(new Page<>(current, size), qw));
    }

    public BaseTeacher detail(Long id) {
        BaseTeacher t = teacherMapper.selectById(id);
        if (t == null) {
            throw new BusinessException("教职工不存在");
        }
        return t;
    }

    @Transactional
    public BaseTeacher save(BaseTeacher teacher) {
        Long oid = resolveOrgId(teacher.getOrgId());
        teacher.setOrgId(oid);
        if (teacher.getId() == null) {
            if (teacher.getWorkStatus() == null || teacher.getWorkStatus().isBlank()) {
                teacher.setWorkStatus("active");
            }
            teacherMapper.insert(teacher);
        } else {
            teacherMapper.updateById(teacher);
        }
        return teacher;
    }

    @Transactional
    public void remove(Long id) {
        teacherMapper.deleteById(id);
    }

    /** 岗位绑定（一人多岗：班主任/任课/保育员/校医/行政等） */
    @Transactional
    public BaseTeacherPost savePost(BaseTeacherPost post) {
        Long oid = resolveOrgId(post.getOrgId());
        post.setOrgId(oid);
        if (post.getId() == null) {
            postMapper.insert(post);
        } else {
            postMapper.updateById(post);
        }
        return post;
    }

    public java.util.List<BaseTeacherPost> listPosts(Long teacherId) {
        return postMapper.selectList(new LambdaQueryWrapper<BaseTeacherPost>()
                .eq(BaseTeacherPost::getTeacherId, teacherId)
                .eq(BaseTeacherPost::getPostStatus, 1));
    }
}
