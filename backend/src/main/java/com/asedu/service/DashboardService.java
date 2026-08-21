package com.asedu.service;

import com.asedu.base.mapper.BaseClassMapper;
import com.asedu.base.mapper.BaseStudentMapper;
import com.asedu.base.mapper.BaseTeacherMapper;
import com.asedu.att.mapper.AttStudentRecordMapper;
import com.asedu.att.mapper.AttLeaveMapper;
import com.asedu.fin.mapper.FinBillMapper;
import com.asedu.security.UserContext;
import com.asedu.sys.mapper.SysAlertMapper;
import com.asedu.sys.mapper.SysLogOperationMapper;
import com.asedu.sys.mapper.SysOrgMapper;
import com.asedu.auth.mapper.AuthUserMapper;
import com.asedu.auth.entity.AuthUser;
import com.asedu.sys.entity.SysOrg;
import com.asedu.base.entity.BaseStudent;
import com.asedu.base.entity.BaseTeacher;
import com.asedu.base.entity.BaseClass;
import com.asedu.att.entity.AttStudentRecord;
import com.asedu.att.entity.AttLeave;
import com.asedu.fin.entity.FinBill;
import com.asedu.sys.entity.SysAlert;
import com.asedu.sys.entity.SysLogOperation;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 数据看板统计服务
 * 平台看板（超管）：机构总量/用户分布/学段占比/日活/待办告警
 * 学校看板（校管）：师生班级/今日考勤/待办请假/缴费欠费
 */
@Service
@RequiredArgsConstructor
public class DashboardService {

    private final SysOrgMapper orgMapper;
    private final AuthUserMapper userMapper;
    private final BaseStudentMapper studentMapper;
    private final BaseTeacherMapper teacherMapper;
    private final BaseClassMapper classMapper;
    private final AttStudentRecordMapper attMapper;
    private final AttLeaveMapper leaveMapper;
    private final FinBillMapper billMapper;
    private final SysAlertMapper alertMapper;
    private final SysLogOperationMapper logMapper;

    /** 平台总览（仅超管） */
    public Map<String, Object> platform() {
        Map<String, Object> data = new HashMap<>();
        data.put("orgTotal", orgMapper.selectCount(null));
        data.put("userTotal", userMapper.selectCount(null));
        data.put("studentTotal", studentMapper.selectCount(null));
        data.put("teacherTotal", teacherMapper.selectCount(null));

        // 学段占比（按机构学段统计学生数）
        Map<String, Long> stageDist = new LinkedHashMap<>();
        List<SysOrg> orgs = orgMapper.selectList(null);
        for (String stage : List.of("kindergarten", "primary", "junior", "senior", "vocational", "university")) {
            long cnt = 0;
            for (SysOrg o : orgs) {
                if (stage.equals(o.getStage())) {
                    cnt += studentMapper.selectCount(new LambdaQueryWrapper<BaseStudent>()
                            .eq(BaseStudent::getOrgId, o.getId()));
                }
            }
            stageDist.put(stage, cnt);
        }
        data.put("stageDist", stageDist);

        // 用户类型分布
        Map<String, Long> userDist = new LinkedHashMap<>();
        for (String type : List.of("school_admin", "teacher", "student", "parent", "visitor")) {
            userDist.put(type, userMapper.selectCount(new LambdaQueryWrapper<AuthUser>()
                    .eq(AuthUser::getUserType, type)));
        }
        data.put("userDist", userDist);

        data.put("todayAtt", attMapper.selectCount(new LambdaQueryWrapper<AttStudentRecord>()
                .eq(AttStudentRecord::getAttDate, LocalDate.now())));
        data.put("pendingAlerts", alertMapper.selectCount(new LambdaQueryWrapper<SysAlert>()
                .eq(SysAlert::getStatus, 0)));
        data.put("opLogTotal", logMapper.selectCount(new LambdaQueryWrapper<SysLogOperation>()));
        data.put("pendingLeaves", leaveMapper.selectCount(new LambdaQueryWrapper<AttLeave>()
                .eq(AttLeave::getApproveStatus, "pending")));
        return data;
    }

    /** 学校总览（校管/教职工） */
    public Map<String, Object> school() {
        Long orgId = UserContext.orgId();
        Map<String, Object> data = new HashMap<>();
        if (orgId == null) {
            return data;
        }
        data.put("studentTotal", studentMapper.selectCount(new LambdaQueryWrapper<BaseStudent>()
                .eq(BaseStudent::getOrgId, orgId)));
        data.put("teacherTotal", teacherMapper.selectCount(new LambdaQueryWrapper<BaseTeacher>()
                .eq(BaseTeacher::getOrgId, orgId)));
        data.put("classTotal", classMapper.selectCount(new LambdaQueryWrapper<BaseClass>()
                .eq(BaseClass::getOrgId, orgId)));
        data.put("todayAtt", attMapper.selectCount(new LambdaQueryWrapper<AttStudentRecord>()
                .eq(AttStudentRecord::getOrgId, orgId)
                .eq(AttStudentRecord::getAttDate, LocalDate.now())));
        data.put("pendingLeaves", leaveMapper.selectCount(new LambdaQueryWrapper<AttLeave>()
                .eq(AttLeave::getOrgId, orgId)
                .eq(AttLeave::getApproveStatus, "pending")));
        data.put("unpaidBills", billMapper.selectCount(new LambdaQueryWrapper<FinBill>()
                .eq(FinBill::getOrgId, orgId)
                .in(FinBill::getBillStatus, List.of("unpaid", "partial"))));
        return data;
    }
}
