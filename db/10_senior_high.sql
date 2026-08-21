-- =====================================================================
-- 10_senior_high.sql —— 普高学段专属模块（新高考选科走班/分层教学/高考升学）
-- 对应文档：5.5.2、5.6.2 新高考选科走班与分层教学管理 /
--           5.5.3 普高模考学情、精准考评与高考升学管理 /
--           5.4.3 普高培优补差与升学备考专属管理
-- 约定：普高专属闭环，选科/分层/走班数据独立存储，无跨模块耦合。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 1. 新高考选科规则（3+1+2 / 3+3 双模式，选科时段/组合/人数阈值）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `high_selection_rule`;
CREATE TABLE `high_selection_rule` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `grade_id`      BIGINT UNSIGNED NOT NULL                COMMENT '适用年级（关联 base_grade.id）',
  `rule_mode`     VARCHAR(10) NOT NULL DEFAULT '3+1+2'    COMMENT '选科模式：3+1+2 / 3+3',
  `valid_combos`  TEXT NULL                               COMMENT '合规选科组合清单（JSON数组，预设所有合规组合）',
  `open_status`   TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '选科通道：0关闭/1开启',
  `select_start`  DATETIME NULL                           COMMENT '选科开始时间',
  `select_end`    DATETIME NULL                           COMMENT '选科截止时间（锁定最终结果）',
  `min_students`  INT NOT NULL DEFAULT 0                  COMMENT '组合最少人数阈值（低于阈值提示调整）',
  `reselect_times` TINYINT UNSIGNED NOT NULL DEFAULT 1    COMMENT '允许改选次数（弃选改选规则）',
  `status`        TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '规则状态：0停用/1启用',
  `created_by`    BIGINT UNSIGNED NULL                    COMMENT '配置人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_selection_rule` (`org_id`,`grade_id`),
  CONSTRAINT `chk_selection_mode` CHECK (`rule_mode` IN ('3+1+2','3+3'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='新高考选科规则配置表（组合校验/时段/阈值固化）';

-- ---------------------------------------------------------------------
-- 2. 学生选科（线上自主选科 + 二次微调 + 班主任审核确认）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `high_selection_choice`;
CREATE TABLE `high_selection_choice` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '选科ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `rule_id`      BIGINT UNSIGNED NOT NULL                COMMENT '选科规则（关联 high_selection_rule.id）',
  `combo_code`   VARCHAR(20) NOT NULL                    COMMENT '选科组合编码（如 物化生/历政地）',
  `combo_detail` VARCHAR(100) NOT NULL DEFAULT ''        COMMENT '组合明细（首选+再选科目）',
  `choice_round` TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '选科轮次（初次/微调轮次）',
  `status`       VARCHAR(10) NOT NULL DEFAULT 'pending'  COMMENT '状态：pending待审核/confirmed已确认/locked已锁定/canceled已弃选',
  `audit_by`     BIGINT UNSIGNED NULL                    COMMENT '班主任审核人（关联 auth_user.id）',
  `audit_at`     DATETIME NULL                           COMMENT '审核时间',
  `audit_remark` VARCHAR(255) NOT NULL DEFAULT ''        COMMENT '审核意见（选科合规性校验）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '选科时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_choice_student` (`student_id`,`status`),
  KEY `idx_choice_combo` (`org_id`,`combo_code`),
  KEY `idx_choice_rule` (`rule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生选科表（自主选科/改选/审核确认，生成个人选科档案）';

-- ---------------------------------------------------------------------
-- 3. 分层走班（分层班级 + 走班教学班成员，固定行政班+动态教学班双架构）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `high_tier_class`;
CREATE TABLE `high_tier_class` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '分层班级ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `class_id`    BIGINT UNSIGNED NOT NULL                 COMMENT '对应班级（关联 base_class.id，class_type=tier）',
  `tier_type`   VARCHAR(20) NOT NULL                     COMMENT '层级：excellent培优重点班/parallel平行班/basic补差基础班',
  `base_on`     VARCHAR(100) NOT NULL DEFAULT ''         COMMENT '分层依据（入学成绩/历次模考学情）',
  `term_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '学期（关联 base_term.id，学期分层调整）',
  `operator_id` BIGINT UNSIGNED NULL                     COMMENT '调整人（关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tier_class` (`class_id`,`term_id`),
  KEY `idx_tier_org` (`org_id`,`tier_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='普高分层班级配置表（培优班/平行班/基础班）';

DROP TABLE IF EXISTS `high_walk_class_member`;
CREATE TABLE `high_walk_class_member` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '走班成员ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `walk_class_id` BIGINT UNSIGNED NOT NULL               COMMENT '走班教学班（关联 base_class.id，class_type=walk）',
  `student_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '学生ID（关联 base_student.id）',
  `subject_code` VARCHAR(30) NOT NULL                    COMMENT '走班科目（选科学科）',
  `term_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '学期（关联 base_term.id）',
  `status`      TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0已退出/1在班',
  `operator_id` BIGINT UNSIGNED NULL                     COMMENT '调整人（关联 auth_user.id，微调走班名单留痕）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '入班时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_walk_member` (`walk_class_id`,`student_id`,`term_id`),
  KEY `idx_walk_student` (`student_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='走班教学班成员表（行政班+教学班双重归属）';

-- ---------------------------------------------------------------------
-- 4. 新高考赋分规则（等级赋分换算，模考分数统计适配）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `high_score_conversion`;
CREATE TABLE `high_score_conversion` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '赋分规则ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `subject_code` VARCHAR(30) NOT NULL                    COMMENT '赋分科目（再选科目）',
  `grade_band`   VARCHAR(10) NOT NULL                    COMMENT '等级（A/B/C/D/E）',
  `rank_from`    DECIMAL(5,2) NOT NULL                   COMMENT '排名区间下限（百分比）',
  `rank_to`      DECIMAL(5,2) NOT NULL                   COMMENT '排名区间上限（百分比）',
  `score_from`   TINYINT UNSIGNED NOT NULL               COMMENT '赋分下限',
  `score_to`     TINYINT UNSIGNED NOT NULL               COMMENT '赋分上限',
  `term_id`      BIGINT UNSIGNED NULL                    COMMENT '适用学期（关联 base_term.id；NULL=长期）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_conversion` (`org_id`,`subject_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='新高考等级赋分规则表（模考赋分统计适配）';

-- ---------------------------------------------------------------------
-- 5. 高考备考台账（模考累计/志愿预填报/报名资格预审/备考计划）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `high_gaokao_prep`;
CREATE TABLE `high_gaokao_prep` (
  `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '备考台账ID',
  `org_id`         BIGINT UNSIGNED NOT NULL               COMMENT '机构ID（关联 sys_org.id）',
  `student_id`     BIGINT UNSIGNED NOT NULL               COMMENT '学生ID（关联 base_student.id）',
  `school_year_id` BIGINT UNSIGNED NOT NULL               COMMENT '学年（关联 base_school_year.id，高三备考学年）',
  `prep_plan`      VARCHAR(1000) NOT NULL DEFAULT ''      COMMENT '备考计划/培优补差任务',
  `target_school`  VARCHAR(200) NOT NULL DEFAULT ''       COMMENT '目标院校',
  `aspiration_type` VARCHAR(20) NULL                      COMMENT '志愿意向：volunteer_first志愿批次/college_choice院校选择',
  `volunteer_info` VARCHAR(500) NOT NULL DEFAULT ''       COMMENT '志愿预填报信息',
  `register_qualify` VARCHAR(10) NOT NULL DEFAULT 'unchecked' COMMENT '高考报名资格预审：unchecked未核验/passed通过/failed不通过',
  `graduate_credit_check` VARCHAR(10) NOT NULL DEFAULT 'unchecked' COMMENT '毕业学分核验：unchecked/passed/failed',
  `mock_summary`   VARCHAR(1000) NOT NULL DEFAULT ''      COMMENT '模考累计统计/达标情况摘要',
  `prep_status`    VARCHAR(10) NOT NULL DEFAULT 'preparing' COMMENT '备考状态：preparing备考中/tracking跟踪中/finished已结束',
  `operator_id`    BIGINT UNSIGNED NULL                   COMMENT '登记人（关联 auth_user.id）',
  `created_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_gaokao_prep` (`student_id`,`school_year_id`),
  KEY `idx_prep_org` (`org_id`,`prep_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='高考备考台账表（报名核验/志愿预填报/毕业学分/备考闭环）';

-- ---------------------------------------------------------------------
-- 6. 毕业升学去向台账（高考成绩/录取院校/复读，年度升学报表支撑）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `high_graduation_outcome`;
CREATE TABLE `high_graduation_outcome` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '升学记录ID',
  `org_id`          BIGINT UNSIGNED NOT NULL              COMMENT '机构ID（关联 sys_org.id）',
  `student_id`      BIGINT UNSIGNED NOT NULL              COMMENT '学生ID（关联 base_student.id）',
  `graduate_year`   SMALLINT UNSIGNED NOT NULL            COMMENT '毕业年份',
  `gaokao_total`    DECIMAL(7,2) NULL                     COMMENT '高考总分',
  `gaokao_rank`     INT NULL                              COMMENT '省/市排名',
  `outcome_type`    VARCHAR(20) NOT NULL                  COMMENT '去向类型：admitted录取/repeat复读/employment就业/other其他',
  `admitted_school` VARCHAR(200) NOT NULL DEFAULT ''      COMMENT '录取院校',
  `admitted_major`  VARCHAR(200) NOT NULL DEFAULT ''      COMMENT '录取专业',
  `batch_type`      VARCHAR(20) NOT NULL DEFAULT ''       COMMENT '录取批次（本科/专科/提前批）',
  `remark`          VARCHAR(500) NOT NULL DEFAULT ''      COMMENT '备注',
  `operator_id`     BIGINT UNSIGNED NULL                  COMMENT '登记人（关联 auth_user.id）',
  `created_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登记时间',
  PRIMARY KEY (`id`),
  KEY `idx_outcome_org` (`org_id`,`graduate_year`),
  KEY `idx_outcome_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='普高毕业升学去向表（升学率/录取台账/升学统计年报）';
