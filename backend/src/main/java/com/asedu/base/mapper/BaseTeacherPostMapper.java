package com.asedu.base.mapper;

import com.asedu.base.entity.BaseTeacherPost;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** BaseTeacherPost —— 对应 db 表，见实体注释 */
@Mapper
public interface BaseTeacherPostMapper extends BaseMapper<BaseTeacherPost> {
}
