package com.asedu.edu.mapper;

import com.asedu.edu.entity.EduCourse;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** EduCourse —— 对应 db 表，见实体注释 */
@Mapper
public interface EduCourseMapper extends BaseMapper<EduCourse> {
}
