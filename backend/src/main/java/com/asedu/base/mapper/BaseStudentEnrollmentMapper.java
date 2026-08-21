package com.asedu.base.mapper;

import com.asedu.base.entity.BaseStudentEnrollment;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** BaseStudentEnrollment —— 对应 db 表，见实体注释 */
@Mapper
public interface BaseStudentEnrollmentMapper extends BaseMapper<BaseStudentEnrollment> {
}
