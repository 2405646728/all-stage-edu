package com.asedu.uni.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** 社团成员表 —— 对应 db 表 uni_club_member */
@Data
@TableName("uni_club_member")
public class UniClubMember implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long clubId;
    private Long studentId;
    private String role;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime joinAt;
    private Integer status;
}