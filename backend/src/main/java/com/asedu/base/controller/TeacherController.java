package com.asedu.base.controller;

import com.asedu.base.entity.BaseTeacher;
import com.asedu.base.entity.BaseTeacherPost;
import com.asedu.base.service.TeacherService;
import com.asedu.common.api.PageResult;
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

/** 师资与岗位（全学段数据底座） */
@RestController
@RequestMapping("/api/base/teacher")
@RequiredArgsConstructor
public class TeacherController {

    private final TeacherService teacherService;

    @GetMapping("/page")
    public R<PageResult<BaseTeacher>> page(@RequestParam(defaultValue = "1") long current,
                                           @RequestParam(defaultValue = "10") long size,
                                           @RequestParam(required = false) Long orgId,
                                           @RequestParam(required = false) String keyword,
                                           @RequestParam(required = false) String workStatus) {
        return R.ok(teacherService.page(current, size, orgId, keyword, workStatus));
    }

    @GetMapping("/{id}")
    public R<BaseTeacher> detail(@PathVariable Long id) {
        return R.ok(teacherService.detail(id));
    }

    @PostMapping("/save")
    public R<BaseTeacher> save(@RequestBody BaseTeacher teacher) {
        return R.ok(teacherService.save(teacher));
    }

    @DeleteMapping("/{id}")
    public R<Void> remove(@PathVariable Long id) {
        teacherService.remove(id);
        return R.ok();
    }

    @PostMapping("/post/save")
    public R<BaseTeacherPost> savePost(@RequestBody BaseTeacherPost post) {
        return R.ok(teacherService.savePost(post));
    }

    @GetMapping("/post/list")
    public R<List<BaseTeacherPost>> listPosts(@RequestParam Long teacherId) {
        return R.ok(teacherService.listPosts(teacherId));
    }
}
