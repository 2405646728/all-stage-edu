-- =====================================================================
-- 08_kindergarten.sql —— 幼儿园学段专属模块（安全/陪护/成长记录/家校互通）
-- 对应文档：5.2.2 考勤与接送安全管理 / 5.2.3 校园生活与家校互通 /
--           5.2.4 健康安全管控体系 / 5.2.5 与幼儿接送安全业务联动
-- 约定：幼儿园专属高安防闭环；接送白名单只读基础档案监护人数据，
--       核验结果单向同步门禁放行与家校离园通知。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 1. 接送授权（固定接送白名单 + 临时接送授权，杜绝错接误接）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `kind_pickup_authorization`;
CREATE TABLE `kind_pickup_authorization` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '授权ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                 COMMENT '幼儿ID（关联 base_student.id）',
  `guardian_id`  BIGINT UNSIGNED NULL                     COMMENT '固定接送人（关联 base_guardian.id；临时接送为NULL）',
  `pickup_type`  VARCHAR(10) NOT NULL DEFAULT 'fixed'     COMMENT '接送类型：fixed固定接送/temp临时接送',
  `temp_name`    VARCHAR(50) NOT NULL DEFAULT ''          COMMENT '临时接送人姓名',
  `temp_phone`   VARCHAR(20) NOT NULL DEFAULT ''          COMMENT '临时接送人手机号',
  `temp_id_card` VARCHAR(64) NOT NULL DEFAULT ''          COMMENT '临时接送人证件（应用层加密存储）',
  `temp_photo`   VARCHAR(500) NOT NULL DEFAULT ''         COMMENT '临时接送人照片（关联 base_file，人脸核验）',
  `valid_from`   DATETIME NULL                            COMMENT '授权有效期开始（临时接送必填）',
  `valid_until`  DATETIME NULL                            COMMENT '授权有效期截止',
  `apply_by`     BIGINT UNSIGNED NOT NULL                 COMMENT '授权申请人（家长线上授权/班主任，关联 auth_user.id）',
  `approve_status` VARCHAR(10) NOT NULL DEFAULT 'pending' COMMENT '审批状态：pending/approved/rejected（班主任后台核验留存）',
  `approve_by`   BIGINT UNSIGNED NULL                     COMMENT '核验人（关联 auth_user.id）',
  `approve_at`   DATETIME NULL                            COMMENT '核验时间',
  `status`       TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0失效/1有效',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_pickup_auth_student` (`student_id`,`status`),
  KEY `idx_pickup_auth_org` (`org_id`),
  KEY `idx_pickup_auth_guardian` (`guardian_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='幼儿接送授权表（固定/临时接送白名单，班主任核验留存）';

-- ---------------------------------------------------------------------
-- 2. 接送记录（每一次接送行为完整留存 + 超时未接安全预警）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `kind_pickup_record`;
CREATE TABLE `kind_pickup_record` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '接送记录ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                 COMMENT '幼儿ID（关联 base_student.id）',
  `guardian_id`  BIGINT UNSIGNED NULL                     COMMENT '接送人（关联 base_guardian.id；临时接送关联授权记录）',
  `auth_id`      BIGINT UNSIGNED NULL                     COMMENT '接送授权（关联 kind_pickup_authorization.id）',
  `pickup_name`  VARCHAR(50) NOT NULL                     COMMENT '接送人姓名（冗余留痕）',
  `pickup_time`  DATETIME NOT NULL                        COMMENT '接送时间',
  `direction`    VARCHAR(10) NOT NULL DEFAULT 'out'       COMMENT '方向：out离园接走/in送园',
  `verify_way`   VARCHAR(10) NOT NULL                     COMMENT '核验方式：face人脸/card卡号/phone手机号/manual人工核验',
  `verify_result` VARCHAR(20) NOT NULL DEFAULT 'passed'   COMMENT '核验结果：passed匹配放行/failed不匹配拦截/manual_verify二次核验放行',
  `device_id`    BIGINT UNSIGNED NULL                     COMMENT '核验设备（关联 sys_gate_device.id）',
  `is_alert`     TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '是否触发安防预警：0否/1是（超时未接/非授权人员红色预警）',
  `alert_note`   VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '预警说明（推送班主任/保育员/家长）',
  `operator_id`  BIGINT UNSIGNED NULL                     COMMENT '登记/放行人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  KEY `idx_pickup_student` (`student_id`,`pickup_time`),
  KEY `idx_pickup_org` (`org_id`,`pickup_time`),
  KEY `idx_pickup_alert` (`is_alert`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='幼儿接送记录表（全量溯源 + 陌生/超时安全预警）';

-- ---------------------------------------------------------------------
-- 3. 每日餐食公示（早中晚餐/加餐 + 过敏禁忌高亮提醒）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `kind_meal`;
CREATE TABLE `kind_meal` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '餐食ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `meal_date`   DATE NOT NULL                            COMMENT '供餐日期',
  `meal_type`   VARCHAR(10) NOT NULL                     COMMENT '餐次：breakfast早餐/lunch午餐/dinner晚餐/snack加餐',
  `menu_content` TEXT NOT NULL                           COMMENT '餐食清单',
  `photo`       VARCHAR(500) NOT NULL DEFAULT ''         COMMENT '餐食实拍图（关联 base_file）',
  `nutrition_note` VARCHAR(500) NOT NULL DEFAULT ''      COMMENT '营养配比说明',
  `taboo_note`  VARCHAR(500) NOT NULL DEFAULT ''         COMMENT '饮食禁忌提示（自动适配过敏幼儿标签高亮提醒）',
  `publisher_id` BIGINT UNSIGNED NOT NULL                COMMENT '发布人（保育员/班主任/管理员，关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_meal` (`org_id`,`meal_date`,`meal_type`),
  KEY `idx_meal_date` (`org_id`,`meal_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='每日餐食公示表（家长端实时查看，独立内容发布）';

-- ---------------------------------------------------------------------
-- 4. 午休与校园活动记录（成长纪实归档，纯记录纯展示模块）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `kind_nap_record`;
CREATE TABLE `kind_nap_record` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '午休记录ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `student_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '幼儿ID（关联 base_student.id）',
  `nap_date`    DATE NOT NULL                            COMMENT '日期',
  `sleep_minutes` INT NOT NULL DEFAULT 0                 COMMENT '入睡时长（分钟）',
  `nap_status`  VARCHAR(20) NOT NULL DEFAULT 'normal'    COMMENT '午休状态：normal正常/difficult入睡困难/awake未睡',
  `performance` VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '午休表现',
  `recorder_id` BIGINT UNSIGNED NOT NULL                 COMMENT '记录人（保育员，关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_nap` (`student_id`,`nap_date`),
  KEY `idx_nap_org` (`org_id`,`nap_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='幼儿午休记录表';

DROP TABLE IF EXISTS `kind_activity_record`;
CREATE TABLE `kind_activity_record` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '活动记录ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `class_id`      BIGINT UNSIGNED NULL                    COMMENT '班级ID（关联 base_class.id；全园活动为NULL）',
  `activity_type` VARCHAR(20) NOT NULL                    COMMENT '活动类型：class_daily班级日常/outdoor户外游戏/classroom课堂活动/festival节日活动/safety安全教育活动',
  `title`         VARCHAR(200) NOT NULL                   COMMENT '活动标题',
  `content`       TEXT NULL                               COMMENT '活动内容',
  `media_files`   VARCHAR(1000) NOT NULL DEFAULT ''       COMMENT '图文视频地址（关联 base_file，逗号分隔）',
  `activity_date` DATE NOT NULL                           COMMENT '活动日期',
  `publisher_id`  BIGINT UNSIGNED NOT NULL                COMMENT '发布人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  PRIMARY KEY (`id`),
  KEY `idx_activity_org` (`org_id`,`activity_date`),
  KEY `idx_activity_class` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='校园活动记录表（自动归档幼儿成长纪实）';

DROP TABLE IF EXISTS `kind_growth_record`;
CREATE TABLE `kind_growth_record` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '成长动态ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '幼儿ID（关联 base_student.id）',
  `class_id`     BIGINT UNSIGNED NULL                    COMMENT '班级ID（关联 base_class.id）',
  `record_type`  VARCHAR(20) NOT NULL DEFAULT 'daily'    COMMENT '类型：class_photo课堂纪实/performance课堂表现/comment阶段性成长点评/album成长相册',
  `title`        VARCHAR(200) NOT NULL DEFAULT ''        COMMENT '标题',
  `content`      TEXT NULL                               COMMENT '内容',
  `media_files`  VARCHAR(1000) NOT NULL DEFAULT ''       COMMENT '图文视频（关联 base_file，逗号分隔）',
  `publisher_id` BIGINT UNSIGNED NOT NULL                COMMENT '发布人（教职工，关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  PRIMARY KEY (`id`),
  KEY `idx_growth_student` (`student_id`,`created_at`),
  KEY `idx_growth_class` (`class_id`),
  KEY `idx_growth_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='幼儿成长动态表（按个人维度汇总，家长随时翻阅）';

-- ---------------------------------------------------------------------
-- 5. 晨检午检 + 异常健康上报跟进 + 校园安全巡查（健康安全管控体系）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `kind_health_check`;
CREATE TABLE `kind_health_check` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '检查记录ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `student_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '幼儿ID（关联 base_student.id）',
  `check_date`  DATE NOT NULL                            COMMENT '检查日期',
  `check_type`  VARCHAR(10) NOT NULL                     COMMENT '检查类型：morning晨检/noon午检',
  `temperature` DECIMAL(4,1) NULL                        COMMENT '体温（℃）',
  `mental_state` VARCHAR(20) NOT NULL DEFAULT 'normal'   COMMENT '精神状态：normal良好/tired疲惫/upset情绪不佳',
  `hygiene`     VARCHAR(20) NOT NULL DEFAULT 'normal'    COMMENT '卫生情况：normal良好/abnormal异常',
  `symptom`     VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '身体异常症状（发热/咳嗽/呕吐/外伤等）',
  `is_abnormal` TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '是否异常：0否/1是（异常高亮标记）',
  `recorder_id` BIGINT UNSIGNED NOT NULL                 COMMENT '记录人（保育员，关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_health_check` (`student_id`,`check_date`,`check_type`),
  KEY `idx_check_org` (`org_id`,`check_date`),
  KEY `idx_check_abnormal` (`org_id`,`is_abnormal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='晨检午检体温监测表（每日健康台账，异常单向同步家校提醒）';

DROP TABLE IF EXISTS `kind_health_abnormal`;
CREATE TABLE `kind_health_abnormal` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '异常记录ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL                COMMENT '幼儿ID（关联 base_student.id）',
  `symptom`       VARCHAR(255) NOT NULL                   COMMENT '异常症状详情（发热/咳嗽/呕吐/外伤/不适）',
  `occurred_at`   DATETIME NOT NULL                       COMMENT '发生时间',
  `handle_measure` VARCHAR(500) NOT NULL DEFAULT ''       COMMENT '处理措施',
  `follow_note`   VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '跟进记录（处置流程闭环）',
  `status`        VARCHAR(10) NOT NULL DEFAULT 'open'     COMMENT '状态：open跟进中/closed已闭环',
  `reporter_id`   BIGINT UNSIGNED NOT NULL                COMMENT '上报人（教职工，关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上报时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_abnormal_student` (`student_id`,`occurred_at`),
  KEY `idx_abnormal_org` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='幼儿异常健康上报跟进表（健康问题闭环管控台账）';

DROP TABLE IF EXISTS `kind_safety_inspect`;
CREATE TABLE `kind_safety_inspect` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '隐患ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `inspect_type`  VARCHAR(20) NOT NULL DEFAULT 'facility' COMMENT '巡查类型：facility设施/venue场地/device设备/security安防',
  `hazard_desc`   VARCHAR(500) NOT NULL                   COMMENT '隐患描述',
  `location`      VARCHAR(200) NOT NULL DEFAULT ''        COMMENT '隐患位置',
  `risk_level`    VARCHAR(10) NOT NULL DEFAULT 'low'      COMMENT '风险等级：low一般/medium较大/high重大',
  `rectify_owner_id` BIGINT UNSIGNED NULL                 COMMENT '整改责任人（关联 auth_user.id）',
  `rectify_deadline` DATE NULL                            COMMENT '整改时限',
  `rectify_evidence` VARCHAR(500) NOT NULL DEFAULT ''     COMMENT '整改凭证（关联 base_file）',
  `status`        VARCHAR(10) NOT NULL DEFAULT 'reported' COMMENT '状态：reported已上报/assigned已指派整改/rectified已整改/reviewed复核闭环',
  `review_by`     BIGINT UNSIGNED NULL                    COMMENT '复核人（关联 auth_user.id）',
  `review_at`     DATETIME NULL                           COMMENT '复核时间',
  `reporter_id`   BIGINT UNSIGNED NOT NULL                COMMENT '上报人（安保/管理员，关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上报时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_inspect_org` (`org_id`,`status`),
  KEY `idx_inspect_level` (`risk_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='校园安全巡查隐患整改表（隐患上报-指派整改-复核闭环-台账留存）';
