package com.asedu.uni.mapper;

import com.asedu.uni.entity.UniHealthRecord;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** UniHealthRecord —— 对应 db 表，见实体注释 */
@Mapper
public interface UniHealthRecordMapper extends BaseMapper<UniHealthRecord> {
}
