package com.asedu.sys.mapper;

import com.asedu.sys.entity.SysLogLogin;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** SysLogLogin —— 对应 db 表，见实体注释 */
@Mapper
public interface SysLogLoginMapper extends BaseMapper<SysLogLogin> {
}
