package com.asedu.base.mapper;

import com.asedu.base.entity.BaseStudent;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** BaseStudent —— 对应 db 表，见实体注释 */
@Mapper
public interface BaseStudentMapper extends BaseMapper<BaseStudent> {
}
