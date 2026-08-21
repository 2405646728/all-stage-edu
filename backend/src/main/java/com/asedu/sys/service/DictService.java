package com.asedu.sys.service;

import com.asedu.sys.entity.SysDictItem;
import com.asedu.sys.entity.SysDictType;
import com.asedu.sys.mapper.SysDictItemMapper;
import com.asedu.sys.mapper.SysDictTypeMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 全局基础字典服务（字典全局复用，学段差异化渲染支撑）
 */
@Service
@RequiredArgsConstructor
public class DictService {

    private final SysDictTypeMapper typeMapper;
    private final SysDictItemMapper itemMapper;

    public List<SysDictType> listTypes(String keyword) {
        LambdaQueryWrapper<SysDictType> qw = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            qw.and(w -> w.like(SysDictType::getTypeCode, keyword).or().like(SysDictType::getTypeName, keyword));
        }
        qw.orderByAsc(SysDictType::getTypeCode);
        return typeMapper.selectList(qw);
    }

    public List<SysDictItem> listItems(String typeCode, String stage) {
        return itemMapper.selectList(new LambdaQueryWrapper<SysDictItem>()
                .eq(SysDictItem::getTypeCode, typeCode)
                .and(stage != null && !stage.isBlank(),
                        w -> w.isNull(SysDictItem::getStage).or().eq(SysDictItem::getStage, stage))
                .orderByAsc(SysDictItem::getSortNo));
    }

    @Transactional
    public SysDictType saveType(SysDictType type) {
        if (type.getId() == null) {
            typeMapper.insert(type);
        } else {
            typeMapper.updateById(type);
        }
        return type;
    }

    @Transactional
    public void removeType(Long id) {
        typeMapper.deleteById(id);
        // 级联删除字典项（逻辑结构完整）
        itemMapper.delete(new LambdaQueryWrapper<SysDictItem>()
                .eq(SysDictItem::getTypeCode, typeMapper.selectById(id).getTypeCode()));
    }

    @Transactional
    public SysDictItem saveItem(SysDictItem item) {
        if (item.getId() == null) {
            itemMapper.insert(item);
        } else {
            itemMapper.updateById(item);
        }
        return item;
    }

    @Transactional
    public void removeItem(Long id) {
        itemMapper.deleteById(id);
    }
}
