package com.asedu.sys.mapper;

import com.asedu.sys.entity.SysVersion;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** SysVersion —— 对应 db 表，见实体注释 */
@Mapper
public interface SysVersionMapper extends BaseMapper<SysVersion> {
}
