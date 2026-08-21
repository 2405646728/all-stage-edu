package com.asedu.base.mapper;

import com.asedu.base.entity.BaseGuardian;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** BaseGuardian —— 对应 db 表，见实体注释 */
@Mapper
public interface BaseGuardianMapper extends BaseMapper<BaseGuardian> {
}
