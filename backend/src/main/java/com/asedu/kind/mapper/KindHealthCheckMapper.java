package com.asedu.kind.mapper;

import com.asedu.kind.entity.KindHealthCheck;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** KindHealthCheck —— 对应 db 表，见实体注释 */
@Mapper
public interface KindHealthCheckMapper extends BaseMapper<KindHealthCheck> {
}
