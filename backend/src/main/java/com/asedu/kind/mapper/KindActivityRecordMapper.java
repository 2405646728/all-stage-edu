package com.asedu.kind.mapper;

import com.asedu.kind.entity.KindActivityRecord;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** KindActivityRecord —— 对应 db 表，见实体注释 */
@Mapper
public interface KindActivityRecordMapper extends BaseMapper<KindActivityRecord> {
}
