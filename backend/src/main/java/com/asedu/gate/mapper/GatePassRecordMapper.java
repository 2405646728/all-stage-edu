package com.asedu.gate.mapper;

import com.asedu.gate.entity.GatePassRecord;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** GatePassRecord —— 对应 db 表，见实体注释 */
@Mapper
public interface GatePassRecordMapper extends BaseMapper<GatePassRecord> {
}
