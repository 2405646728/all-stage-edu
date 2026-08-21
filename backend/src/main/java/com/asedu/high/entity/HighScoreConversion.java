package com.asedu.high.entity;

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

/** 新高考等级赋分规则表 —— 对应 db 表 high_score_conversion */
@Data
@TableName("high_score_conversion")
public class HighScoreConversion implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String subjectCode;
    private String gradeBand;
    private BigDecimal rankFrom;
    private BigDecimal rankTo;
    private Integer scoreFrom;
    private Integer scoreTo;
    private Long termId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}