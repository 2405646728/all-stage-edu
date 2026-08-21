package com.asedu.fin.mapper;

import com.asedu.fin.entity.FinPayment;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** FinPayment —— 对应 db 表，见实体注释 */
@Mapper
public interface FinPaymentMapper extends BaseMapper<FinPayment> {
}
