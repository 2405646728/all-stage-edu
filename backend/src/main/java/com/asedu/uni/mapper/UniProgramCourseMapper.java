package com.asedu.uni.mapper;

import com.asedu.uni.entity.UniProgramCourse;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** UniProgramCourse —— 对应 db 表，见实体注释 */
@Mapper
public interface UniProgramCourseMapper extends BaseMapper<UniProgramCourse> {
}
