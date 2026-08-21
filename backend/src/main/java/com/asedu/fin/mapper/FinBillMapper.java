package com.asedu.fin.mapper;

import com.asedu.fin.entity.FinBill;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** FinBill —— 对应 db 表，见实体注释 */
@Mapper
public interface FinBillMapper extends BaseMapper<FinBill> {
}
