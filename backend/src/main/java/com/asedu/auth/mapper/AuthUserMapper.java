package com.asedu.auth.mapper;

import com.asedu.auth.entity.AuthUser;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AuthUserMapper extends BaseMapper<AuthUser> {
}
