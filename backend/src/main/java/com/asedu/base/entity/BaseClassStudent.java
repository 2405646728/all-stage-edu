package com.asedu.base.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** 班级学生关系表（分班/调班/升班台账）—— db 表 base_class_student */
@Data
@TableName("base_class_student")
public class BaseClassStudent implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long classId;
    private Long schoolYearId;
    /** assigned智能分班/manual手动调班/transfer插班/promotion升班 */
    private String enterType;
    private LocalDate enterDate;
    private LocalDate leaveDate;
    /** 0历史/1当前在班 */
    private Integer status;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
