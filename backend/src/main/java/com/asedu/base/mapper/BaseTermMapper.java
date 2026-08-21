package com.asedu.base.mapper;

import com.asedu.base.entity.BaseTerm;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** BaseTerm —— 对应 db 表，见实体注释 */
@Mapper
public interface BaseTermMapper extends BaseMapper<BaseTerm> {
}
