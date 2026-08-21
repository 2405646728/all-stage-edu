package com.asedu.fin.entity;

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

/** 收费项目配置表 —— 对应 db 表 fin_fee_item */
@Data
@TableName("fin_fee_item")
public class FinFeeItem implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String itemCode;
    private String itemName;
    private String feeType;
    private String stageScope;
    private String chargeCycle;
    private BigDecimal defaultAmount;
    private String description;
    private Integer status;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
    @TableLogic
    private Integer isDeleted;
}