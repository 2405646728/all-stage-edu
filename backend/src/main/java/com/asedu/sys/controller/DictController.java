package com.asedu.sys.controller;

import com.asedu.common.api.R;
import com.asedu.sys.entity.SysDictItem;
import com.asedu.sys.entity.SysDictType;
import com.asedu.sys.service.DictService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** 全局基础字典（全学段通用） */
@RestController
@RequestMapping("/api/sys/dict")
@RequiredArgsConstructor
public class DictController {

    private final DictService dictService;

    @GetMapping("/type/list")
    public R<List<SysDictType>> listTypes(@RequestParam(required = false) String keyword) {
        return R.ok(dictService.listTypes(keyword));
    }

    @GetMapping("/item/list")
    public R<List<SysDictItem>> listItems(@RequestParam String typeCode, @RequestParam(required = false) String stage) {
        return R.ok(dictService.listItems(typeCode, stage));
    }

    @PostMapping("/type/save")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public R<SysDictType> saveType(@RequestBody SysDictType type) {
        return R.ok(dictService.saveType(type));
    }

    @DeleteMapping("/type/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public R<Void> removeType(@PathVariable Long id) {
        dictService.removeType(id);
        return R.ok();
    }

    @PostMapping("/item/save")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public R<SysDictItem> saveItem(@RequestBody SysDictItem item) {
        return R.ok(dictService.saveItem(item));
    }

    @DeleteMapping("/item/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public R<Void> removeItem(@PathVariable Long id) {
        dictService.removeItem(id);
        return R.ok();
    }
}
