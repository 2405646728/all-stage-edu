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

/** 缴费记录表 —— 对应 db 表 fin_payment */
@Data
@TableName("fin_payment")
public class FinPayment implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long billId;
    private Long studentId;
    private String payNo;
    private String payType;
    private BigDecimal payAmount;
    private String payWay;
    private LocalDateTime payTime;
    private String receiptFile;
    private Long operatorId;
    private String remark;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}