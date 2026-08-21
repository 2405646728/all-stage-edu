-- =====================================================================
-- 05_attendance_gate.sql —— 考勤与门禁安防（全学段通用安全管控模块）
-- 对应文档：5.2.2 考勤与接送安全管理 / 5.2.5 校园门禁安防管理 /
--           各学段「考勤安防、健康校园」模块
-- 约定：考勤/门禁为独立闭环，仅读取基础档案静态数据，单向同步家校/安全台账。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 1. 学生考勤（签到/签退/在校时长/异常标记；入校+离校全场景）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `att_student_record`;
CREATE TABLE `att_student_record` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '考勤ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                 COMMENT '学生ID（关联 base_student.id）',
  `class_id`     BIGINT UNSIGNED NULL                     COMMENT '班级ID（关联 base_class.id，统计维度）',
  `att_date`     DATE NOT NULL                            COMMENT '考勤日期',
  `attend_scene` VARCHAR(20) NOT NULL DEFAULT 'daily'     COMMENT '考勤场景：daily日常/in_after入离园(校)/class课堂/self_study晚自习/weekend周末留校',
  `sign_in_time` DATETIME NULL                            COMMENT '签到/入校时间',
  `sign_out_time` DATETIME NULL                           COMMENT '签退/离校时间',
  `stay_minutes` INT NOT NULL DEFAULT 0                   COMMENT '在校时长（分钟）',
  `sign_in_way`  VARCHAR(10) NULL                         COMMENT '签到方式：card刷卡/face刷脸/manual人工补录',
  `sign_out_way` VARCHAR(10) NULL                         COMMENT '签退方式：card/face/manual',
  `device_id`    BIGINT UNSIGNED NULL                     COMMENT '打卡设备（关联 sys_gate_device.id）',
  `device_name`  VARCHAR(100) NOT NULL DEFAULT ''         COMMENT '设备名称（冗余留痕）',
  `location`     VARCHAR(100) NOT NULL DEFAULT ''         COMMENT '打卡地点',
  `status`       VARCHAR(20) NOT NULL DEFAULT 'pending'   COMMENT '考勤状态：normal正常/late迟到/early_leave早退/absent缺勤/leave请假/skip未签退异常',
  `remark`       VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '备注（人工补录原因等）',
  `operator_id`  BIGINT UNSIGNED NULL                     COMMENT '补录操作人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_att_student` (`student_id`,`att_date`,`attend_scene`),
  KEY `idx_att_org_date` (`org_id`,`att_date`),
  KEY `idx_att_class` (`class_id`,`att_date`),
  KEY `idx_att_status` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生考勤明细表（刷卡/刷脸/人工补录，日周月统计台账）';

-- ---------------------------------------------------------------------
-- 2. 教职工考勤（全岗位上下班打卡/请假/外勤；与幼儿学生业务体系完全独立）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `att_staff_record`;
CREATE TABLE `att_staff_record` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '考勤ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `teacher_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '教职工ID（关联 base_teacher.id）',
  `att_date`    DATE NOT NULL                            COMMENT '考勤日期',
  `work_in_time` DATETIME NULL                           COMMENT '上班打卡时间',
  `work_out_time` DATETIME NULL                          COMMENT '下班打卡时间',
  `work_in_way` VARCHAR(10) NULL                         COMMENT '打卡方式：card/face/manual',
  `status`      VARCHAR(20) NOT NULL DEFAULT 'pending'   COMMENT '状态：normal正常/late迟到/early_leave早退/absent旷工/leave请假/field外勤',
  `field_note`  VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '外勤登记说明',
  `operator_id` BIGINT UNSIGNED NULL                     COMMENT '登记人（关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_att_staff` (`teacher_id`,`att_date`),
  KEY `idx_att_staff_org` (`org_id`,`att_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='教职工考勤表（月度考勤报表/岗位考核/薪资统计依据）';

-- ---------------------------------------------------------------------
-- 3. 请假（家长端线上请假 + 班主任后台代请假；审批通过自动同步缺勤）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `att_leave`;
CREATE TABLE `att_leave` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '请假ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id；教职工请假可扩展 leave_user_type）',
  `leave_user_type` VARCHAR(10) NOT NULL DEFAULT 'student' COMMENT '请假人类型：student学生/teacher教职工',
  `leave_type`    VARCHAR(20) NOT NULL                    COMMENT '请假类型：personal事假/sick病假/annual年假/bereavement丧假/other其他',
  `start_time`    DATETIME NOT NULL                       COMMENT '请假开始时间',
  `end_time`      DATETIME NOT NULL                       COMMENT '请假结束时间',
  `duration_hours` DECIMAL(6,2) NOT NULL DEFAULT 0        COMMENT '请假时长（小时）',
  `reason`        VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '请假事由',
  `evidence_file` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '凭证（关联 base_file，病假证明等）',
  `apply_source`  VARCHAR(10) NOT NULL DEFAULT 'parent'   COMMENT '申请来源：parent家长端/staff后台代请假',
  `apply_by`      BIGINT UNSIGNED NOT NULL                COMMENT '申请人（关联 auth_user.id）',
  `approve_status` VARCHAR(10) NOT NULL DEFAULT 'pending' COMMENT '审批状态：pending待审批/approved通过/rejected驳回/canceled撤销',
  `approve_by`    BIGINT UNSIGNED NULL                    COMMENT '审批人（关联 auth_user.id）',
  `approve_at`    DATETIME NULL                           COMMENT '审批时间',
  `approve_remark` VARCHAR(255) NOT NULL DEFAULT ''       COMMENT '审批意见',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_leave_student` (`student_id`,`created_at`),
  KEY `idx_leave_org` (`org_id`,`approve_status`),
  KEY `idx_leave_time` (`org_id`,`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='请假登记表（审批通过单向联动考勤统计/当日门禁权限冻结）';

-- ---------------------------------------------------------------------
-- 4. 门禁通行权限（在读/在岗状态自动分配；离园离职自动回收）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `gate_permission`;
CREATE TABLE `gate_permission` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `person_type`  VARCHAR(10) NOT NULL                     COMMENT '人员类型：student学生/teacher教职工/guardian接送人/visitor访客',
  `person_id`    BIGINT UNSIGNED NOT NULL                 COMMENT '人员ID（按 person_type 关联 base_student/base_teacher/base_guardian）',
  `device_group` VARCHAR(200) NOT NULL DEFAULT ''         COMMENT '适用设备范围（全部/指定设备编码列表）',
  `permission`   VARCHAR(20) NOT NULL DEFAULT 'in_out'    COMMENT '权限类型：in_out出入/in入校/out出校/area区域通行（实训场地等）',
  `grant_mode`   VARCHAR(10) NOT NULL DEFAULT 'auto'      COMMENT '授权方式：auto自动/manual单独授权/batch批量授权',
  `valid_from`   DATETIME NULL                            COMMENT '有效期开始',
  `valid_until`  DATETIME NULL                            COMMENT '有效期截止',
  `status`       TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0冻结/1有效/2过期（权限回收留痕）',
  `freeze_reason` VARCHAR(255) NOT NULL DEFAULT ''        COMMENT '冻结原因（请假/离园/毕业自动冻结说明）',
  `operator_id`  BIGINT UNSIGNED NULL                     COMMENT '授权操作人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_gate_perm_person` (`person_type`,`person_id`,`status`),
  KEY `idx_gate_perm_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='门禁通行权限表（在读/在岗状态单向同步，离园离职自动回收）';

-- ---------------------------------------------------------------------
-- 5. 门禁通行记录（入校/离校全量溯源，永久留存）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `gate_pass_record`;
CREATE TABLE `gate_pass_record` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `person_type` VARCHAR(10) NOT NULL                     COMMENT '人员类型：student/teacher/guardian/visitor/stranger陌生人员',
  `person_id`   BIGINT UNSIGNED NULL                     COMMENT '人员ID（陌生人员为NULL）',
  `person_name` VARCHAR(50) NOT NULL DEFAULT ''          COMMENT '人员姓名（冗余留痕）',
  `device_id`   BIGINT UNSIGNED NOT NULL                 COMMENT '设备ID（关联 sys_gate_device.id）',
  `device_name` VARCHAR(100) NOT NULL DEFAULT ''         COMMENT '设备名称（冗余）',
  `pass_time`   DATETIME NOT NULL                        COMMENT '通行时间',
  `direction`   VARCHAR(5) NOT NULL                      COMMENT '方向：in入/out出',
  `pass_way`    VARCHAR(10) NOT NULL                     COMMENT '通行方式：card刷卡/face刷脸/manual人工核验',
  `result`      VARCHAR(10) NOT NULL DEFAULT 'valid'     COMMENT '通行结果：valid有效通行/invalid无效/abnormal异常通行（拦截）',
  `fail_reason` VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '拦截/异常原因（非授权/权限过期/陌生人员）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  KEY `idx_pass_person` (`person_type`,`person_id`,`pass_time`),
  KEY `idx_pass_org_time` (`org_id`,`pass_time`),
  KEY `idx_pass_device` (`device_id`),
  KEY `idx_pass_result` (`result`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='门禁通行记录表（全量溯源安防台账，永久留存）';

-- ---------------------------------------------------------------------
-- 6. 陌生人员拦截与安防预警（风控闭环，独立于家校日常通知链路）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `gate_alert`;
CREATE TABLE `gate_alert` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '预警ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `pass_record_id` BIGINT UNSIGNED NOT NULL              COMMENT '关联通行记录（关联 gate_pass_record.id）',
  `alert_type`  VARCHAR(20) NOT NULL                     COMMENT '预警类型：stranger陌生人员/unauthorized非授权/expired权限过期/overtime超时滞留/night夜间异常',
  `alert_level` VARCHAR(10) NOT NULL DEFAULT 'error'     COMMENT '预警级别：warn/error（红色安防预警）',
  `content`     VARCHAR(500) NOT NULL DEFAULT ''         COMMENT '预警内容',
  `notify_target` VARCHAR(200) NOT NULL DEFAULT ''       COMMENT '推送对象（安保/管理员/班主任/家长，逗号分隔user_id）',
  `status`      TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '处理状态：0未处理/1已处理',
  `handled_by`  BIGINT UNSIGNED NULL                     COMMENT '处理人（关联 auth_user.id，二次核验放行登记）',
  `handled_at`  DATETIME NULL                            COMMENT '处理时间',
  `handle_note` VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '处理备注（人工二次核验放行说明）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预警时间',
  PRIMARY KEY (`id`),
  KEY `idx_gate_alert_org` (`org_id`,`status`),
  KEY `idx_gate_alert_time` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='门禁安防预警表（陌生拦截/异常通行红色预警闭环）';

-- ---------------------------------------------------------------------
-- 7. 访客预约与临时通行（访客/临时角色：仅临时阅览、预约入校）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `gate_visitor`;
CREATE TABLE `gate_visitor` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '访客ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `name`          VARCHAR(50) NOT NULL                    COMMENT '访客姓名',
  `phone`         VARCHAR(20) NOT NULL DEFAULT ''         COMMENT '手机号',
  `id_card`       VARCHAR(64) NOT NULL DEFAULT ''         COMMENT '证件号（应用层加密存储）',
  `visit_purpose` VARCHAR(100) NOT NULL DEFAULT ''        COMMENT '来访事由',
  `interviewee_id` BIGINT UNSIGNED NULL                   COMMENT '被访人（关联 auth_user.id）',
  `invite_by`     BIGINT UNSIGNED NULL                    COMMENT '邀请/登记人（关联 auth_user.id）',
  `visit_start`   DATETIME NOT NULL                       COMMENT '预约入校时间',
  `visit_end`     DATETIME NULL                           COMMENT '离校时间',
  `approve_status` VARCHAR(10) NOT NULL DEFAULT 'pending' COMMENT '审批状态：pending/approved/rejected',
  `status`        TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '通行状态：0未入校/1已入校/2已离校/3过期',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登记时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_visitor_org` (`org_id`,`status`),
  KEY `idx_visitor_time` (`visit_start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='访客预约表（访客临时角色通行管控）';
