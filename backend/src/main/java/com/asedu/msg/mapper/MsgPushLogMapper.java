package com.asedu.msg.mapper;

import com.asedu.msg.entity.MsgPushLog;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** MsgPushLog —— 对应 db 表，见实体注释 */
@Mapper
public interface MsgPushLogMapper extends BaseMapper<MsgPushLog> {
}
