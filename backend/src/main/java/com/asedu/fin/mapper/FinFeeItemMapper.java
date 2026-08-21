package com.asedu.fin.mapper;

import com.asedu.fin.entity.FinFeeItem;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** FinFeeItem —— 对应 db 表，见实体注释 */
@Mapper
public interface FinFeeItemMapper extends BaseMapper<FinFeeItem> {
}
