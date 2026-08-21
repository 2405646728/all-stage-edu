package com.asedu.base.mapper;

import com.asedu.base.entity.BaseClassStudent;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** BaseClassStudent —— 对应 db 表，见实体注释 */
@Mapper
public interface BaseClassStudentMapper extends BaseMapper<BaseClassStudent> {
}
