package com.asedu.base.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.LocalDate;

/** 学生主档保存 DTO —— 与 db 表 base_student 字段一一对应 */
@Data
public class StudentSaveDTO {

    private Long id;
    private Long orgId;
    private Long campusId;
    @NotBlank(message = "学号不能为空")
    private String studentNo;
    @NotBlank(message = "姓名不能为空")
    private String name;
    private Integer gender;
    private LocalDate birthDate;
    private String idCard;
    private String nation;
    private String nativePlace;
    private String household;
    private String address;
    private String photo;
    private LocalDate admitDate;
    private String admitBatch;
    private String studyStatus;
    private Integer boarder;
    private Long currentClassId;
    private String specialNote;
    private String sourceDesc;
    /** 是否同时生成家长账号（批量开通联动预留） */
    private Boolean createAccount;
}
