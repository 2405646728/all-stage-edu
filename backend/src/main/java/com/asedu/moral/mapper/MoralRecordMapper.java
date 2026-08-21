package com.asedu.moral.mapper;

import com.asedu.moral.entity.MoralRecord;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** MoralRecord —— 对应 db 表，见实体注释 */
@Mapper
public interface MoralRecordMapper extends BaseMapper<MoralRecord> {
}
