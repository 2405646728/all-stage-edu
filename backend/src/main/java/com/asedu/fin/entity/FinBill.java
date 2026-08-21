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

/** 学生缴费账单表 —— 对应 db 表 fin_bill */
@Data
@TableName("fin_bill")
public class FinBill implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private String billNo;
    private Long studentId;
    private Long classId;
    private Long feeItemId;
    private Long standardId;
    private Long schoolYearId;
    private Long termId;
    private BigDecimal billAmount;
    private BigDecimal reducedAmount;
    private BigDecimal paidAmount;
    private String billStatus;
    private LocalDate dueDate;
    private String remark;
    private Long createdBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}