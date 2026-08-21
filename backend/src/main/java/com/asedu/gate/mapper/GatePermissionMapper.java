package com.asedu.gate.mapper;

import com.asedu.gate.entity.GatePermission;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** GatePermission —— 对应 db 表，见实体注释 */
@Mapper
public interface GatePermissionMapper extends BaseMapper<GatePermission> {
}
