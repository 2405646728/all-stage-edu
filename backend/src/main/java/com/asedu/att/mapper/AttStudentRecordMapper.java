package com.asedu.att.mapper;

import com.asedu.att.entity.AttStudentRecord;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** AttStudentRecord —— 对应 db 表，见实体注释 */
@Mapper
public interface AttStudentRecordMapper extends BaseMapper<AttStudentRecord> {
}
