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

/** 财务操作日志表 —— 对应 db 表 fin_ledger_log */
@Data
@TableName("fin_ledger_log")
public class FinLedgerLog implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String action;
    private String targetTable;
    private Long targetId;
    private String billNo;
    private BigDecimal amountBefore;
    private BigDecimal amountAfter;
    private String detail;
    private Long operatorId;
    private String operatorName;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}