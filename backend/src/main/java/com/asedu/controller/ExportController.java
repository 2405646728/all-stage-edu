package com.asedu.controller;

import com.asedu.base.entity.BaseStudent;
import com.asedu.base.mapper.BaseStudentMapper;
import com.asedu.common.api.R;
import com.asedu.common.exception.BusinessException;
import com.asedu.common.util.CsvUtil;
import com.asedu.fin.entity.FinBill;
import com.asedu.fin.mapper.FinBillMapper;
import com.asedu.security.UserContext;
import com.asedu.sys.entity.SysOrg;
import com.asedu.sys.mapper.SysOrgMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.ByteArrayOutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/** 报表导出（CSV，Excel 兼容） */
@RestController
@RequestMapping("/api/export")
@RequiredArgsConstructor
public class ExportController {

    private final SysOrgMapper orgMapper;
    private final BaseStudentMapper studentMapper;
    private final FinBillMapper billMapper;

    private Long resolveOrgId(Long orgId) {
        if (UserContext.isSuperAdmin()) {
            if (orgId == null) {
                throw new BusinessException("平台超级管理员导出机构数据必须指定 orgId");
            }
            return orgId;
        }
        Long mine = UserContext.orgId();
        if (mine == null) {
            throw new BusinessException("当前账号未绑定机构");
        }
        return mine;
    }

    @GetMapping("/org")
    public ResponseEntity<byte[]> exportOrg() throws Exception {
        List<SysOrg> orgs = UserContext.isSuperAdmin()
                ? orgMapper.selectList(new LambdaQueryWrapper<SysOrg>().orderByAsc(SysOrg::getId))
                : orgMapper.selectList(new LambdaQueryWrapper<SysOrg>().eq(SysOrg::getId, UserContext.orgId()));
        String[] header = {"机构编码", "机构名称", "学段", "办学主体", "省", "市", "区县", "地址", "联系人", "电话", "状态", "服务截止"};
        List<String[]> rows = new ArrayList<>();
        for (SysOrg o : orgs) {
            rows.add(new String[]{o.getOrgCode(), o.getOrgName(), o.getStage(), o.getSchoolType(),
                    o.getProvince(), o.getCity(), o.getDistrict(), o.getAddress(),
                    o.getContactName(), o.getContactPhone(), String.valueOf(o.getStatus()),
                    o.getServiceEnd() == null ? "" : o.getServiceEnd().toString()});
        }
        return csv("机构台账.csv", header, rows);
    }

    @GetMapping("/student")
    public ResponseEntity<byte[]> exportStudent(@RequestParam(required = false) Long orgId) throws Exception {
        Long oid = resolveOrgId(orgId);
        List<BaseStudent> list = studentMapper.selectList(new LambdaQueryWrapper<BaseStudent>()
                .eq(BaseStudent::getOrgId, oid).orderByAsc(BaseStudent::getStudentNo));
        String[] header = {"学号/园号", "姓名", "性别", "出生日期", "身份证号", "民族", "入园/入学日期", "就读状态", "寄宿", "当前班级ID"};
        List<String[]> rows = new ArrayList<>();
        for (BaseStudent s : list) {
            rows.add(new String[]{s.getStudentNo(), s.getName(),
                    s.getGender() == 1 ? "男" : s.getGender() == 2 ? "女" : "",
                    s.getBirthDate() == null ? "" : s.getBirthDate().toString(),
                    s.getIdCard(), s.getNation(),
                    s.getAdmitDate() == null ? "" : s.getAdmitDate().toString(),
                    s.getStudyStatus(), s.getBoarder() == 1 ? "寄宿" : "走读",
                    s.getCurrentClassId() == null ? "" : String.valueOf(s.getCurrentClassId())});
        }
        return csv("学生台账.csv", header, rows);
    }

    @GetMapping("/bill")
    public ResponseEntity<byte[]> exportBill(@RequestParam(required = false) Long orgId) throws Exception {
        Long oid = resolveOrgId(orgId);
        List<FinBill> list = billMapper.selectList(new LambdaQueryWrapper<FinBill>()
                .eq(FinBill::getOrgId, oid).orderByDesc(FinBill::getCreatedAt));
        String[] header = {"账单号", "学生ID", "应缴金额", "减免金额", "已缴金额", "账单状态", "截止日期"};
        List<String[]> rows = new ArrayList<>();
        for (FinBill b : list) {
            rows.add(new String[]{b.getBillNo(), String.valueOf(b.getStudentId()),
                    b.getBillAmount() == null ? "" : b.getBillAmount().toPlainString(),
                    b.getReducedAmount() == null ? "" : b.getReducedAmount().toPlainString(),
                    b.getPaidAmount() == null ? "" : b.getPaidAmount().toPlainString(),
                    b.getBillStatus(), b.getDueDate() == null ? "" : b.getDueDate().toString()});
        }
        return csv("缴费台账.csv", header, rows);
    }

    private ResponseEntity<byte[]> csv(String filename, String[] header, List<String[]> rows) throws Exception {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        CsvUtil.write(bos, header, rows);
        byte[] data = bos.toByteArray();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"" + URLEncoder.encode(filename, StandardCharsets.UTF_8) + "\"")
                .contentType(MediaType.parseMediaType("text/csv;charset=UTF-8"))
                .body(data);
    }
}
