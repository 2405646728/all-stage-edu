package com.asedu.base.mapper;

import com.asedu.base.entity.BaseStudentHealth;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** BaseStudentHealth —— 对应 db 表，见实体注释 */
@Mapper
public interface BaseStudentHealthMapper extends BaseMapper<BaseStudentHealth> {
}
