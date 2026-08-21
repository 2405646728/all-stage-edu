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

/** 高校健康体质记录表 —— 对应 db 表 uni_health_record */
@Data
@TableName("uni_health_record")
public class UniHealthRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long schoolYearId;
    private String recordType;
    private BigDecimal heightCm;
    private BigDecimal weightKg;
    private BigDecimal score;
    private String resultDetail;
    private Integer isAbnormal;
    private Long recorderId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}