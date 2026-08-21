package com.asedu.exam.mapper;

import com.asedu.exam.entity.ExamSubject;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** ExamSubject —— 对应 db 表，见实体注释 */
@Mapper
public interface ExamSubjectMapper extends BaseMapper<ExamSubject> {
}
