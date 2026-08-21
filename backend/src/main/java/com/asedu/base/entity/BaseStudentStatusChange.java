package com.asedu.base.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 学籍异动台账表 —— db 表 base_student_status_change */
@Data
@TableName("base_student_status_change")
public class BaseStudentStatusChange implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long studentId;
    private Long enrollId;
    /** enroll建档/transfer_in转入/transfer_out转出/suspend休学/resume复学/retain留级/skip跳级/graduate毕业/withdraw退学/deregister注销 */
    private String changeType;
    private String beforeStatus;
    private String afterStatus;
    private Long beforeClassId;
    private Long afterClassId;
    private String changeReason;
    private String targetOrgName;
    private String evidenceFile;
    /** pending待审核/approved已通过/rejected已驳回 */
    private String auditStatus;
    private Long auditBy;
    private LocalDateTime auditAt;
    private String auditRemark;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
