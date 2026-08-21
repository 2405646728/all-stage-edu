package com.asedu.base.controller;

import com.asedu.base.entity.BaseClass;
import com.asedu.base.entity.BaseGrade;
import com.asedu.base.entity.BaseSchoolYear;
import com.asedu.base.entity.BaseTerm;
import com.asedu.base.service.BaseArchService;
import com.asedu.common.api.R;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 组织架构：学年/学期/年级/班级（全学段统一底座） */
@RestController
@RequestMapping("/api/base/arch")
@RequiredArgsConstructor
public class BaseArchController {

    private final BaseArchService archService;

    @GetMapping("/school-year/list")
    public R<List<BaseSchoolYear>> listSchoolYears(@RequestParam(required = false) Long orgId) {
        return R.ok(archService.listSchoolYears(orgId));
    }

    @PostMapping("/school-year/save")
    public R<BaseSchoolYear> saveSchoolYear(@RequestBody BaseSchoolYear entity) {
        return R.ok(archService.saveSchoolYear(entity));
    }

    @DeleteMapping("/school-year/{id}")
    public R<Void> removeSchoolYear(@PathVariable Long id) {
        archService.removeSchoolYear(id);
        return R.ok();
    }

    @GetMapping("/term/list")
    public R<List<BaseTerm>> listTerms(@RequestParam(required = false) Long orgId,
                                       @RequestParam(required = false) Long schoolYearId) {
        return R.ok(archService.listTerms(orgId, schoolYearId));
    }

    @PostMapping("/term/save")
    public R<BaseTerm> saveTerm(@RequestBody BaseTerm entity) {
        return R.ok(archService.saveTerm(entity));
    }

    @GetMapping("/grade/list")
    public R<List<BaseGrade>> listGrades(@RequestParam(required = false) Long orgId,
                                         @RequestParam(required = false) Long schoolYearId) {
        return R.ok(archService.listGrades(orgId, schoolYearId));
    }

    @PostMapping("/grade/save")
    public R<BaseGrade> saveGrade(@RequestBody BaseGrade entity) {
        return R.ok(archService.saveGrade(entity));
    }

    @DeleteMapping("/grade/{id}")
    public R<Void> removeGrade(@PathVariable Long id) {
        archService.removeGrade(id);
        return R.ok();
    }

    @GetMapping("/class/list")
    public R<List<BaseClass>> listClasses(@RequestParam(required = false) Long orgId,
                                          @RequestParam(required = false) Long gradeId) {
        return R.ok(archService.listClasses(orgId, gradeId));
    }

    @PostMapping("/class/save")
    public R<BaseClass> saveClass(@RequestBody BaseClass entity) {
        return R.ok(archService.saveClass(entity));
    }

    @DeleteMapping("/class/{id}")
    public R<Void> removeClass(@PathVariable Long id) {
        archService.removeClass(id);
        return R.ok();
    }
}
