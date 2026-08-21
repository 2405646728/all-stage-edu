package com.asedu.base.mapper;

import com.asedu.base.entity.BaseTeacher;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** BaseTeacher —— 对应 db 表，见实体注释 */
@Mapper
public interface BaseTeacherMapper extends BaseMapper<BaseTeacher> {
}
