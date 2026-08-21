package com.asedu.base.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 学生监护人绑定表 —— db 表 base_student_guardian */
@Data
@TableName("base_student_guardian")
public class BaseStudentGuardian implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long guardianId;
    private Integer isPrimary;
    private Integer canPickup;
    /** 0已解绑/1绑定中 */
    private Integer bindStatus;
    private LocalDateTime boundAt;
    private LocalDateTime unboundAt;
    private Long operatorId;
}
