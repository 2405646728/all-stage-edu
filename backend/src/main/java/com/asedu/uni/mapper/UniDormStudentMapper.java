package com.asedu.uni.mapper;

import com.asedu.uni.entity.UniDormStudent;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** UniDormStudent —— 对应 db 表，见实体注释 */
@Mapper
public interface UniDormStudentMapper extends BaseMapper<UniDormStudent> {
}
