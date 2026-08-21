package com.asedu.uni.mapper;

import com.asedu.uni.entity.UniClubMember;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** UniClubMember —— 对应 db 表，见实体注释 */
@Mapper
public interface UniClubMemberMapper extends BaseMapper<UniClubMember> {
}
