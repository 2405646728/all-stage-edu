package com.asedu.sys.mapper;

import com.asedu.sys.entity.SysLogOperation;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** SysLogOperation —— 对应 db 表，见实体注释 */
@Mapper
public interface SysLogOperationMapper extends BaseMapper<SysLogOperation> {
}
