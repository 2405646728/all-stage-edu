package com.asedu.base.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/** 学籍异动登记 DTO —— 对应 db 表 base_student_status_change */
@Data
public class EnrollmentChangeDTO {

    @NotNull(message = "学生ID不能为空")
    private Long studentId;
    /** enroll建档/transfer_in转入/transfer_out转出/suspend休学/resume复学/retain留级/skip跳级/graduate毕业/withdraw退学/deregister注销 */
    @NotNull(message = "异动类型不能为空")
    private String changeType;
    private String beforeStatus;
    private String afterStatus;
    private String changeReason;
    private String targetOrgName;
    private String evidenceFile;
}
