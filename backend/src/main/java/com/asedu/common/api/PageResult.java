package com.asedu.common.api;

import com.baomidou.mybatisplus.core.metadata.IPage;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 分页统一返回
 */
@Data
public class PageResult<T> implements Serializable {

    private long total;
    private long pages;
    private long current;
    private long size;
    private List<T> records;

    public static <T> PageResult<T> of(IPage<T> page) {
        PageResult<T> pr = new PageResult<>();
        pr.setTotal(page.getTotal());
        pr.setPages(page.getPages());
        pr.setCurrent(page.getCurrent());
        pr.setSize(page.getSize());
        pr.setRecords(page.getRecords());
        return pr;
    }
}
