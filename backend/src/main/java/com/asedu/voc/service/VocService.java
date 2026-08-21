package com.asedu.voc.service;

import com.asedu.common.api.PageResult;
import com.asedu.common.exception.BusinessException;
import com.asedu.security.UserContext;
import com.asedu.voc.entity.VocCertificate;
import com.asedu.voc.entity.VocCompany;
import com.asedu.voc.entity.VocDeviceBorrow;
import com.asedu.voc.entity.VocEmployment;
import com.asedu.voc.entity.VocInternship;
import com.asedu.voc.entity.VocInternshipCheckin;
import com.asedu.voc.entity.VocInternshipReport;
import com.asedu.voc.entity.VocMajor;
import com.asedu.voc.entity.VocTrainingDevice;
import com.asedu.voc.entity.VocTrainingPlan;
import com.asedu.voc.entity.VocTrainingRecord;
import com.asedu.voc.entity.VocTrainingSite;
import com.asedu.voc.mapper.VocCertificateMapper;
import com.asedu.voc.mapper.VocCompanyMapper;
import com.asedu.voc.mapper.VocDeviceBorrowMapper;
import com.asedu.voc.mapper.VocEmploymentMapper;
import com.asedu.voc.mapper.VocInternshipCheckinMapper;
import com.asedu.voc.mapper.VocInternshipMapper;
import com.asedu.voc.mapper.VocInternshipReportMapper;
import com.asedu.voc.mapper.VocMajorMapper;
import com.asedu.voc.mapper.VocTrainingDeviceMapper;
import com.asedu.voc.mapper.VocTrainingPlanMapper;
import com.asedu.voc.mapper.VocTrainingRecordMapper;
import com.asedu.voc.mapper.VocTrainingSiteMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 职高专属服务：专业/实训场地设备/实训计划记录/考证/校企/顶岗实习/就业
 */
@Service
@RequiredArgsConstructor
public class VocService {

    private final VocMajorMapper majorMapper;
    private final VocTrainingSiteMapper siteMapper;
    private final VocTrainingDeviceMapper deviceMapper;
    private final VocDeviceBorrowMapper borrowMapper;
    private final VocTrainingPlanMapper planMapper;
    private final VocTrainingRecordMapper recordMapper;
    private final VocCertificateMapper certificateMapper;
    private final VocCompanyMapper companyMapper;
    private final VocInternshipMapper internshipMapper;
    private final VocInternshipCheckinMapper checkinMapper;
    private final VocInternshipReportMapper reportMapper;
    private final VocEmploymentMapper employmentMapper;

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

    // ---------- 专业 ----------
    public List<VocMajor> listMajors(Long orgId) {
        Long oid = resolveOrgId(orgId);
        return majorMapper.selectList(new LambdaQueryWrapper<VocMajor>()
                .eq(VocMajor::getOrgId, oid).orderByAsc(VocMajor::getMajorCode));
    }

    @Transactional
    public VocMajor saveMajor(VocMajor major) {
        major.setOrgId(resolveOrgId(major.getOrgId()));
        major.setCreatedBy(UserContext.userId());
        if (major.getId() == null) {
            majorMapper.insert(major);
        } else {
            majorMapper.updateById(major);
        }
        return major;
    }

    // ---------- 实训场地/设备/借用 ----------
    public List<VocTrainingSite> listSites(Long orgId) {
        Long oid = resolveOrgId(orgId);
        return siteMapper.selectList(new LambdaQueryWrapper<VocTrainingSite>()
                .eq(VocTrainingSite::getOrgId, oid));
    }

    @Transactional
    public VocTrainingSite saveSite(VocTrainingSite site) {
        site.setOrgId(resolveOrgId(site.getOrgId()));
        if (site.getId() == null) {
            siteMapper.insert(site);
        } else {
            siteMapper.updateById(site);
        }
        return site;
    }

    public List<VocTrainingDevice> listDevices(Long orgId, Long siteId) {
        Long oid = resolveOrgId(orgId);
        return deviceMapper.selectList(new LambdaQueryWrapper<VocTrainingDevice>()
                .eq(VocTrainingDevice::getOrgId, oid)
                .eq(siteId != null, VocTrainingDevice::getSiteId, siteId));
    }

    @Transactional
    public VocTrainingDevice saveDevice(VocTrainingDevice device) {
        device.setOrgId(resolveOrgId(device.getOrgId()));
        if (device.getId() == null) {
            deviceMapper.insert(device);
        } else {
            deviceMapper.updateById(device);
        }
        return device;
    }

    @Transactional
    public VocDeviceBorrow saveBorrow(VocDeviceBorrow borrow) {
        borrow.setOrgId(resolveOrgId(borrow.getOrgId()));
        borrow.setOperatorId(UserContext.userId());
        if (borrow.getStatus() == null || borrow.getStatus().isBlank()) {
            borrow.setStatus("borrowed");
        }
        if (borrow.getId() == null) {
            borrowMapper.insert(borrow);
        } else {
            borrowMapper.updateById(borrow);
        }
        return borrow;
    }

    // ---------- 实训计划与记录 ----------
    public List<VocTrainingPlan> listPlans(Long orgId, Long classId) {
        Long oid = resolveOrgId(orgId);
        return planMapper.selectList(new LambdaQueryWrapper<VocTrainingPlan>()
                .eq(VocTrainingPlan::getOrgId, oid)
                .eq(classId != null, VocTrainingPlan::getClassId, classId)
                .orderByDesc(VocTrainingPlan::getStartDate));
    }

    @Transactional
    public VocTrainingPlan savePlan(VocTrainingPlan plan) {
        plan.setOrgId(resolveOrgId(plan.getOrgId()));
        if (plan.getId() == null) {
            planMapper.insert(plan);
        } else {
            planMapper.updateById(plan);
        }
        return plan;
    }

    public PageResult<VocTrainingRecord> pageRecords(long current, long size, Long orgId, Long planId) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<VocTrainingRecord> qw = new LambdaQueryWrapper<VocTrainingRecord>()
                .eq(VocTrainingRecord::getOrgId, oid)
                .eq(planId != null, VocTrainingRecord::getPlanId, planId)
                .orderByDesc(VocTrainingRecord::getTrainingDate);
        return PageResult.of(recordMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public VocTrainingRecord saveRecord(VocTrainingRecord record) {
        record.setOrgId(resolveOrgId(record.getOrgId()));
        record.setRecorderId(UserContext.userId());
        if (record.getId() == null) {
            recordMapper.insert(record);
        } else {
            recordMapper.updateById(record);
        }
        return record;
    }

    // ---------- 考证 ----------
    public List<VocCertificate> listCertificates(Long orgId, Long studentId) {
        Long oid = resolveOrgId(orgId);
        return certificateMapper.selectList(new LambdaQueryWrapper<VocCertificate>()
                .eq(VocCertificate::getOrgId, oid)
                .eq(studentId != null, VocCertificate::getStudentId, studentId));
    }

    @Transactional
    public VocCertificate saveCertificate(VocCertificate cert) {
        cert.setOrgId(resolveOrgId(cert.getOrgId()));
        cert.setOperatorId(UserContext.userId());
        if (cert.getResult() == null || cert.getResult().isBlank()) {
            cert.setResult("pending");
        }
        if (cert.getId() == null) {
            certificateMapper.insert(cert);
        } else {
            certificateMapper.updateById(cert);
        }
        return cert;
    }

    // ---------- 校企合作 ----------
    public List<VocCompany> listCompanies(Long orgId) {
        Long oid = resolveOrgId(orgId);
        return companyMapper.selectList(new LambdaQueryWrapper<VocCompany>()
                .eq(VocCompany::getOrgId, oid).orderByDesc(VocCompany::getCreatedAt));
    }

    @Transactional
    public VocCompany saveCompany(VocCompany company) {
        company.setOrgId(resolveOrgId(company.getOrgId()));
        company.setCreatedBy(UserContext.userId());
        if (company.getId() == null) {
            companyMapper.insert(company);
        } else {
            companyMapper.updateById(company);
        }
        return company;
    }

    // ---------- 顶岗实习 ----------
    public PageResult<VocInternship> pageInternships(long current, long size, Long orgId, String internStatus) {
        Long oid = resolveOrgId(orgId);
        LambdaQueryWrapper<VocInternship> qw = new LambdaQueryWrapper<VocInternship>()
                .eq(VocInternship::getOrgId, oid)
                .eq(internStatus != null && !internStatus.isBlank(), VocInternship::getInternStatus, internStatus)
                .orderByDesc(VocInternship::getCreatedAt);
        return PageResult.of(internshipMapper.selectPage(new Page<>(current, size), qw));
    }

    @Transactional
    public VocInternship saveInternship(VocInternship internship) {
        internship.setOrgId(resolveOrgId(internship.getOrgId()));
        internship.setOperatorId(UserContext.userId());
        if (internship.getInternStatus() == null || internship.getInternStatus().isBlank()) {
            internship.setInternStatus("reported");
        }
        if (internship.getId() == null) {
            internshipMapper.insert(internship);
        } else {
            internshipMapper.updateById(internship);
        }
        return internship;
    }

    public List<VocInternshipCheckin> listCheckins(Long internshipId) {
        return checkinMapper.selectList(new LambdaQueryWrapper<VocInternshipCheckin>()
                .eq(VocInternshipCheckin::getInternshipId, internshipId)
                .orderByDesc(VocInternshipCheckin::getCheckinDate));
    }

    @Transactional
    public VocInternshipCheckin saveCheckin(VocInternshipCheckin checkin) {
        checkin.setOrgId(resolveOrgId(checkin.getOrgId()));
        if (checkin.getStatus() == null || checkin.getStatus().isBlank()) {
            checkin.setStatus("on_duty");
        }
        if (checkin.getId() == null) {
            checkinMapper.insert(checkin);
        } else {
            checkinMapper.updateById(checkin);
        }
        return checkin;
    }

    public List<VocInternshipReport> listReports(Long internshipId) {
        return reportMapper.selectList(new LambdaQueryWrapper<VocInternshipReport>()
                .eq(VocInternshipReport::getInternshipId, internshipId)
                .orderByDesc(VocInternshipReport::getSubmittedAt));
    }

    @Transactional
    public VocInternshipReport saveReport(VocInternshipReport report) {
        report.setOrgId(resolveOrgId(report.getOrgId()));
        if (report.getId() == null) {
            reportMapper.insert(report);
        } else {
            reportMapper.updateById(report);
        }
        return report;
    }

    // ---------- 就业 ----------
    public List<VocEmployment> listEmployments(Long orgId, Integer graduateYear) {
        Long oid = resolveOrgId(orgId);
        return employmentMapper.selectList(new LambdaQueryWrapper<VocEmployment>()
                .eq(VocEmployment::getOrgId, oid)
                .eq(graduateYear != null, VocEmployment::getGraduateYear, graduateYear));
    }

    @Transactional
    public VocEmployment saveEmployment(VocEmployment employment) {
        employment.setOrgId(resolveOrgId(employment.getOrgId()));
        employment.setOperatorId(UserContext.userId());
        if (employment.getId() == null) {
            employmentMapper.insert(employment);
        } else {
            employmentMapper.updateById(employment);
        }
        return employment;
    }
}
