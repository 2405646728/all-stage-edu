package com.asedu.auth.mapper;

import com.asedu.auth.entity.AuthOpenItem;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** AuthOpenItem —— 对应 db 表，见实体注释 */
@Mapper
public interface AuthOpenItemMapper extends BaseMapper<AuthOpenItem> {
}
