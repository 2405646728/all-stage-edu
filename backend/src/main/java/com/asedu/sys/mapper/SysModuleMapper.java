package com.asedu.sys.mapper;

import com.asedu.sys.entity.SysModule;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** SysModule —— 对应 db 表，见实体注释 */
@Mapper
public interface SysModuleMapper extends BaseMapper<SysModule> {
}
