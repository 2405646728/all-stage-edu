package com.asedu.uni.mapper;

import com.asedu.uni.entity.UniClub;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** UniClub —— 对应 db 表，见实体注释 */
@Mapper
public interface UniClubMapper extends BaseMapper<UniClub> {
}
