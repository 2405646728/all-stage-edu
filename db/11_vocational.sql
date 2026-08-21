-- =====================================================================
-- 11_vocational.sql —— 职高学段专属模块（专业实训/考证/校企合作/顶岗实习/就业）
-- 对应文档：5.7.2 文化课+专业实训教学管理 /
--           5.7.3 实训实习与校企合作专属管理 / 5.7.5 收费台账与实训财务 /
--           九章 职高阶段完整功能板块
-- 约定：职教专属闭环；实训安全禁忌关联 base_student_health.training_taboo。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 1. 专业目录（专业方向/学制/实训分组）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `voc_major`;
CREATE TABLE `voc_major` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '专业ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `major_code`  VARCHAR(32) NOT NULL                     COMMENT '专业编码（机构内唯一）',
  `major_name`  VARCHAR(100) NOT NULL                    COMMENT '专业名称（机械/化工/护理/计算机等）',
  `major_direction` VARCHAR(200) NOT NULL DEFAULT ''     COMMENT '专业方向',
  `schooling_years` TINYINT UNSIGNED NOT NULL DEFAULT 3  COMMENT '学制（弹性学制支撑）',
  `special_risk` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '专业实训安全提示（机械/化工/护理特殊禁忌）',
  `status`      TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0停办/1开办',
  `created_by`  BIGINT UNSIGNED NULL                     COMMENT '创建人（关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted`  TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '逻辑删除：0正常/1已删',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_voc_major` (`org_id`,`major_code`),
  KEY `idx_major_org` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='职高专业目录表（专业分班/实训分组基础）';

-- ---------------------------------------------------------------------
-- 2. 实训场地与设备（状态监控/借用/维保/报废备案）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `voc_training_site`;
CREATE TABLE `voc_training_site` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '场地ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `site_code`   VARCHAR(32) NOT NULL                     COMMENT '场地编码（机构内唯一）',
  `site_name`   VARCHAR(100) NOT NULL                    COMMENT '场地名称（实训车间/实验室等）',
  `major_id`    BIGINT UNSIGNED NULL                     COMMENT '绑定专业（关联 voc_major.id）',
  `capacity`    INT NOT NULL DEFAULT 0                   COMMENT '容纳人数',
  `location`    VARCHAR(200) NOT NULL DEFAULT ''         COMMENT '位置',
  `status`      TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0停用/1可用/2维护中',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_training_site` (`org_id`,`site_code`),
  KEY `idx_site_major` (`major_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='校内实训场地表（排课/设备分配冲突规避）';

DROP TABLE IF EXISTS `voc_training_device`;
CREATE TABLE `voc_training_device` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '设备ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `site_id`     BIGINT UNSIGNED NULL                     COMMENT '所属场地（关联 voc_training_site.id）',
  `device_code` VARCHAR(64) NOT NULL                     COMMENT '设备编码（唯一）',
  `device_name` VARCHAR(100) NOT NULL                    COMMENT '设备名称',
  `device_model` VARCHAR(100) NOT NULL DEFAULT ''        COMMENT '型号',
  `status`      VARCHAR(20) NOT NULL DEFAULT 'idle'      COMMENT '状态：idle闲置/in_use使用中/maintenance维保/borrowed已借出/scrapped已报废',
  `maintain_note` VARCHAR(500) NOT NULL DEFAULT ''       COMMENT '维保记录',
  `scrapped_at` DATETIME NULL                            COMMENT '报废备案时间',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '录入时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_training_device` (`device_code`),
  KEY `idx_device_org` (`org_id`,`status`),
  KEY `idx_device_site` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='实训设备表（状态监控/借用/维保/报废备案）';

DROP TABLE IF EXISTS `voc_device_borrow`;
CREATE TABLE `voc_device_borrow` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '借用ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `device_id`    BIGINT UNSIGNED NOT NULL                COMMENT '设备ID（关联 voc_training_device.id）',
  `borrower_id`  BIGINT UNSIGNED NOT NULL                COMMENT '借用人（关联 auth_user.id，教师/实训指导教师）',
  `class_id`     BIGINT UNSIGNED NULL                    COMMENT '使用班级（关联 base_class.id）',
  `borrow_time`  DATETIME NOT NULL                       COMMENT '借用时间',
  `plan_return`  DATETIME NULL                           COMMENT '计划归还时间',
  `return_time`  DATETIME NULL                           COMMENT '实际归还时间',
  `status`       VARCHAR(10) NOT NULL DEFAULT 'borrowed' COMMENT '状态：borrowed借用中/returned已归还/overdue逾期',
  `operator_id`  BIGINT UNSIGNED NULL                    COMMENT '登记人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登记时间',
  PRIMARY KEY (`id`),
  KEY `idx_borrow_device` (`device_id`,`status`),
  KEY `idx_borrow_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='实训设备借用登记表（合理分配资源，规避使用冲突）';

-- ---------------------------------------------------------------------
-- 3. 实训计划与过程记录（技能成长轨迹，毕业/实习核心佐证）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `voc_training_plan`;
CREATE TABLE `voc_training_plan` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '实训计划ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `term_id`       BIGINT UNSIGNED NOT NULL                COMMENT '学期（关联 base_term.id）',
  `class_id`      BIGINT UNSIGNED NOT NULL                COMMENT '实训班级（关联 base_class.id）',
  `major_id`      BIGINT UNSIGNED NULL                    COMMENT '专业（关联 voc_major.id）',
  `project_name`  VARCHAR(200) NOT NULL                   COMMENT '实训项目名称',
  `content`       TEXT NULL                               COMMENT '实训内容',
  `teacher_id`    BIGINT UNSIGNED NOT NULL                COMMENT '指导教师（关联 base_teacher.id）',
  `site_id`       BIGINT UNSIGNED NULL                    COMMENT '实训场地（关联 voc_training_site.id）',
  `start_date`    DATE NOT NULL                           COMMENT '开始日期',
  `end_date`      DATE NOT NULL                           COMMENT '结束日期',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_plan_org` (`org_id`,`term_id`),
  KEY `idx_plan_class` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='实训计划表（学期实训项目制定）';

DROP TABLE IF EXISTS `voc_training_record`;
CREATE TABLE `voc_training_record` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '实训记录ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `plan_id`       BIGINT UNSIGNED NOT NULL                COMMENT '实训计划（关联 voc_training_plan.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `training_date` DATE NOT NULL                           COMMENT '实训日期',
  `operation_note` VARCHAR(500) NOT NULL DEFAULT ''       COMMENT '实操过程记录',
  `operation_score` DECIMAL(6,2) NULL                     COMMENT '操作评分',
  `attendance`    VARCHAR(10) NOT NULL DEFAULT 'present'  COMMENT '实训在岗：present在岗/late迟到/absent缺勤',
  `media_files`   VARCHAR(1000) NOT NULL DEFAULT ''       COMMENT '实训图文视频台账（关联 base_file）',
  `recorder_id`   BIGINT UNSIGNED NOT NULL                COMMENT '记录教师（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  KEY `idx_training_student` (`student_id`,`training_date`),
  KEY `idx_training_plan` (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='校内实训过程记录表（技能成长轨迹归档）';

-- ---------------------------------------------------------------------
-- 4. 职业资格证书考级（技能考核/证书备案/考证通过率）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `voc_certificate`;
CREATE TABLE `voc_certificate` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '考证记录ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `cert_name`    VARCHAR(200) NOT NULL                   COMMENT '证书名称（职业资格/等级证书）',
  `cert_level`   VARCHAR(50) NOT NULL DEFAULT ''         COMMENT '证书等级',
  `cert_org`     VARCHAR(200) NOT NULL DEFAULT ''        COMMENT '颁证机构',
  `exam_date`    DATE NULL                               COMMENT '考试/考核日期',
  `score`        DECIMAL(7,2) NULL                       COMMENT '考核成绩',
  `result`       VARCHAR(10) NOT NULL DEFAULT 'pending'  COMMENT '结果：pending待考/passed通过/failed未通过',
  `cert_no`      VARCHAR(100) NOT NULL DEFAULT ''        COMMENT '证书编号',
  `cert_file`    VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '证书备案附件（关联 base_file）',
  `operator_id`  BIGINT UNSIGNED NULL                    COMMENT '登记人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登记时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_cert_student` (`student_id`),
  KEY `idx_cert_org` (`org_id`,`result`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='职业资格证书考级表（技能考核/证书备案/通过率统计）';

-- ---------------------------------------------------------------------
-- 5. 校企合作与顶岗实习（报备-分配-打卡-周月报-企业评价-考核闭环）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `voc_company`;
CREATE TABLE `voc_company` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '企业ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `company_name`  VARCHAR(200) NOT NULL                   COMMENT '企业名称',
  `qualification` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '企业资质',
  `coop_project`  VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '合作项目',
  `post_desc`     VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '实训岗位',
  `mentor_name`   VARCHAR(50) NOT NULL DEFAULT ''         COMMENT '对接导师/企业导师',
  `mentor_phone`  VARCHAR(20) NOT NULL DEFAULT ''         COMMENT '导师联系方式',
  `coop_start`    DATE NULL                               COMMENT '合作周期开始',
  `coop_end`      DATE NULL                               COMMENT '合作周期结束',
  `status`        TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '状态：0终止/1合作中',
  `created_by`    BIGINT UNSIGNED NULL                    COMMENT '备案人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '备案时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_company_org` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='校企合作单位备案表（实训基地/合作项目/企业导师）';

DROP TABLE IF EXISTS `voc_internship`;
CREATE TABLE `voc_internship` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '实习ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `company_id`    BIGINT UNSIGNED NOT NULL                COMMENT '实习单位（关联 voc_company.id）',
  `post_name`     VARCHAR(100) NOT NULL                   COMMENT '实习岗位',
  `agreement_file` VARCHAR(500) NOT NULL DEFAULT ''       COMMENT '实习协议（关联 base_file）',
  `start_date`    DATE NOT NULL                           COMMENT '实习开始日期',
  `end_date`      DATE NULL                               COMMENT '实习结束日期',
  `mentor_id`     BIGINT UNSIGNED NULL                    COMMENT '校内巡查教师（关联 base_teacher.id，线上巡查）',
  `company_score` DECIMAL(6,2) NULL                       COMMENT '企业评价得分',
  `company_comment` VARCHAR(500) NOT NULL DEFAULT ''      COMMENT '企业评价',
  `intern_status` VARCHAR(20) NOT NULL DEFAULT 'reported' COMMENT '状态：reported已报备/assigned已分配/ongoing实习中/finished已结业/abnormal异常离岗',
  `risk_note`     VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '实习风险预警/异常离岗登记',
  `operator_id`   BIGINT UNSIGNED NULL                    COMMENT '登记人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报备时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_intern_student` (`student_id`,`intern_status`),
  KEY `idx_intern_company` (`company_id`),
  KEY `idx_intern_org` (`org_id`,`intern_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='顶岗实习表（协议/岗位/企业评价/实习结业，实习状态联动毕业资格）';

DROP TABLE IF EXISTS `voc_internship_checkin`;
CREATE TABLE `voc_internship_checkin` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '打卡ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `internship_id` BIGINT UNSIGNED NOT NULL               COMMENT '实习记录（关联 voc_internship.id）',
  `checkin_date` DATE NOT NULL                           COMMENT '打卡日期',
  `checkin_time` DATETIME NULL                           COMMENT '打卡时间',
  `location`     VARCHAR(200) NOT NULL DEFAULT ''        COMMENT '打卡地点',
  `checkin_way`  VARCHAR(10) NOT NULL DEFAULT 'app'      COMMENT '方式：app手机定位/manual补录',
  `status`       VARCHAR(10) NOT NULL DEFAULT 'on_duty'  COMMENT '状态：on_duty在岗/leave离岗报备/absent缺勤',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  KEY `idx_intern_checkin` (`internship_id`,`checkin_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='顶岗实习打卡表（校外实习过程管控）';

DROP TABLE IF EXISTS `voc_internship_report`;
CREATE TABLE `voc_internship_report` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '报告ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `internship_id` BIGINT UNSIGNED NOT NULL               COMMENT '实习记录（关联 voc_internship.id）',
  `report_type`  VARCHAR(10) NOT NULL                    COMMENT '类型：weekly周报/monthly月报',
  `report_period` VARCHAR(50) NOT NULL                   COMMENT '报告周期（如 2025-W12 / 2025-03）',
  `content`      TEXT NOT NULL                           COMMENT '报告内容',
  `reviewer_id`  BIGINT UNSIGNED NULL                    COMMENT '批阅教师（关联 auth_user.id）',
  `review_note`  VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '批阅意见',
  `submitted_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  PRIMARY KEY (`id`),
  KEY `idx_report_intern` (`internship_id`,`report_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='实习周报月报表（企业实习过程文档）';

-- ---------------------------------------------------------------------
-- 6. 毕业就业台账（就业去向/岗位匹配度/升学，年度就业报表）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `voc_employment`;
CREATE TABLE `voc_employment` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '就业记录ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `graduate_year` SMALLINT UNSIGNED NOT NULL              COMMENT '毕业年份',
  `outcome_type`  VARCHAR(20) NOT NULL                    COMMENT '去向：employed就业/further_study升学/self_employed自主创业/unemployed待业/other其他',
  `company_name`  VARCHAR(200) NOT NULL DEFAULT ''        COMMENT '就业单位',
  `post_name`     VARCHAR(100) NOT NULL DEFAULT ''        COMMENT '就业岗位',
  `major_match`   VARCHAR(10) NOT NULL DEFAULT 'unknown'  COMMENT '岗位匹配度：matched对口/related相关/not_matched不对口/unknown未统计',
  `further_school` VARCHAR(200) NOT NULL DEFAULT ''       COMMENT '升学学校',
  `salary_range`  VARCHAR(50) NOT NULL DEFAULT ''         COMMENT '薪资范围（统计口径）',
  `operator_id`   BIGINT UNSIGNED NULL                    COMMENT '登记人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登记时间',
  PRIMARY KEY (`id`),
  KEY `idx_emp_org` (`org_id`,`graduate_year`),
  KEY `idx_emp_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='职高毕业就业台账表（专业就业率/办学质量督查年报）';
