package com.asedu.msg.mapper;

import com.asedu.msg.entity.MsgMessage;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** MsgMessage —— 对应 db 表，见实体注释 */
@Mapper
public interface MsgMessageMapper extends BaseMapper<MsgMessage> {
}
