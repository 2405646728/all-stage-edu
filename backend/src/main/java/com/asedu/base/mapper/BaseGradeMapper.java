package com.asedu.base.mapper;

import com.asedu.base.entity.BaseGrade;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** BaseGrade —— 对应 db 表，见实体注释 */
@Mapper
public interface BaseGradeMapper extends BaseMapper<BaseGrade> {
}
