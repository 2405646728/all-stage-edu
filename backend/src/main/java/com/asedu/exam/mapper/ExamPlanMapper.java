package com.asedu.exam.mapper;

import com.asedu.exam.entity.ExamPlan;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** ExamPlan —— 对应 db 表，见实体注释 */
@Mapper
public interface ExamPlanMapper extends BaseMapper<ExamPlan> {
}
