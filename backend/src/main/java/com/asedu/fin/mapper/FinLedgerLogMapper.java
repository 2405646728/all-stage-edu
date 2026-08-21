package com.asedu.fin.mapper;

import com.asedu.fin.entity.FinLedgerLog;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** FinLedgerLog —— 对应 db 表，见实体注释 */
@Mapper
public interface FinLedgerLogMapper extends BaseMapper<FinLedgerLog> {
}
