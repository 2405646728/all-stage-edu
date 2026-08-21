package com.asedu.att.service;

import com.asedu.att.entity.AttLeave;
import com.asedu.att.entity.AttStudentRecord;
import com.asedu.att.mapper.AttLeaveMapper;
import com.asedu.att.mapper.AttStudentRecordMapper;
import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * 考勤服务：学生考勤（签到/签退/异常标记）+ 请假申请与审批（单向联动）
 */
@Service
@RequiredArgsConstructor
public class AttService {

    private final AttStudentRecordMapper recordMapper;
    private final AttLeaveMapper leaveMapper;

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

    // ---------- 学生考勤 ----------
    public PageResult<AttStudentRecord> pageStudentAtt(long current, long size, Long orgId,
                                                       String keyword, String attDate, String status) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<AttStudentRecord> qw = new LambdaQueryWrapper<AttStudentRecord>()
                .eq(AttStudentRecord::getOrgId, oid)
                .eq(status != null && !status.isBlank(), AttStudentRecord::getStatus, status)
                .eq(attDate != null && !attDate.isBlank(), AttStudentRecord::getAttDate, attDate);
        if (keyword != null && !keyword.isBlank()) {
            qw.inSql(AttStudentRecord::getStudentId,
                    "SELECT id FROM base_student WHERE org_id=" + oid + " AND (name LIKE '%" + keyword + "%' OR student_no LIKE '%" + keyword + "%')");
        }
        qw.orderByDesc(AttStudentRecord::getAttDate).orderByDesc(AttStudentRecord::getId);
        return PageResult.of(recordMapper.selectPage(new Page<>(current, size), qw));
    }

    /** 打卡登记（刷卡/刷脸/人工补录） */
    @Transactional
    public AttStudentRecord checkIn(AttStudentRecord record) {
        Long oid = resolveOrgId(record.getOrgId());
        record.setOrgId(oid);
        record.setOperatorId(UserContext.userId());
        // 缺勤清单核对：状态为空默认正常，迟到由调用方或设备规则标记
        if (record.getStatus() == null || record.getStatus().isBlank()) {
            record.setStatus("normal");
        }
        if (record.getSignInTime() != null && record.getSignOutTime() != null) {
            long minutes = java.time.Duration.between(record.getSignInTime(), record.getSignOutTime()).toMinutes();
            record.setStayMinutes((int) Math.max(0, minutes));
        }
        if (record.getId() == null) {
            recordMapper.insert(record);
        } else {
            recordMapper.updateById(record);
        }
        return record;
    }

    // ---------- 请假 ----------
    public PageResult<AttLeave> pageLeave(long current, long size, Long orgId, String approveStatus) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<AttLeave> qw = new LambdaQueryWrapper<AttLeave>()
                .eq(AttLeave::getOrgId, oid)
                .eq(approveStatus != null && !approveStatus.isBlank(), AttLeave::getApproveStatus, approveStatus);
        qw.orderByDesc(AttLeave::getCreatedAt);
        return PageResult.of(leaveMapper.selectPage(new Page<>(current, size), qw));
    }

    /** 请假申请（家长端/班主任代请假） */
    @Transactional
    public AttLeave leaveApply(AttLeave leave) {
        Long oid = resolveOrgId(leave.getOrgId());
        leave.setOrgId(oid);
        leave.setApplyBy(UserContext.userId());
        if (leave.getApproveStatus() == null || leave.getApproveStatus().isBlank()) {
            leave.setApproveStatus("pending");
        }
        leaveMapper.insert(leave);
        return leave;
    }

    /** 请假审批（通过后自动同步缺勤，剔除无效考勤；未通过则补录） */
    @Transactional
    public AttLeave leaveApprove(Long id, String approveStatus, String remark) {
        AttLeave leave = leaveMapper.selectById(id);
        if (leave == null) {
            throw new BusinessException("请假记录不存在");
        }
        leave.setApproveStatus(approveStatus);
        leave.setApproveBy(UserContext.userId());
        leave.setApproveAt(LocalDateTime.now());
        leave.setApproveRemark(remark == null ? "" : remark);
        leaveMapper.updateById(leave);
        // 通过后同步考勤记录状态为 leave（请假剔除）
        if ("approved".equals(approveStatus)) {
            recordMapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<AttStudentRecord>()
                    .eq(AttStudentRecord::getOrgId, leave.getOrgId())
                    .eq(AttStudentRecord::getStudentId, leave.getStudentId())
                    .eq(AttStudentRecord::getAttDate, leave.getStartTime().toLocalDate())
                    .set(AttStudentRecord::getStatus, "leave"));
        }
        return leave;
    }
}
