package com.asedu.gate.mapper;

import com.asedu.gate.entity.GateVisitor;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** GateVisitor —— 对应 db 表，见实体注释 */
@Mapper
public interface GateVisitorMapper extends BaseMapper<GateVisitor> {
}
