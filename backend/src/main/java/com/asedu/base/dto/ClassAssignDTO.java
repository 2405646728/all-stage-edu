package com.asedu.base.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

/** 分班/调班 DTO —— 对应 db 表 base_class_student */
@Data
public class ClassAssignDTO {

    @NotNull(message = "学生ID不能为空")
    private Long studentId;
    @NotNull(message = "班级ID不能为空")
    private Long classId;
    /** assigned/manual/transfer/promotion */
    private String enterType;
    private LocalDate enterDate;
}
