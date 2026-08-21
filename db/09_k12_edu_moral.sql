-- =====================================================================
-- 09_k12_edu_moral.sql —— 教务教学 + 德育综评（小学/初中/普高通用模块）
-- 对应文档：5.3.2 小学教务教学 / 5.4.2、5.5.2 初中教务中考 /
--           5.5.2、5.6.2 普高新高考教务（选科走班部分见 10_senior_high.sql）/
--           5.3.3、5.4.3、5.5.3、5.6.3 德育学风与综评模块
-- 约定：教务/德育为独立闭环，单向依赖基础档案数据，弱联动零耦合。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 1. 课程体系配置（必修/选修/社团拓展/会考/中考核心/高考学科/实训配比）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `edu_course`;
CREATE TABLE `edu_course` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '课程ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `stage`        VARCHAR(20) NOT NULL                    COMMENT '学段',
  `grade_id`     BIGINT UNSIGNED NOT NULL                COMMENT '适用年级（关联 base_grade.id）',
  `subject_code` VARCHAR(30) NOT NULL                    COMMENT '学科编码（字典 subject_type）',
  `course_name`  VARCHAR(100) NOT NULL                   COMMENT '课程名称',
  `course_type`  VARCHAR(20) NOT NULL DEFAULT 'required' COMMENT '课程类型：required必修/elective选修/club社团拓展/exam_core中考核心/gaokao高考学科/major专业课/training实训课',
  `periods_week` TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '周课时',
  `credit`       DECIMAL(4,1) NOT NULL DEFAULT 0         COMMENT '学分/课时标准',
  `assess_way`   VARCHAR(20) NOT NULL DEFAULT 'exam'     COMMENT '考核方式：exam考试/score评分/level等级',
  `term_id`      BIGINT UNSIGNED NULL                    COMMENT '适用学期（关联 base_term.id；NULL=全学年）',
  `status`       TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '状态：0停用/1启用',
  `created_by`   BIGINT UNSIGNED NULL                    COMMENT '创建人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_course` (`org_id`,`grade_id`,`subject_code`,`term_id`),
  KEY `idx_course_org` (`org_id`,`stage`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='课程体系配置表（教学大纲/课时学分标准固化）';

-- ---------------------------------------------------------------------
-- 2. 课表与调课（智能排课结果 + 临时调课/代课/补课/停课登记）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `edu_schedule_plan`;
CREATE TABLE `edu_schedule_plan` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '课表条目ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `term_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '学期（关联 base_term.id）',
  `class_id`    BIGINT UNSIGNED NULL                     COMMENT '班级/教学班（关联 base_class.id；行政班与走班教学班共用）',
  `course_id`   BIGINT UNSIGNED NOT NULL                 COMMENT '课程（关联 edu_course.id）',
  `teacher_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '授课教师（关联 base_teacher.id）',
  `room`        VARCHAR(100) NOT NULL DEFAULT ''         COMMENT '教室/场地（冲突规避）',
  `weekday`     TINYINT UNSIGNED NOT NULL                COMMENT '星期（1~7）',
  `section_no`  TINYINT UNSIGNED NOT NULL                COMMENT '节次（1~12）',
  `start_week`  TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '起始周',
  `end_week`    TINYINT UNSIGNED NOT NULL DEFAULT 20     COMMENT '结束周',
  `schedule_type` VARCHAR(10) NOT NULL DEFAULT 'normal'  COMMENT '类型：normal正常/temp临时调课/substitute代课/makeup补课/paused停课',
  `origin_plan_id` BIGINT UNSIGNED NULL                  COMMENT '原课表条目（调课/代课溯源，关联本表id）',
  `operator_id` BIGINT UNSIGNED NULL                     COMMENT '操作人（关联 auth_user.id，排课记录永久留存）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_schedule_class` (`class_id`,`term_id`),
  KEY `idx_schedule_teacher` (`teacher_id`,`term_id`),
  KEY `idx_schedule_org` (`org_id`,`term_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='课表条目表（班级课表/教师课表/个人课表多端同步）';

DROP TABLE IF EXISTS `edu_schedule_change`;
CREATE TABLE `edu_schedule_change` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '调课登记ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `change_type`   VARCHAR(10) NOT NULL                    COMMENT '类型：adjust调课/substitute代课/makeup补课/stop停课/holiday节假日调班',
  `plan_id`       BIGINT UNSIGNED NOT NULL                COMMENT '原课表条目（关联 edu_schedule_plan.id）',
  `from_weekday`  TINYINT UNSIGNED NULL                   COMMENT '原星期',
  `from_section`  TINYINT UNSIGNED NULL                   COMMENT '原节次',
  `to_date`       DATE NULL                               COMMENT '调整至日期',
  `to_weekday`    TINYINT UNSIGNED NULL                   COMMENT '调整至星期',
  `to_section`    TINYINT UNSIGNED NULL                   COMMENT '调整至节次',
  `reason`        VARCHAR(255) NOT NULL DEFAULT ''        COMMENT '调课原因',
  `operator_id`   BIGINT UNSIGNED NOT NULL                COMMENT '登记人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登记时间',
  PRIMARY KEY (`id`),
  KEY `idx_change_org` (`org_id`,`created_at`),
  KEY `idx_change_plan` (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='调课代课补课登记表（课表实时同步更新）';

-- ---------------------------------------------------------------------
-- 3. 教学纪实与校本资源库（教案课件沉淀，纯资源模块）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `edu_teaching_record`;
CREATE TABLE `edu_teaching_record` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '纪实ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `plan_id`      BIGINT UNSIGNED NULL                    COMMENT '课表条目（关联 edu_schedule_plan.id）',
  `class_id`     BIGINT UNSIGNED NOT NULL                COMMENT '班级/教学班（关联 base_class.id）',
  `course_id`    BIGINT UNSIGNED NOT NULL                COMMENT '课程（关联 edu_course.id）',
  `teacher_id`   BIGINT UNSIGNED NOT NULL                COMMENT '授课教师（关联 base_teacher.id）',
  `teach_date`   DATE NOT NULL                           COMMENT '授课日期',
  `content`      TEXT NULL                               COMMENT '教学内容',
  `class_performance` TEXT NULL                          COMMENT '课堂表现记录',
  `attendance_note` VARCHAR(500) NOT NULL DEFAULT ''     COMMENT '出勤情况（课堂点名/缺勤学生登记）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  KEY `idx_teach_org` (`org_id`,`teach_date`),
  KEY `idx_teach_class` (`class_id`),
  KEY `idx_teach_teacher` (`teacher_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='课堂教学纪实表（授课登记/出勤/课堂台账）';

DROP TABLE IF EXISTS `edu_resource`;
CREATE TABLE `edu_resource` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '资源ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `resource_type` VARCHAR(20) NOT NULL                    COMMENT '类型：lesson_plan教案/courseware课件/exercise习题/paper试卷/reflection教学反思/material校本素材/guide实训指导手册/video操作视频',
  `subject_code`  VARCHAR(30) NOT NULL DEFAULT ''         COMMENT '学科（字典 subject_type）',
  `grade_id`      BIGINT UNSIGNED NULL                    COMMENT '适用年级（关联 base_grade.id）',
  `class_id`      BIGINT UNSIGNED NULL                    COMMENT '分层班级适配（关联 base_class.id，差异化资源）',
  `term_id`       BIGINT UNSIGNED NULL                    COMMENT '学期（关联 base_term.id）',
  `title`         VARCHAR(200) NOT NULL                   COMMENT '标题',
  `file_url`      VARCHAR(500) NOT NULL                   COMMENT '文件地址（关联 base_file）',
  `share_scope`   VARCHAR(10) NOT NULL DEFAULT 'school'   COMMENT '共享范围：school校级/dept教研组/person个人',
  `uploader_id`   BIGINT UNSIGNED NOT NULL                COMMENT '上传人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  PRIMARY KEY (`id`),
  KEY `idx_resource_org` (`org_id`,`subject_code`),
  KEY `idx_resource_grade` (`grade_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='校本教学资源库表（教案/课件/习题/真题/实训资源沉淀）';

-- ---------------------------------------------------------------------
-- 4. 考试与成绩（单元测/月考/期中期末/模考/联考/中高考全真模拟）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `exam_plan`;
CREATE TABLE `exam_plan` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '考试ID',
  `org_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `exam_name`  VARCHAR(200) NOT NULL                    COMMENT '考试名称',
  `exam_type`  VARCHAR(20) NOT NULL                     COMMENT '考试类型：unit单元测/weekly周测/monthly月考/midterm期中/final期末/model模考/union联考/mock高考模拟/zhongkao中考模拟/skill技能实操/cert考证',
  `term_id`    BIGINT UNSIGNED NOT NULL                 COMMENT '学期（关联 base_term.id）',
  `grade_id`   BIGINT UNSIGNED NULL                     COMMENT '年级范围（关联 base_grade.id；NULL=多年级）',
  `exam_date`  DATE NULL                                COMMENT '考试日期',
  `total_score` DECIMAL(7,2) NULL                       COMMENT '总分',
  `status`     VARCHAR(10) NOT NULL DEFAULT 'draft'     COMMENT '状态：draft编排中/ongoing进行中/scoring成绩录入中/finished已归档',
  `created_by` BIGINT UNSIGNED NULL                     COMMENT '创建人（关联 auth_user.id）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_exam_org` (`org_id`,`term_id`),
  KEY `idx_exam_type` (`org_id`,`exam_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='考试计划表（全阶段考试建档，成绩归档）';

DROP TABLE IF EXISTS `exam_subject`;
CREATE TABLE `exam_subject` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '考试科目ID',
  `exam_id`      BIGINT UNSIGNED NOT NULL                COMMENT '考试ID（关联 exam_plan.id）',
  `subject_code` VARCHAR(30) NOT NULL                    COMMENT '科目编码（字典 subject_type）',
  `full_score`   DECIMAL(7,2) NOT NULL                   COMMENT '满分',
  `weight`       DECIMAL(4,2) NOT NULL DEFAULT 1.00      COMMENT '权重（总分核算）',
  `exam_date`    DATE NULL                               COMMENT '科目考试时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_exam_subject` (`exam_id`,`subject_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='考试科目配置表';

DROP TABLE IF EXISTS `exam_score`;
CREATE TABLE `exam_score` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '成绩ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `exam_id`      BIGINT UNSIGNED NOT NULL                COMMENT '考试ID（关联 exam_plan.id）',
  `exam_subject_id` BIGINT UNSIGNED NOT NULL             COMMENT '考试科目（关联 exam_subject.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `class_id`     BIGINT UNSIGNED NULL                    COMMENT '班级（关联 base_class.id，统计维度）',
  `score`        DECIMAL(7,2) NULL                       COMMENT '分数（缺考为NULL）',
  `grade_level`  VARCHAR(10) NULL                        COMMENT '等级（A/B/C/D，等级换算）',
  `class_rank`   INT NULL                                COMMENT '班级排名',
  `grade_rank`   INT NULL                                COMMENT '年级排名',
  `is_absent`    TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '是否缺考：0否/1是',
  `remark`       VARCHAR(255) NOT NULL DEFAULT ''        COMMENT '备注（补考/作弊等）',
  `entry_by`     BIGINT UNSIGNED NULL                    COMMENT '录入人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '录入时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间（分数修正留痕）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_exam_score` (`exam_subject_id`,`student_id`),
  KEY `idx_score_exam` (`exam_id`),
  KEY `idx_score_student` (`student_id`),
  KEY `idx_score_class` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='考试成绩表（批量录入/排名换算/学业台账，加密归档）';

-- ---------------------------------------------------------------------
-- 5. 学情分析支撑（薄弱知识点/学业预警/分层标注，纯数据沉淀）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `edu_weak_point`;
CREATE TABLE `edu_weak_point` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '薄弱点ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `subject_code`  VARCHAR(30) NOT NULL                    COMMENT '学科（字典 subject_type）',
  `weak_desc`     VARCHAR(500) NOT NULL                   COMMENT '薄弱学科/易错知识点描述',
  `source_exam_id` BIGINT UNSIGNED NULL                   COMMENT '来源考试（关联 exam_plan.id）',
  `improve_plan`  VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '补差方案/攻坚计划',
  `follow_result` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '跟进成效（短板提升轨迹）',
  `status`        VARCHAR(10) NOT NULL DEFAULT 'open'     COMMENT '状态：open待攻坚/improving提升中/closed已闭环',
  `created_by`    BIGINT UNSIGNED NULL                    COMMENT '登记人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_weak_student` (`student_id`,`subject_code`),
  KEY `idx_weak_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学业薄弱点台账表（精准学情诊断/培优补差）';

DROP TABLE IF EXISTS `edu_study_warning`;
CREATE TABLE `edu_study_warning` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '预警ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `warning_type` VARCHAR(20) NOT NULL                    COMMENT '预警类型：lag学业滞后/bias偏科严重/model_fail模考不达标/credit_short学分不足/absent缺勤',
  `warning_level` VARCHAR(10) NOT NULL DEFAULT 'warn'    COMMENT '级别：info提醒/warn预警/critical严重',
  `content`      VARCHAR(500) NOT NULL                   COMMENT '预警内容',
  `notify_target` VARCHAR(200) NOT NULL DEFAULT ''       COMMENT '推送对象（班主任/家长/辅导员，逗号分隔user_id）',
  `status`       TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '处理状态：0未处理/1已跟进',
  `handled_by`   BIGINT UNSIGNED NULL                    COMMENT '跟进人（关联 auth_user.id）',
  `handled_at`   DATETIME NULL                           COMMENT '跟进时间',
  `handle_note`  VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '跟进记录',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预警时间',
  PRIMARY KEY (`id`),
  KEY `idx_warning_student` (`student_id`,`status`),
  KEY `idx_warning_org` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学业预警表（分层预警，单向同步家校提醒，不修改底层学业数据）';

DROP TABLE IF EXISTS `edu_tier_student`;
CREATE TABLE `edu_tier_student` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '分层ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `student_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '学生ID（关联 base_student.id）',
  `term_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '学期（关联 base_term.id）',
  `tier_type`   VARCHAR(20) NOT NULL                     COMMENT '分层：excellent培优生/borderline临界生/weak学困生/basic基础班/parallel平行班',
  `tier_class_id` BIGINT UNSIGNED NULL                   COMMENT '分层班级（关联 base_class.id）',
  `mark_line`   VARCHAR(50) NOT NULL DEFAULT ''          COMMENT '划定依据（培优线/临界线/合格线说明）',
  `operator_id` BIGINT UNSIGNED NULL                     COMMENT '调整人（关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '标注时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tier_student` (`student_id`,`term_id`),
  KEY `idx_tier_org` (`org_id`,`tier_type`),
  KEY `idx_tier_class` (`tier_class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学业分层标注表（培优/临界/学困分层教学）';


-- ---------------------------------------------------------------------
-- 6. 德育奖惩（多维评分 + 积分累加 + 违纪处分台账）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `moral_score_rule`;
CREATE TABLE `moral_score_rule` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '评分规则ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `dimension`    VARCHAR(20) NOT NULL                    COMMENT '德育维度：discipline纪律/hygiene卫生/etiquette礼仪/study学习/labor劳动/safety安全/attendance出勤/style学风/classroom课堂/dress仪容仪表/practice劳动实践',
  `rule_name`    VARCHAR(100) NOT NULL                   COMMENT '规则名称',
  `score_value`  DECIMAL(6,2) NOT NULL                   COMMENT '分值（加分正/扣分负）',
  `status`       TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '状态：0停用/1启用',
  `created_by`   BIGINT UNSIGNED NULL                    COMMENT '创建人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_rule_org` (`org_id`,`dimension`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='德育评分标准表（自定义加分扣分规则）';

DROP TABLE IF EXISTS `moral_record`;
CREATE TABLE `moral_record` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '奖惩记录ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `class_id`     BIGINT UNSIGNED NULL                    COMMENT '班级ID（关联 base_class.id）',
  `record_type`  VARCHAR(10) NOT NULL                    COMMENT '类型：reward奖励/punish违纪/rectify整改/good好事/civilized文明表现',
  `dimension`    VARCHAR(20) NOT NULL                    COMMENT '维度（对应 moral_score_rule.dimension）',
  `score`        DECIMAL(6,2) NOT NULL DEFAULT 0         COMMENT '积分变动（德育积分累加依据）',
  `reason`       VARCHAR(500) NOT NULL                   COMMENT '奖惩事由',
  `evidence_file` VARCHAR(500) NOT NULL DEFAULT ''       COMMENT '佐证材料（关联 base_file）',
  `handle_result` VARCHAR(255) NOT NULL DEFAULT ''       COMMENT '处理结果（警告/处分/撤销处分台账）',
  `punish_level` VARCHAR(20) NULL                        COMMENT '处分级别：warning警告/serious严重警告/demerit记过/expel留校察看',
  `revoke_status` TINYINT UNSIGNED NOT NULL DEFAULT 0    COMMENT '是否已撤销处分：0否/1是',
  `revoke_at`    DATETIME NULL                           COMMENT '撤销时间',
  `recorder_id`  BIGINT UNSIGNED NOT NULL                COMMENT '登记人（班主任/德育管理员，关联 auth_user.id）',
  `occurred_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发生/登记时间',
  PRIMARY KEY (`id`),
  KEY `idx_moral_student` (`student_id`,`occurred_at`),
  KEY `idx_moral_class` (`class_id`),
  KEY `idx_moral_org` (`org_id`,`record_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='日常德育奖惩登记表（个人德育积分台账，单向同步综评）';

-- ---------------------------------------------------------------------
-- 7. 班级量化考核（班风学风周评/月评/学期评比）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `moral_class_eval`;
CREATE TABLE `moral_class_eval` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '考核ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `class_id`     BIGINT UNSIGNED NOT NULL                COMMENT '班级ID（关联 base_class.id，行政班/教学班双重维度）',
  `eval_period`  VARCHAR(10) NOT NULL                    COMMENT '考核周期：day日/week周/month月/term学期',
  `period_start` DATE NOT NULL                           COMMENT '周期开始',
  `period_end`   DATE NOT NULL                           COMMENT '周期结束',
  `discipline_score` DECIMAL(6,2) NOT NULL DEFAULT 0     COMMENT '纪律得分',
  `hygiene_score` DECIMAL(6,2) NOT NULL DEFAULT 0        COMMENT '卫生得分',
  `attendance_score` DECIMAL(6,2) NOT NULL DEFAULT 0     COMMENT '出勤得分',
  `activity_score` DECIMAL(6,2) NOT NULL DEFAULT 0       COMMENT '活动得分',
  `study_style_score` DECIMAL(6,2) NOT NULL DEFAULT 0    COMMENT '学风/自习得分',
  `total_score`  DECIMAL(8,2) NOT NULL DEFAULT 0         COMMENT '总分',
  `rank_no`      INT NULL                                COMMENT '全校排名（文明班级评选依据）',
  `remark`       VARCHAR(255) NOT NULL DEFAULT ''        COMMENT '备注',
  `operator_id`  BIGINT UNSIGNED NULL                    COMMENT '统计人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '生成时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_class_eval` (`class_id`,`eval_period`,`period_start`),
  KEY `idx_eval_org` (`org_id`,`period_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='班级量化考核表（文明班级/优秀集体评选支撑）';

-- ---------------------------------------------------------------------
-- 8. 德育活动/班会/社会实践/志愿服务/入团入党培养（综评佐证素材）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `moral_activity`;
CREATE TABLE `moral_activity` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '活动记录ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NULL                    COMMENT '学生ID（个人参与，关联 base_student.id；NULL=班级集体活动）',
  `class_id`      BIGINT UNSIGNED NULL                    COMMENT '班级ID（关联 base_class.id）',
  `activity_type` VARCHAR(20) NOT NULL                    COMMENT '类型：class_meeting主题班会/moral德育宣讲/legal法治教育/volunteer志愿服务/practice社会实践/labor劳动教育/research研学/league入团/youth团日/party入党积极分子培养',
  `title`         VARCHAR(200) NOT NULL                   COMMENT '活动标题',
  `content`       TEXT NULL                               COMMENT '活动内容记录',
  `evidence_file` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '佐证材料（关联 base_file）',
  `activity_date` DATE NOT NULL                           COMMENT '活动日期',
  `performance`   VARCHAR(255) NOT NULL DEFAULT ''        COMMENT '表现评价',
  `recorder_id`   BIGINT UNSIGNED NOT NULL                COMMENT '记录人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  KEY `idx_moral_act_student` (`student_id`),
  KEY `idx_moral_act_class` (`class_id`),
  KEY `idx_moral_act_org` (`org_id`,`activity_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='德育活动与社会实践表（班会/志愿/入团/研学台账归档）';

-- ---------------------------------------------------------------------
-- 9. 谈心谈话与心理跟进（重点学生台账，私密独立存储）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `moral_talk`;
CREATE TABLE `moral_talk` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '谈话记录ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `talk_type`     VARCHAR(20) NOT NULL DEFAULT 'heart'    COMMENT '类型：heart谈心谈话/psycho心理测评/counsel心理疏导/follow跟进',
  `talk_content`  TEXT NOT NULL                           COMMENT '谈话/疏导内容（密文存储）',
  `student_state` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '学生心理状态（情绪波动/学业压力/焦虑，密文存储）',
  `follow_plan`   VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '跟进方案',
  `improve_note`  VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '阶段性改善情况',
  `is_key_student` TINYINT UNSIGNED NOT NULL DEFAULT 0    COMMENT '是否重点学生台账：0否/1是',
  `talker_id`     BIGINT UNSIGNED NOT NULL                COMMENT '谈话人（班主任/校医/心理教师，关联 auth_user.id）',
  `talked_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '谈话时间',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_talk_student` (`student_id`,`talked_at`),
  KEY `idx_talk_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生谈心谈话心理跟进表（青春期心理疏导/重点学生长效管护，私密隔离）';

-- ---------------------------------------------------------------------
-- 10. 综合素质评价（五大维度过程性记录，官方综评档案）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `moral_comprehensive_eval`;
CREATE TABLE `moral_comprehensive_eval` (
  `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '综评记录ID',
  `org_id`         BIGINT UNSIGNED NOT NULL               COMMENT '机构ID（关联 sys_org.id）',
  `student_id`     BIGINT UNSIGNED NOT NULL               COMMENT '学生ID（关联 base_student.id）',
  `term_id`        BIGINT UNSIGNED NOT NULL               COMMENT '学期（关联 base_term.id）',
  `eval_standard`  VARCHAR(20) NOT NULL DEFAULT 'k12'     COMMENT '评价标准：k12义务教育五维/voc职业素养六维/uni高校综测六维/gaokao升学综评',
  `morality_score` DECIMAL(6,2) NOT NULL DEFAULT 0        COMMENT '思想品德',
  `study_score`    DECIMAL(6,2) NOT NULL DEFAULT 0        COMMENT '学业水平/文化课学业',
  `health_score`   DECIMAL(6,2) NOT NULL DEFAULT 0        COMMENT '身心健康',
  `art_score`      DECIMAL(6,2) NOT NULL DEFAULT 0        COMMENT '艺术素养/文体活动',
  `practice_score` DECIMAL(6,2) NOT NULL DEFAULT 0        COMMENT '社会实践/志愿服务',
  `extra_score`    DECIMAL(6,2) NOT NULL DEFAULT 0        COMMENT '拓展维度（职业素养/科创竞赛/备考态度/纪律作风）',
  `total_score`    DECIMAL(8,2) NOT NULL DEFAULT 0        COMMENT '综评总分',
  `comment`        VARCHAR(1000) NOT NULL DEFAULT ''      COMMENT '评语（班主任/辅导员过程性评语）',
  `eval_status`    VARCHAR(10) NOT NULL DEFAULT 'draft'   COMMENT '状态：draft草稿/settled定稿/archived已归档（官方综评档案）',
  `evaluator_id`   BIGINT UNSIGNED NULL                   COMMENT '评价人（关联 auth_user.id）',
  `created_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_comprehensive` (`student_id`,`term_id`),
  KEY `idx_eval_org` (`org_id`,`term_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生综合素质评价表（过程性评分汇总，毕业认定/升学归档依据）';
