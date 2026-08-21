package com.asedu.exam.mapper;

import com.asedu.exam.entity.ExamScore;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** ExamScore —— 对应 db 表，见实体注释 */
@Mapper
public interface ExamScoreMapper extends BaseMapper<ExamScore> {
}
