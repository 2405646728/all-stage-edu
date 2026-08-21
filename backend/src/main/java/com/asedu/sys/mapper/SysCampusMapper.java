package com.asedu.sys.mapper;

import com.asedu.sys.entity.SysCampus;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** SysCampus —— 对应 db 表，见实体注释 */
@Mapper
public interface SysCampusMapper extends BaseMapper<SysCampus> {
}
