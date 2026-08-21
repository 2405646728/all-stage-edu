-- =====================================================================
-- 04_base_common.sql —— 通用基础底座（各学段「基础档案数据底座」模块）
-- 对应文档：5.2.1（幼儿园）、6.1.1/5.3.x（小学）、7.1.1/5.4.1/5.5.1（初中）、
--           5.5.1/5.6.1/8.1.1（普高）、9.1.1（职高）、10.1.1（高校）
-- 定位：全学段唯一数据底座，仅对外输出只读数据，下游业务单向依赖。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 1. 学年 / 学期（全校教学周期基础）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `base_school_year`;
CREATE TABLE `base_school_year` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '学年ID',
  `org_id`     BIGINT UNSIGNED NOT NULL                  COMMENT '机构ID（关联 sys_org.id）',
  `year_name`  VARCHAR(50) NOT NULL                      COMMENT '学年名称（如 2025-2026学年）',
  `start_date` DATE NOT NULL                             COMMENT '学年开始日期',
  `end_date`   DATE NOT NULL                             COMMENT '学年结束日期',
  `status`     TINYINT UNSIGNED NOT NULL DEFAULT 1       COMMENT '状态：0关闭/1当前/2未开始',
  `created_by` BIGINT UNSIGNED NULL                      COMMENT '创建人（关联 auth_user.id）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` TINYINT UNSIGNED NOT NULL DEFAULT 0       COMMENT '逻辑删除：0正常/1已删',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_school_year` (`org_id`,`year_name`),
  KEY `idx_year_org` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学年表';

DROP TABLE IF EXISTS `base_term`;
CREATE TABLE `base_term` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '学期ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `school_year_id` BIGINT UNSIGNED NOT NULL              COMMENT '学年ID（关联 base_school_year.id）',
  `term_name`   VARCHAR(50) NOT NULL                     COMMENT '学期名称（如 第一学期）',
  `term_no`     TINYINT UNSIGNED NOT NULL                COMMENT '学期序号（1/2）',
  `start_date`  DATE NOT NULL                            COMMENT '学期开始日期',
  `end_date`    DATE NOT NULL                            COMMENT '学期结束日期',
  `status`      TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '状态：0未开始/1当前/2已结束',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_term` (`org_id`,`school_year_id`,`term_no`),
  KEY `idx_term_org` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学期表';

-- ---------------------------------------------------------------------
-- 2. 年级 / 班级架构（各学段差异化名称：小班/一年级/七年级/高一/大一/职高年级）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `base_grade`;
CREATE TABLE `base_grade` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '年级ID',
  `org_id`     BIGINT UNSIGNED NOT NULL                  COMMENT '机构ID（关联 sys_org.id）',
  `campus_id`  BIGINT UNSIGNED NULL                      COMMENT '校区ID（关联 sys_campus.id）',
  `stage`      VARCHAR(20) NOT NULL                      COMMENT '学段（冗余自机构，学段差异化渲染）',
  `grade_name` VARCHAR(50) NOT NULL                      COMMENT '年级名称（小班/中班/大班/一年级~高三/职高一年级~三年级/大一~大四）',
  `grade_no`   TINYINT UNSIGNED NOT NULL                 COMMENT '年级序号（1=最低年级）',
  `school_year_id` BIGINT UNSIGNED NULL                  COMMENT '所属学年（关联 base_school_year.id）',
  `class_capacity` INT NOT NULL DEFAULT 0                COMMENT '班级容量标准',
  `status`     TINYINT UNSIGNED NOT NULL DEFAULT 1       COMMENT '状态：0归档/1启用',
  `sort_no`    INT NOT NULL DEFAULT 0                    COMMENT '排序号',
  `created_by` BIGINT UNSIGNED NULL                      COMMENT '创建人（关联 auth_user.id）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` TINYINT UNSIGNED NOT NULL DEFAULT 0       COMMENT '逻辑删除：0正常/1已删',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_grade` (`org_id`,`school_year_id`,`grade_name`),
  KEY `idx_grade_org` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='年级表（全学段统一架构，学段差异化渲染）';

DROP TABLE IF EXISTS `base_class`;
CREATE TABLE `base_class` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '班级ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `campus_id`     BIGINT UNSIGNED NULL                    COMMENT '校区ID（关联 sys_campus.id）',
  `stage`         VARCHAR(20) NOT NULL                    COMMENT '学段（冗余自机构）',
  `grade_id`      BIGINT UNSIGNED NOT NULL                COMMENT '年级ID（关联 base_grade.id）',
  `department_id` BIGINT UNSIGNED NULL                    COMMENT '院系ID（高校用，关联 uni_department.id）',
  `major_id`      BIGINT UNSIGNED NULL                    COMMENT '专业ID（职高/高校用，关联 voc_major.id / uni_major.id）',
  `class_name`    VARCHAR(50) NOT NULL                    COMMENT '班级名称（如 小一班/三年级2班/高三(1)班）',
  `class_type`    VARCHAR(20) NOT NULL DEFAULT 'normal'   COMMENT '班级类型：normal行政班/walk走班教学班/tier分层班/training实训班',
  `class_capacity` INT NOT NULL DEFAULT 0                 COMMENT '班级容量',
  `open_date`     DATE NULL                               COMMENT '开班时间',
  `status`        TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '状态：0归档(闲置班级)/1启用',
  `sort_no`       INT NOT NULL DEFAULT 0                  COMMENT '排序号',
  `created_by`    BIGINT UNSIGNED NULL                    COMMENT '创建人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted`    TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '逻辑删除：0正常/1已删',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_class` (`org_id`,`grade_id`,`class_name`),
  KEY `idx_class_org` (`org_id`,`status`),
  KEY `idx_class_grade` (`grade_id`),
  KEY `idx_class_major` (`major_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='班级表（含行政班/教学班/分层班/实训班，全学段统一）';

-- ---------------------------------------------------------------------
-- 3. 学生主档（全学段通用字段；学段特有字段挂学段拓展表，保持底座冻结）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `base_student`;
CREATE TABLE `base_student` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '学生ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id，数据隔离）',
  `campus_id`    BIGINT UNSIGNED NULL                     COMMENT '校区ID（关联 sys_campus.id）',
  `stage`        VARCHAR(20) NOT NULL                     COMMENT '学段（冗余自机构）',
  `student_no`   VARCHAR(32) NOT NULL                     COMMENT '学号/园号（机构内唯一，账号唯一标识依据）',
  `user_id`      BIGINT UNSIGNED NULL                     COMMENT '对应账号ID（关联 auth_user.id，台账同步自动建号）',
  `name`         VARCHAR(50) NOT NULL                     COMMENT '姓名',
  `gender`       TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '性别：0未知/1男/2女',
  `birth_date`   DATE NULL                                COMMENT '出生日期',
  `id_card`      VARCHAR(64) NOT NULL DEFAULT ''          COMMENT '身份证号（唯一去重依据，应用层加密存储）',
  `nation`       VARCHAR(20) NOT NULL DEFAULT '汉族'       COMMENT '民族',
  `native_place` VARCHAR(50) NOT NULL DEFAULT ''          COMMENT '籍贯',
  `household`    VARCHAR(100) NOT NULL DEFAULT ''         COMMENT '户籍信息',
  `address`      VARCHAR(200) NOT NULL DEFAULT ''         COMMENT '家庭住址',
  `photo`        VARCHAR(500) NOT NULL DEFAULT ''         COMMENT '照片地址（关联 base_file）',
  `admit_date`   DATE NULL                                COMMENT '入园/入学时间',
  `admit_batch`  VARCHAR(30) NOT NULL DEFAULT ''          COMMENT '入园/入学批次',
  `study_status` VARCHAR(20) NOT NULL DEFAULT 'normal'    COMMENT '就读状态：normal在读/suspended休学/left离园(校)/graduated毕业/withdrawn退学',
  `boarder`      TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '是否寄宿：0走读/1寄宿（寄宿/走读考勤规则依据）',
  `current_class_id` BIGINT UNSIGNED NULL                 COMMENT '当前班级（关联 base_class.id，分班后冗余维护）',
  `special_note` VARCHAR(500) NOT NULL DEFAULT ''         COMMENT '特殊备注（特长短板/家庭情况等，敏感内容加密存储）',
  `source_desc`  VARCHAR(100) NOT NULL DEFAULT ''         COMMENT '生源信息（小升初/中考生源/高考生源/新生入学批次）',
  `created_by`   BIGINT UNSIGNED NULL                     COMMENT '录入人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by`   BIGINT UNSIGNED NULL                     COMMENT '最后更新人',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted`   TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '逻辑删除：0正常/1已删',
  `deleted_at`   DATETIME NULL                            COMMENT '删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_no` (`org_id`,`student_no`),
  KEY `idx_student_org` (`org_id`,`study_status`),
  KEY `idx_student_class` (`current_class_id`),
  KEY `idx_student_idcard` (`id_card`),
  KEY `idx_student_stage` (`stage`),
  KEY `idx_student_name` (`org_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生主档表（全学段统一底座；学号/身份证唯一查重）';

-- ---------------------------------------------------------------------
-- 4. 学籍与学籍异动台账（学籍状态权威，单向联动下游权限）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `base_student_enrollment`;
CREATE TABLE `base_student_enrollment` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '学籍ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id，一对一）',
  `enroll_no`     VARCHAR(32) NOT NULL                    COMMENT '学籍号（教育局标准学籍号，唯一）',
  `stage`         VARCHAR(20) NOT NULL                    COMMENT '学段',
  `schooling_years` TINYINT UNSIGNED NOT NULL DEFAULT 0   COMMENT '学制年限（幼儿园3/小学6/初中3/普高3/职高3/大学4）',
  `enroll_date`   DATE NOT NULL                           COMMENT '入籍/注册时间',
  `enroll_batch`  VARCHAR(30) NOT NULL DEFAULT ''         COMMENT '学籍批次/入园批次',
  `current_grade_id` BIGINT UNSIGNED NULL                 COMMENT '当前年级（关联 base_grade.id）',
  `current_class_id` BIGINT UNSIGNED NULL                 COMMENT '当前班级（关联 base_class.id）',
  `enroll_status` VARCHAR(20) NOT NULL DEFAULT 'normal'   COMMENT '学籍状态：normal在读/在园/suspended休学/transferred_out转出/graduated毕业/withdrawn退学/deregistered注销',
  `graduate_at`   DATE NULL                               COMMENT '毕业/离园时间',
  `created_by`    BIGINT UNSIGNED NULL                    COMMENT '建档人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_enroll_no` (`enroll_no`),
  UNIQUE KEY `uk_enroll_student` (`student_id`),
  KEY `idx_enroll_org` (`org_id`,`enroll_status`),
  KEY `idx_enroll_grade` (`current_grade_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学籍表（学籍状态权威数据源，单向联动考勤/门禁/家校/报名权限）';

DROP TABLE IF EXISTS `base_student_status_change`;
CREATE TABLE `base_student_status_change` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '异动ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `enroll_id`     BIGINT UNSIGNED NOT NULL                COMMENT '学籍ID（关联 base_student_enrollment.id）',
  `change_type`   VARCHAR(20) NOT NULL                    COMMENT '异动类型：enroll建档/transfer_in转入/transfer_out转出/suspend休学/resume复学/retain留级/skip跳级/graduate毕业/withdraw退学/deregister注销',
  `before_status` VARCHAR(20) NOT NULL DEFAULT ''         COMMENT '异动前学籍状态',
  `after_status`  VARCHAR(20) NOT NULL                    COMMENT '异动后学籍状态',
  `before_class_id` BIGINT UNSIGNED NULL                  COMMENT '异动前班级（关联 base_class.id）',
  `after_class_id` BIGINT UNSIGNED NULL                   COMMENT '异动后班级（留级/跳级/调班）',
  `change_reason` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '异动事由',
  `target_org_name` VARCHAR(100) NOT NULL DEFAULT ''      COMMENT '转入/转出目标学校',
  `evidence_file` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '佐证材料（关联 base_file，休学备案/转学证明等）',
  `audit_status`  VARCHAR(10) NOT NULL DEFAULT 'pending'  COMMENT '审核状态：pending待审核/approved已通过/rejected已驳回（学籍变动须后台审核备案）',
  `audit_by`      BIGINT UNSIGNED NULL                    COMMENT '审核人（关联 auth_user.id）',
  `audit_at`      DATETIME NULL                           COMMENT '审核时间',
  `audit_remark`  VARCHAR(255) NOT NULL DEFAULT ''        COMMENT '审核意见',
  `operator_id`   BIGINT UNSIGNED NOT NULL                COMMENT '经办人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登记时间',
  PRIMARY KEY (`id`),
  KEY `idx_change_student` (`student_id`,`created_at`),
  KEY `idx_change_org` (`org_id`),
  KEY `idx_change_audit` (`audit_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学籍异动台账表（全流程登记/审核/留痕/溯源）';

-- ---------------------------------------------------------------------
-- 5. 班级学生关系（分班/调班/升班全量历史，可追溯每学年人员变动明细）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `base_class_student`;
CREATE TABLE `base_class_student` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '关系ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `student_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '学生ID（关联 base_student.id）',
  `class_id`    BIGINT UNSIGNED NOT NULL                 COMMENT '班级ID（关联 base_class.id）',
  `school_year_id` BIGINT UNSIGNED NOT NULL              COMMENT '学年ID（升班历史维度，关联 base_school_year.id）',
  `enter_type`  VARCHAR(20) NOT NULL DEFAULT 'assigned'  COMMENT '入班方式：assigned智能分班/manual手动调班/transfer插班/promotion升班',
  `enter_date`  DATE NOT NULL                            COMMENT '入班日期',
  `leave_date`  DATE NULL                                COMMENT '离班日期（转班/毕业/离校）',
  `status`      TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0历史/1当前在班',
  `operator_id` BIGINT UNSIGNED NULL                     COMMENT '操作人（关联 auth_user.id，分班记录留痕）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_class_student` (`class_id`,`student_id`,`school_year_id`),
  KEY `idx_cs_student` (`student_id`,`status`),
  KEY `idx_cs_class` (`class_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='班级学生关系表（分班/调班/升班台账，永久留存）';

-- ---------------------------------------------------------------------
-- 6. 监护人（多监护人绑定；接送人白名单数据源）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `base_guardian`;
CREATE TABLE `base_guardian` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '监护人ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `name`         VARCHAR(50) NOT NULL                     COMMENT '监护人姓名',
  `phone`        VARCHAR(20) NOT NULL                     COMMENT '手机号',
  `relation`     VARCHAR(20) NOT NULL                     COMMENT '与孩子关系：father父亲/mother母亲/grandfather祖父/grandmother祖母/other其他',
  `is_emergency` TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '是否紧急联系人：0否/1是',
  `work_info`    VARCHAR(100) NOT NULL DEFAULT ''         COMMENT '工作信息',
  `id_card`      VARCHAR(64) NOT NULL DEFAULT ''          COMMENT '证件号（临时接送核验，应用层加密存储）',
  `face_feature` VARCHAR(2000) NOT NULL DEFAULT ''        COMMENT '人脸特征值（刷脸核验，密文存储）',
  `user_id`      BIGINT UNSIGNED NULL                     COMMENT '对应家长账号（关联 auth_user.id）',
  `created_by`   BIGINT UNSIGNED NULL                     COMMENT '录入人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted`   TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '逻辑删除：0正常/1已删',
  PRIMARY KEY (`id`),
  KEY `idx_guardian_org` (`org_id`),
  KEY `idx_guardian_phone` (`phone`),
  KEY `idx_guardian_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='监护人表（多监护人/紧急联系人，接送白名单数据源）';

DROP TABLE IF EXISTS `base_student_guardian`;
CREATE TABLE `base_student_guardian` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '绑定ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `student_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '学生ID（关联 base_student.id）',
  `guardian_id` BIGINT UNSIGNED NOT NULL                 COMMENT '监护人ID（关联 base_guardian.id）',
  `is_primary`  TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '是否第一监护人：0次要/1第一',
  `can_pickup`  TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '是否授权接送：0否/1是（固定接送授权）',
  `bind_status` TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '绑定状态：0已解绑/1绑定中',
  `bound_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '绑定时间',
  `unbound_at`  DATETIME NULL                            COMMENT '解绑时间',
  `operator_id` BIGINT UNSIGNED NULL                     COMMENT '操作人（关联 auth_user.id）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_guardian` (`student_id`,`guardian_id`),
  KEY `idx_sg_guardian` (`guardian_id`,`bind_status`),
  KEY `idx_sg_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生监护人绑定表（多子女关联、主次监护人、接送授权）';

-- ---------------------------------------------------------------------
-- 7. 教职工与岗位配置（一人多岗、一岗多人；岗位联动权限）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `base_teacher`;
CREATE TABLE `base_teacher` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '教职工ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `campus_id`   BIGINT UNSIGNED NULL                     COMMENT '校区ID（关联 sys_campus.id）',
  `stage`       VARCHAR(20) NOT NULL                     COMMENT '学段（冗余自机构）',
  `staff_no`    VARCHAR(32) NOT NULL                     COMMENT '工号（机构内唯一，账号唯一标识依据）',
  `user_id`     BIGINT UNSIGNED NULL                     COMMENT '对应账号ID（关联 auth_user.id）',
  `name`        VARCHAR(50) NOT NULL                     COMMENT '姓名',
  `gender`      TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '性别：0未知/1男/2女',
  `phone`       VARCHAR(20) NOT NULL DEFAULT ''          COMMENT '手机号',
  `id_card`     VARCHAR(64) NOT NULL DEFAULT ''          COMMENT '身份证号（应用层加密存储）',
  `education`   VARCHAR(20) NOT NULL DEFAULT ''          COMMENT '学历',
  `title`       VARCHAR(30) NOT NULL DEFAULT ''          COMMENT '职称',
  `hire_date`   DATE NULL                                COMMENT '入职日期',
  `work_status` VARCHAR(20) NOT NULL DEFAULT 'active'    COMMENT '在职状态：active在职/leave休假/resigned离职/retired退休',
  `external_type` VARCHAR(20) NOT NULL DEFAULT 'internal' COMMENT '师资类型：internal校内/external校外（企业导师/实训导师备案）',
  `created_by`  BIGINT UNSIGNED NULL                     COMMENT '录入人（关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted`  TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '逻辑删除：0正常/1已删',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_staff_no` (`org_id`,`staff_no`),
  KEY `idx_teacher_org` (`org_id`,`work_status`),
  KEY `idx_teacher_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='教职工表（全学段师资底座）';

DROP TABLE IF EXISTS `base_teacher_post`;
CREATE TABLE `base_teacher_post` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '岗位绑定ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `teacher_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '教职工ID（关联 base_teacher.id）',
  `post_type`   VARCHAR(30) NOT NULL                     COMMENT '岗位类型：head_teacher班主任/subject_teacher任课/life_teacher保育员/nurse校医/admin行政/logistics后勤/counselor辅导员/major_teacher专业教师/training_teacher实训指导/tutor导师/psychologist心理辅导',
  `grade_id`    BIGINT UNSIGNED NULL                     COMMENT '绑定年级（关联 base_grade.id）',
  `class_id`    BIGINT UNSIGNED NULL                     COMMENT '绑定班级（关联 base_class.id，管辖范围）',
  `subject_code` VARCHAR(30) NOT NULL DEFAULT ''         COMMENT '授课科目（字典 subject_type）',
  `major_id`    BIGINT UNSIGNED NULL                     COMMENT '绑定专业（职高/高校，关联 voc_major.id/uni_major.id）',
  `is_primary`  TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '是否主岗：0兼岗/1主岗（一人多岗配置）',
  `post_status` TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0已离岗/1在岗',
  `assigned_at` DATE NOT NULL                            COMMENT '岗位生效日期',
  `left_at`     DATE NULL                                COMMENT '离岗日期',
  `operator_id` BIGINT UNSIGNED NULL                     COMMENT '操作人（关联 auth_user.id，岗位调整留痕）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_post_teacher` (`teacher_id`,`post_status`),
  KEY `idx_post_class` (`class_id`),
  KEY `idx_post_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='师资岗位绑定表（一人多岗/一岗多人，岗位联动权限）';

-- ---------------------------------------------------------------------
-- 8. 学生健康档案（隐私数据加密隔离存储，权限严格受控）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `base_student_health`;
CREATE TABLE `base_student_health` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '健康档案ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id，一对一）',
  `allergy_history` TEXT NULL                            COMMENT '过敏史（食物/药物/粉尘等，密文存储）',
  `disease_history` TEXT NULL                            COMMENT '既往病史（密文存储）',
  `surgery_history` TEXT NULL                            COMMENT '既往手术记录（密文存储）',
  `constitution_note` TEXT NULL                          COMMENT '日常体质备注（密文存储）',
  `diet_taboo`    TEXT NULL                              COMMENT '饮食禁忌（餐食公示高亮提醒依据，密文存储）',
  `sport_taboo`   TEXT NULL                              COMMENT '运动禁忌（密文存储）',
  `psychology_note` TEXT NULL                            COMMENT '心理备注/青春期心理状态/备考压力（密文存储）',
  `sleep_note`    TEXT NULL                              COMMENT '睡眠情况备注（普高备考管护，密文存储）',
  `training_taboo` TEXT NULL                             COMMENT '实训安全禁忌（职高机械/化工/护理专业，密文存储）',
  `blood_type`    VARCHAR(5) NOT NULL DEFAULT ''         COMMENT '血型',
  `height_cm`     DECIMAL(5,1) NULL                       COMMENT '身高（厘米）',
  `weight_kg`     DECIMAL(5,1) NULL                       COMMENT '体重（千克）',
  `updated_by`    BIGINT UNSIGNED NULL                    COMMENT '更新人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_health_student` (`student_id`),
  KEY `idx_health_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生健康档案表（隐私数据单独加密隔离，仅管理员/班主任/保育员/校医可见）';

-- ---------------------------------------------------------------------
-- 9. 统一文件库（文件上传规则通用底层）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `base_file`;
CREATE TABLE `base_file` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '文件ID',
  `org_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id；平台文件为0）',
  `biz_type`   VARCHAR(30) NOT NULL                     COMMENT '业务类型：avatar头像/photo照片/meal餐食/activity活动/evidence凭证/resource教案课件/import导入/notice通知附件/contract协议/certificate证书等',
  `biz_id`     BIGINT UNSIGNED NOT NULL DEFAULT 0       COMMENT '业务数据ID',
  `file_name`  VARCHAR(200) NOT NULL                    COMMENT '原始文件名',
  `file_path`  VARCHAR(500) NOT NULL                    COMMENT '存储路径',
  `file_size`  BIGINT UNSIGNED NOT NULL DEFAULT 0       COMMENT '文件大小（字节）',
  `mime_type`  VARCHAR(100) NOT NULL DEFAULT ''         COMMENT 'MIME类型',
  `uploader_id` BIGINT UNSIGNED NULL                    COMMENT '上传人（关联 auth_user.id）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  PRIMARY KEY (`id`),
  KEY `idx_file_biz` (`biz_type`,`biz_id`),
  KEY `idx_file_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='统一文件库表（图片/附件/凭证/导入导出归档）';
