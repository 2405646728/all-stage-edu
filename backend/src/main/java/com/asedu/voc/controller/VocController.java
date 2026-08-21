package com.asedu.voc.controller;

import com.asedu.common.api.PageResult;
import com.asedu.common.api.R;
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
import com.asedu.voc.service.VocService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 职高专属（专业/实训/考证/校企/实习/就业） */
@RestController
@RequestMapping("/api/voc")
@RequiredArgsConstructor
public class VocController {

    private final VocService vocService;

    @GetMapping("/major/list")
    public R<List<VocMajor>> listMajors(@RequestParam(required = false) Long orgId) {
        return R.ok(vocService.listMajors(orgId));
    }

    @PostMapping("/major/save")
    public R<VocMajor> saveMajor(@RequestBody VocMajor major) {
        return R.ok(vocService.saveMajor(major));
    }

    @GetMapping("/site/list")
    public R<List<VocTrainingSite>> listSites(@RequestParam(required = false) Long orgId) {
        return R.ok(vocService.listSites(orgId));
    }

    @PostMapping("/site/save")
    public R<VocTrainingSite> saveSite(@RequestBody VocTrainingSite site) {
        return R.ok(vocService.saveSite(site));
    }

    @GetMapping("/device/list")
    public R<List<VocTrainingDevice>> listDevices(@RequestParam(required = false) Long orgId,
                                                  @RequestParam(required = false) Long siteId) {
        return R.ok(vocService.listDevices(orgId, siteId));
    }

    @PostMapping("/device/save")
    public R<VocTrainingDevice> saveDevice(@RequestBody VocTrainingDevice device) {
        return R.ok(vocService.saveDevice(device));
    }

    @PostMapping("/borrow/save")
    public R<VocDeviceBorrow> saveBorrow(@RequestBody VocDeviceBorrow borrow) {
        return R.ok(vocService.saveBorrow(borrow));
    }

    @GetMapping("/plan/list")
    public R<List<VocTrainingPlan>> listPlans(@RequestParam(required = false) Long orgId,
                                              @RequestParam(required = false) Long classId) {
        return R.ok(vocService.listPlans(orgId, classId));
    }

    @PostMapping("/plan/save")
    public R<VocTrainingPlan> savePlan(@RequestBody VocTrainingPlan plan) {
        return R.ok(vocService.savePlan(plan));
    }

    @GetMapping("/record/page")
    public R<PageResult<VocTrainingRecord>> pageRecords(@RequestParam(defaultValue = "1") long current,
                                                        @RequestParam(defaultValue = "10") long size,
                                                        @RequestParam(required = false) Long orgId,
                                                        @RequestParam(required = false) Long planId) {
        return R.ok(vocService.pageRecords(current, size, orgId, planId));
    }

    @PostMapping("/record/save")
    public R<VocTrainingRecord> saveRecord(@RequestBody VocTrainingRecord record) {
        return R.ok(vocService.saveRecord(record));
    }

    @GetMapping("/certificate/list")
    public R<List<VocCertificate>> listCertificates(@RequestParam(required = false) Long orgId,
                                                    @RequestParam(required = false) Long studentId) {
        return R.ok(vocService.listCertificates(orgId, studentId));
    }

    @PostMapping("/certificate/save")
    public R<VocCertificate> saveCertificate(@RequestBody VocCertificate cert) {
        return R.ok(vocService.saveCertificate(cert));
    }

    @GetMapping("/company/list")
    public R<List<VocCompany>> listCompanies(@RequestParam(required = false) Long orgId) {
        return R.ok(vocService.listCompanies(orgId));
    }

    @PostMapping("/company/save")
    public R<VocCompany> saveCompany(@RequestBody VocCompany company) {
        return R.ok(vocService.saveCompany(company));
    }

    @GetMapping("/internship/page")
    public R<PageResult<VocInternship>> pageInternships(@RequestParam(defaultValue = "1") long current,
                                                        @RequestParam(defaultValue = "10") long size,
                                                        @RequestParam(required = false) Long orgId,
                                                        @RequestParam(required = false) String internStatus) {
        return R.ok(vocService.pageInternships(current, size, orgId, internStatus));
    }

    @PostMapping("/internship/save")
    public R<VocInternship> saveInternship(@RequestBody VocInternship internship) {
        return R.ok(vocService.saveInternship(internship));
    }

    @GetMapping("/internship/checkin/list")
    public R<List<VocInternshipCheckin>> listCheckins(@RequestParam Long internshipId) {
        return R.ok(vocService.listCheckins(internshipId));
    }

    @PostMapping("/internship/checkin/save")
    public R<VocInternshipCheckin> saveCheckin(@RequestBody VocInternshipCheckin checkin) {
        return R.ok(vocService.saveCheckin(checkin));
    }

    @GetMapping("/internship/report/list")
    public R<List<VocInternshipReport>> listReports(@RequestParam Long internshipId) {
        return R.ok(vocService.listReports(internshipId));
    }

    @PostMapping("/internship/report/save")
    public R<VocInternshipReport> saveReport(@RequestBody VocInternshipReport report) {
        return R.ok(vocService.saveReport(report));
    }

    @GetMapping("/employment/list")
    public R<List<VocEmployment>> listEmployments(@RequestParam(required = false) Long orgId,
                                                  @RequestParam(required = false) Integer graduateYear) {
        return R.ok(vocService.listEmployments(orgId, graduateYear));
    }

    @PostMapping("/employment/save")
    public R<VocEmployment> saveEmployment(@RequestBody VocEmployment employment) {
        return R.ok(vocService.saveEmployment(employment));
    }
}
