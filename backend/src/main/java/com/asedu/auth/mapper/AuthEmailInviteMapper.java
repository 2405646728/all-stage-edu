package com.asedu.auth.mapper;

import com.asedu.auth.entity.AuthEmailInvite;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** AuthEmailInvite —— 对应 db 表，见实体注释 */
@Mapper
public interface AuthEmailInviteMapper extends BaseMapper<AuthEmailInvite> {
}
