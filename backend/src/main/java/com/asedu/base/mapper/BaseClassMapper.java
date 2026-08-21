package com.asedu.base.mapper;

import com.asedu.base.entity.BaseClass;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** BaseClass —— 对应 db 表，见实体注释 */
@Mapper
public interface BaseClassMapper extends BaseMapper<BaseClass> {
}
