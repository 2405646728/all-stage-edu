package com.asedu.kind.mapper;

import com.asedu.kind.entity.KindMeal;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** KindMeal —— 对应 db 表，见实体注释 */
@Mapper
public interface KindMealMapper extends BaseMapper<KindMeal> {
}
