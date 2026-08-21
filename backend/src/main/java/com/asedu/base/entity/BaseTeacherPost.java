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

/** 师资岗位绑定表 —— db 表 base_teacher_post */
@Data
@TableName("base_teacher_post")
public class BaseTeacherPost implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orgId;
    private Long teacherId;
    /** head_teacher班主任/subject_teacher任课/life_teacher保育员/nurse校医/admin行政/logistics后勤/counselor辅导员/major_teacher专业教师/training_teacher实训指导/tutor导师/psychologist心理辅导 */
    private String postType;
    private Long gradeId;
    private Long classId;
    private String subjectCode;
    private Long majorId;
    private Integer isPrimary;
    /** 0已离岗/1在岗 */
    private Integer postStatus;
    private LocalDate assignedAt;
    private LocalDate leftAt;
    private Long operatorId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
