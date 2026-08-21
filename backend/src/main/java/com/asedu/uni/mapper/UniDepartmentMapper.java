package com.asedu.uni.mapper;

import com.asedu.uni.entity.UniDepartment;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/** UniDepartment —— 对应 db 表，见实体注释 */
@Mapper
public interface UniDepartmentMapper extends BaseMapper<UniDepartment> {
}
