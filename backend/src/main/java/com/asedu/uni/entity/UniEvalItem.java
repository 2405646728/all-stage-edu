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

/** 综测申报项表 —— 对应 db 表 uni_eval_item */
@Data
@TableName("uni_eval_item")
public class UniEvalItem implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long schoolYearId;
    private String itemType;
    private String itemName;
    private String evidenceFile;
    private BigDecimal applyScore;
    private String auditStatus;
    private Long auditBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}