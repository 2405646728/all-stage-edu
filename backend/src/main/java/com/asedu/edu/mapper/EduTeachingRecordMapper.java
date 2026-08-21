package com.asedu.edu.mapper;

import com.asedu.edu.entity.EduTeachingRecord;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** EduTeachingRecord —— 对应 db 表，见实体注释 */
@Mapper
public interface EduTeachingRecordMapper extends BaseMapper<EduTeachingRecord> {
}
