package com.asedu.base.mapper;

import com.asedu.base.entity.BaseFile;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** BaseFile —— 对应 db 表，见实体注释 */
@Mapper
public interface BaseFileMapper extends BaseMapper<BaseFile> {
}
