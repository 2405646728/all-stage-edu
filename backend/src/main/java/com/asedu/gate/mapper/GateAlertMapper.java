package com.asedu.gate.mapper;

import com.asedu.gate.entity.GateAlert;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** GateAlert —— 对应 db 表，见实体注释 */
@Mapper
public interface GateAlertMapper extends BaseMapper<GateAlert> {
}
