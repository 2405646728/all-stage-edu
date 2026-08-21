-- =====================================================================
-- 12_university.sql —— 大学高校学段专属模块（学分制/选课绩点/综测评奖/
--                      科创论文/学位就业/宿舍后勤）
-- 对应文档：10.1.1~10.1.7 高校基础档案/学分教务/综测科创/论文就业/宿舍后勤/
--           考勤安防健康/收费抵扣
-- 约定：高校专属闭环，学分/绩点数据独立加密存储，权限隔离。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 1. 院系 / 专业 / 培养方案（学校-院系-专业-年级-班级五级架构支撑）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `uni_department`;
CREATE TABLE `uni_department` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '院系ID',
  `org_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `dept_code`  VARCHAR(32) NOT NULL                     COMMENT '院系编码（机构内唯一）',
  `dept_name`  VARCHAR(100) NOT NULL                    COMMENT '院系名称',
  `leader_id`  BIGINT UNSIGNED NULL                     COMMENT '院系负责人（关联 base_teacher.id）',
  `status`     TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0撤销/1正常',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '逻辑删除：0正常/1已删',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dept` (`org_id`,`dept_code`),
  KEY `idx_dept_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='高校院系表（五级组织架构第二级）';

DROP TABLE IF EXISTS `uni_major`;
CREATE TABLE `uni_major` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '专业ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `dept_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '所属院系（关联 uni_department.id）',
  `major_code`  VARCHAR(32) NOT NULL                     COMMENT '专业代码（机构内唯一）',
  `major_name`  VARCHAR(100) NOT NULL                    COMMENT '专业名称',
  `schooling_years` TINYINT UNSIGNED NOT NULL DEFAULT 4  COMMENT '学制年限',
  `degree_type` VARCHAR(20) NOT NULL DEFAULT 'bachelor'  COMMENT '学位类型：bachelor学士/master硕士/doctor博士',
  `status`      TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0停招/1招生',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted`  TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '逻辑删除：0正常/1已删',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_uni_major` (`org_id`,`major_code`),
  KEY `idx_major_dept` (`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='高校专业表（五级组织架构第三级）';

DROP TABLE IF EXISTS `uni_training_program`;
CREATE TABLE `uni_training_program` (
  `id`               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '培养方案ID',
  `org_id`           BIGINT UNSIGNED NOT NULL             COMMENT '机构ID（关联 sys_org.id）',
  `major_id`         BIGINT UNSIGNED NOT NULL             COMMENT '专业（关联 uni_major.id）',
  `grade_id`         BIGINT UNSIGNED NOT NULL             COMMENT '适用年级（关联 base_grade.id）',
  `program_name`     VARCHAR(200) NOT NULL                COMMENT '方案名称',
  `min_credits`      DECIMAL(6,1) NOT NULL                COMMENT '毕业最低学分',
  `deduction_rule`   VARCHAR(500) NOT NULL DEFAULT ''     COMMENT '学分抵扣规则（证书/竞赛/实践抵扣说明）',
  `status`           TINYINT UNSIGNED NOT NULL DEFAULT 1  COMMENT '状态：0停用/1启用',
  `created_by`       BIGINT UNSIGNED NULL                 COMMENT '创建人（关联 auth_user.id）',
  `created_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_program` (`major_id`,`grade_id`),
  KEY `idx_program_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='专业培养方案表（毕业学分/抵扣规则固化）';

DROP TABLE IF EXISTS `uni_program_course`;
CREATE TABLE `uni_program_course` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '方案课程ID',
  `program_id`   BIGINT UNSIGNED NOT NULL                COMMENT '培养方案（关联 uni_training_program.id）',
  `course_code`  VARCHAR(32) NOT NULL                    COMMENT '课程代码',
  `course_name`  VARCHAR(200) NOT NULL                   COMMENT '课程名称',
  `course_type`  VARCHAR(20) NOT NULL                    COMMENT '课程类型：required必修/elective选修/public公共/major专业/practice实践',
  `credit`       DECIMAL(4,1) NOT NULL                   COMMENT '学分',
  `required_flag` TINYINT UNSIGNED NOT NULL DEFAULT 0    COMMENT '是否必修：0否/1是（修读要求）',
  `advised_term` TINYINT UNSIGNED NULL                   COMMENT '建议修读学期',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_program_course` (`program_id`,`course_code`),
  KEY `idx_pc_program` (`program_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='培养方案课程表（必修/选修/公共/专业/实践学分标准）';

-- ---------------------------------------------------------------------
-- 2. 开课与选课（选课时段/人数上限/修读资格校验/退课）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `uni_course_offer`;
CREATE TABLE `uni_course_offer` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '开课ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `term_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '学期（关联 base_term.id）',
  `program_course_id` BIGINT UNSIGNED NOT NULL           COMMENT '方案课程（关联 uni_program_course.id）',
  `course_no`   VARCHAR(40) NOT NULL                     COMMENT '开课编号（教学班号）',
  `teacher_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '授课教师（关联 base_teacher.id）',
  `capacity`    INT NOT NULL                             COMMENT '课程人数上限',
  `selected_count` INT NOT NULL DEFAULT 0                COMMENT '已选人数',
  `select_start` DATETIME NULL                           COMMENT '选课开始时间',
  `select_end`  DATETIME NULL                            COMMENT '选课结束时间',
  `class_hours` TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '课时',
  `room`        VARCHAR(100) NOT NULL DEFAULT ''         COMMENT '教室',
  `status`      VARCHAR(10) NOT NULL DEFAULT 'open'      COMMENT '状态：open开放选课/closed已截止/canceled停开',
  `created_by`  BIGINT UNSIGNED NULL                     COMMENT '开课人（关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_course_offer` (`org_id`,`term_id`,`course_no`),
  KEY `idx_offer_term` (`term_id`),
  KEY `idx_offer_teacher` (`teacher_id`,`term_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='开课表（学期开课/容量/选课时段，大班授课小班研讨）';

DROP TABLE IF EXISTS `uni_course_select`;
CREATE TABLE `uni_course_select` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '选课ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `offer_id`     BIGINT UNSIGNED NOT NULL                COMMENT '开课（关联 uni_course_offer.id）',
  `term_id`      BIGINT UNSIGNED NOT NULL                COMMENT '学期（关联 base_term.id）',
  `select_status` VARCHAR(10) NOT NULL DEFAULT 'selected' COMMENT '状态：selected已选/dropped已退课/confirmed锁定',
  `select_time`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '选课时间',
  `drop_time`    DATETIME NULL                           COMMENT '退课时间',
  `operator_id`  BIGINT UNSIGNED NULL                    COMMENT '操作人（学生本人/教务代选，关联 auth_user.id）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_course_select` (`student_id`,`offer_id`),
  KEY `idx_select_offer` (`offer_id`),
  KEY `idx_select_student` (`student_id`,`term_id`,`select_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生选课表（自主选课/退课，超学分违规选课校验）';

-- ---------------------------------------------------------------------
-- 3. 成绩与绩点（总成绩核算/GPA/补考重修/学业预警）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `uni_score`;
CREATE TABLE `uni_score` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '成绩ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `offer_id`     BIGINT UNSIGNED NOT NULL                COMMENT '开课（关联 uni_course_offer.id）',
  `term_id`      BIGINT UNSIGNED NOT NULL                COMMENT '学期（关联 base_term.id）',
  `usual_score`  DECIMAL(6,2) NULL                       COMMENT '平时成绩',
  `exam_score`   DECIMAL(6,2) NULL                       COMMENT '期中期末成绩',
  `practice_score` DECIMAL(6,2) NULL                     COMMENT '实践成绩',
  `total_score`  DECIMAL(6,2) NULL                       COMMENT '课程总成绩',
  `grade_point`  DECIMAL(4,2) NULL                       COMMENT '课程绩点',
  `credit`       DECIMAL(4,1) NOT NULL DEFAULT 0         COMMENT '获得学分',
  `status`       VARCHAR(10) NOT NULL DEFAULT 'normal'   COMMENT '状态：normal正常/makeup补考/retake重修/passed通过/failed挂科',
  `review_status` VARCHAR(10) NOT NULL DEFAULT 'none'    COMMENT '复核状态：none未申请/reviewing复核中/done已复核（成绩复核）',
  `entry_by`     BIGINT UNSIGNED NULL                    COMMENT '录入教师（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '录入时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_uni_score` (`student_id`,`offer_id`),
  KEY `idx_score_term` (`term_id`),
  KEY `idx_score_offer` (`offer_id`),
  KEY `idx_score_status` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='高校课程成绩表（总成绩/绩点GPA核算，成绩单/学期绩点报表）';

DROP TABLE IF EXISTS `uni_makeup_retake`;
CREATE TABLE `uni_makeup_retake` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '补考重修ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `student_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '学生ID（关联 base_student.id）',
  `score_id`    BIGINT UNSIGNED NOT NULL                 COMMENT '原成绩（关联 uni_score.id）',
  `apply_type`  VARCHAR(10) NOT NULL                     COMMENT '类型：makeup补考/retake重修',
  `term_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '学期（关联 base_term.id）',
  `apply_status` VARCHAR(10) NOT NULL DEFAULT 'pending'  COMMENT '报名状态：pending待审批/approved通过/rejected驳回',
  `new_score`   DECIMAL(6,2) NULL                        COMMENT '补考/重修成绩',
  `new_credit`  DECIMAL(4,1) NULL                        COMMENT '学分补录',
  `operator_id` BIGINT UNSIGNED NULL                     COMMENT '登记人（关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
  PRIMARY KEY (`id`),
  KEY `idx_makeup_student` (`student_id`,`term_id`),
  KEY `idx_makeup_score` (`score_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='补考重修登记表（挂科/学分补录闭环）';

DROP TABLE IF EXISTS `uni_academic_warning`;
CREATE TABLE `uni_academic_warning` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '预警ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `term_id`      BIGINT UNSIGNED NOT NULL                COMMENT '学期（关联 base_term.id）',
  `warning_type` VARCHAR(20) NOT NULL                    COMMENT '类型：credit_short学分不足/fail多门挂科/low_gpa绩点过低/retain留级预警',
  `warning_level` VARCHAR(10) NOT NULL DEFAULT 'warn'    COMMENT '级别：low低年级预警/high高年级留级预警',
  `content`      VARCHAR(500) NOT NULL                   COMMENT '预警内容',
  `counselor_id` BIGINT UNSIGNED NULL                    COMMENT '辅导员（跟进整改，关联 base_teacher.id）',
  `status`       TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '状态：0未处理/1已跟进',
  `handle_note`  VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '跟进整改记录',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预警时间',
  PRIMARY KEY (`id`),
  KEY `idx_uni_warning_student` (`student_id`,`term_id`),
  KEY `idx_uni_warning_org` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='高校学业预警表（学分/绩点不达标自动识别，辅导员跟进闭环）';


-- ---------------------------------------------------------------------
-- 4. 综合素质测评与评奖评优（六维综测/奖助荣誉/科创竞赛/社团实践）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `uni_comprehensive_eval`;
CREATE TABLE `uni_comprehensive_eval` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '综测ID',
  `org_id`        BIGINT UNSIGNED NOT NULL               COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL               COMMENT '学生ID（关联 base_student.id）',
  `school_year_id` BIGINT UNSIGNED NOT NULL              COMMENT '学年（关联 base_school_year.id）',
  `study_score`   DECIMAL(8,2) NOT NULL DEFAULT 0        COMMENT '学业成绩维度',
  `moral_score`   DECIMAL(8,2) NOT NULL DEFAULT 0        COMMENT '德育表现维度',
  `innovation_score` DECIMAL(8,2) NOT NULL DEFAULT 0     COMMENT '科创竞赛维度',
  `sport_score`   DECIMAL(8,2) NOT NULL DEFAULT 0        COMMENT '文体活动维度',
  `volunteer_score` DECIMAL(8,2) NOT NULL DEFAULT 0      COMMENT '志愿服务维度',
  `practice_score` DECIMAL(8,2) NOT NULL DEFAULT 0       COMMENT '社会实践维度',
  `total_score`   DECIMAL(10,2) NOT NULL DEFAULT 0       COMMENT '综测总分（自动核算）',
  `rank_no`       INT NULL                               COMMENT '综测排名（评奖评优/保研推优依据）',
  `audit_status`  VARCHAR(10) NOT NULL DEFAULT 'pending' COMMENT '状态：pending待辅导员审核/reviewed院系复核/settled定稿',
  `audit_by`      BIGINT UNSIGNED NULL                   COMMENT '审核人（关联 auth_user.id）',
  `audit_at`      DATETIME NULL                          COMMENT '审核时间',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_uni_eval` (`student_id`,`school_year_id`),
  KEY `idx_uni_eval_org` (`org_id`,`school_year_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='高校综合素质测评表（六维自动核算，年度综测档案）';

DROP TABLE IF EXISTS `uni_eval_item`;
CREATE TABLE `uni_eval_item` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '申报项ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `school_year_id` BIGINT UNSIGNED NOT NULL              COMMENT '学年（关联 base_school_year.id）',
  `item_type`    VARCHAR(20) NOT NULL                    COMMENT '类型：study学业/moral德育/innovation科创/sport文体/volunteer志愿/practice实践',
  `item_name`    VARCHAR(200) NOT NULL                   COMMENT '申报事项名称',
  `evidence_file` VARCHAR(500) NOT NULL DEFAULT ''       COMMENT '佐证材料（关联 base_file）',
  `apply_score`  DECIMAL(8,2) NOT NULL DEFAULT 0         COMMENT '申报加分',
  `audit_status` VARCHAR(10) NOT NULL DEFAULT 'pending'  COMMENT '状态：pending待审/approved通过/rejected驳回',
  `audit_by`     BIGINT UNSIGNED NULL                    COMMENT '审核人（辅导员，关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申报时间',
  PRIMARY KEY (`id`),
  KEY `idx_eval_item_student` (`student_id`,`school_year_id`),
  KEY `idx_eval_item_org` (`org_id`,`audit_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='综测申报项表（学生自主申报/辅导员审核/院系复核）';

DROP TABLE IF EXISTS `uni_scholarship`;
CREATE TABLE `uni_scholarship` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '评优ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `project_name` VARCHAR(200) NOT NULL                   COMMENT '评优项目（校级/省级/国家级奖学金、优秀学生/干部/毕业生）',
  `project_level` VARCHAR(10) NOT NULL DEFAULT 'school'  COMMENT '级别：school校级/province省级/nation国家级',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `school_year_id` BIGINT UNSIGNED NOT NULL              COMMENT '学年（关联 base_school_year.id）',
  `amount`       DECIMAL(12,2) NOT NULL DEFAULT 0        COMMENT '奖助金额（元，关联财务抵扣 fin_reduction）',
  `award_file`   VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '荣誉证书/评优文件（关联 base_file）',
  `status`       VARCHAR(10) NOT NULL DEFAULT 'applied'  COMMENT '状态：applied已申报/reviewed审核中/public公示/approved通过/archived归档',
  `public_at`    DATETIME NULL                           COMMENT '公示时间',
  `operator_id`  BIGINT UNSIGNED NULL                    COMMENT '经办人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申报时间',
  PRIMARY KEY (`id`),
  KEY `idx_scholar_student` (`student_id`,`school_year_id`),
  KEY `idx_scholar_org` (`org_id`,`project_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='奖学金评优表（申报/审核/公示/归档，荣誉档案）';

DROP TABLE IF EXISTS `uni_innovation`;
CREATE TABLE `uni_innovation` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '科创项目ID',
  `org_id`        BIGINT UNSIGNED NOT NULL               COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL               COMMENT '负责人学生（关联 base_student.id）',
  `tutor_id`      BIGINT UNSIGNED NULL                   COMMENT '指导教师（关联 base_teacher.id）',
  `project_type`  VARCHAR(20) NOT NULL                   COMMENT '类型：innovation大创项目/competition科创竞赛/research科研课题/patent专利/paper论文',
  `project_name`  VARCHAR(200) NOT NULL                  COMMENT '项目/课题名称',
  `progress_note` VARCHAR(500) NOT NULL DEFAULT ''       COMMENT '项目进度登记',
  `award_level`   VARCHAR(50) NOT NULL DEFAULT ''        COMMENT '获奖等级',
  `award_file`    VARCHAR(500) NOT NULL DEFAULT ''       COMMENT '获奖证书（关联 base_file）',
  `conclusion_file` VARCHAR(500) NOT NULL DEFAULT ''     COMMENT '结题证明（关联 base_file）',
  `status`        VARCHAR(10) NOT NULL DEFAULT 'ongoing' COMMENT '状态：ongoing进行中/awarded已获奖/concluded已结题',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申报时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_innovation_student` (`student_id`),
  KEY `idx_innovation_org` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='科创竞赛与项目课题表（大创/竞赛/专利/论文，综测加分与毕业佐证）';

DROP TABLE IF EXISTS `uni_club`;
CREATE TABLE `uni_club` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '社团ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `club_name`    VARCHAR(100) NOT NULL                   COMMENT '社团名称',
  `club_type`    VARCHAR(50) NOT NULL DEFAULT ''         COMMENT '社团类型（文体/学术/公益等）',
  `leader_student_id` BIGINT UNSIGNED NULL               COMMENT '社团负责人（关联 base_student.id）',
  `advisor_id`   BIGINT UNSIGNED NULL                    COMMENT '指导老师（关联 base_teacher.id）',
  `register_at`  DATE NULL                               COMMENT '备案时间',
  `status`       TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '状态：0注销/1正常',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_club` (`org_id`,`club_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='社团备案表';

DROP TABLE IF EXISTS `uni_club_member`;
CREATE TABLE `uni_club_member` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '成员ID',
  `club_id`    BIGINT UNSIGNED NOT NULL                 COMMENT '社团ID（关联 uni_club.id）',
  `student_id` BIGINT UNSIGNED NOT NULL                 COMMENT '学生ID（关联 base_student.id）',
  `role`       VARCHAR(20) NOT NULL DEFAULT 'member'    COMMENT '角色：leader负责人/secretary干事/member成员',
  `join_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  `status`     TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0已退出/1在社',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_club_member` (`club_id`,`student_id`),
  KEY `idx_member_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='社团成员表';

DROP TABLE IF EXISTS `uni_activity`;
CREATE TABLE `uni_activity` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '活动ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `club_id`      BIGINT UNSIGNED NULL                    COMMENT '主办社团（关联 uni_club.id；NULL=院系/学校活动）',
  `activity_type` VARCHAR(20) NOT NULL                   COMMENT '类型：club社团活动/volunteer志愿服务/practice社会实践/culture文体',
  `title`        VARCHAR(200) NOT NULL                   COMMENT '活动标题',
  `content`      TEXT NULL                               COMMENT '活动内容',
  `activity_date` DATE NOT NULL                          COMMENT '活动日期',
  `evidence_file` VARCHAR(500) NOT NULL DEFAULT ''       COMMENT '活动记录/佐证（关联 base_file）',
  `recorder_id`  BIGINT UNSIGNED NULL                    COMMENT '记录人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  KEY `idx_uni_act_club` (`club_id`),
  KEY `idx_uni_act_org` (`org_id`,`activity_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='高校活动记录表（社团活动/志愿/实践，综测德育维度加分依据）';

-- ---------------------------------------------------------------------
-- 5. 毕业论文与答辩（选题-开题-修改-查重-答辩-判定全流程）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `uni_thesis`;
CREATE TABLE `uni_thesis` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '论文ID',
  `org_id`        BIGINT UNSIGNED NOT NULL               COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL               COMMENT '学生ID（关联 base_student.id）',
  `tutor_id`      BIGINT UNSIGNED NULL                   COMMENT '指导教师（关联 base_teacher.id）',
  `topic`         VARCHAR(200) NOT NULL                  COMMENT '论文选题（教师发布/学生自主/双向匹配）',
  `stage`         VARCHAR(20) NOT NULL DEFAULT 'topic'   COMMENT '进度：topic选题/proposal开题/drafting初稿/revision修改/final定稿',
  `thesis_file`   VARCHAR(500) NOT NULL DEFAULT ''       COMMENT '论文文件（关联 base_file，各版本）',
  `duplicate_rate` DECIMAL(5,2) NULL                     COMMENT '查重率（%）',
  `duplicate_file` VARCHAR(500) NOT NULL DEFAULT ''      COMMENT '查重报告（关联 base_file）',
  `duplicate_pass` TINYINT UNSIGNED NOT NULL DEFAULT 0   COMMENT '查重是否合格：0否/1是（阈值校验）',
  `guide_note`    VARCHAR(1000) NOT NULL DEFAULT ''      COMMENT '指导记录/修改轨迹',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_thesis_student` (`student_id`),
  KEY `idx_thesis_org` (`org_id`,`stage`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='毕业论文表（选题指导/查重/进度全流程溯源）';

DROP TABLE IF EXISTS `uni_thesis_defense`;
CREATE TABLE `uni_thesis_defense` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '答辩ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `thesis_id`    BIGINT UNSIGNED NOT NULL                COMMENT '论文（关联 uni_thesis.id）',
  `defense_type` VARCHAR(10) NOT NULL                    COMMENT '类型：proposal开题答辩/midterm中期审核/final最终答辩',
  `defense_date` DATETIME NULL                           COMMENT '答辩时间',
  `committee`    VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '答辩评委名单',
  `score`        DECIMAL(6,2) NULL                       COMMENT '答辩成绩',
  `result`       VARCHAR(10) NOT NULL DEFAULT 'pending'  COMMENT '结果：pending待答辩/passed合格/revision需整改/failed不合格',
  `opinion`      VARCHAR(1000) NOT NULL DEFAULT ''       COMMENT '整改意见/答辩意见',
  `operator_id`  BIGINT UNSIGNED NULL                    COMMENT '登记人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登记时间',
  PRIMARY KEY (`id`),
  KEY `idx_defense_thesis` (`thesis_id`,`defense_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='论文答辩审核表（开题/中期/最终答辩闭环）';

-- ---------------------------------------------------------------------
-- 6. 毕业学位资格预审（学分/绩点/论文/违纪/费用五维自动校验）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `uni_degree_precheck`;
CREATE TABLE `uni_degree_precheck` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '预审ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `check_year`   SMALLINT UNSIGNED NOT NULL              COMMENT '预审年份（毕业年度）',
  `credit_check` VARCHAR(10) NOT NULL DEFAULT 'unchecked' COMMENT '学分完成情况：unchecked/passed/failed',
  `gpa_check`    VARCHAR(10) NOT NULL DEFAULT 'unchecked' COMMENT '绩点达标：unchecked/passed/failed',
  `thesis_check` VARCHAR(10) NOT NULL DEFAULT 'unchecked' COMMENT '论文答辩：unchecked/passed/failed',
  `discipline_check` VARCHAR(10) NOT NULL DEFAULT 'unchecked' COMMENT '违纪清零：unchecked/passed/failed',
  `fee_check`    VARCHAR(10) NOT NULL DEFAULT 'unchecked' COMMENT '费用结清：unchecked/passed/failed',
  `overall_result` VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '综合判定：pending预审中/graduate毕业合格/degree_qualified学位授予/extension延期毕业',
  `operator_id`  BIGINT UNSIGNED NULL                   COMMENT '预审人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预审时间',
  PRIMARY KEY (`id`),
  KEY `idx_precheck_org` (`org_id`,`check_year`),
  KEY `idx_precheck_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='毕业与学位资格预审表（毕业合格清单/延期毕业清单/学位授予台账）';

-- ---------------------------------------------------------------------
-- 7. 毕业生就业签约与档案（三方协议/就业率/升学比例统计）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `uni_employment`;
CREATE TABLE `uni_employment` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '就业记录ID',
  `org_id`        BIGINT UNSIGNED NOT NULL               COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL               COMMENT '学生ID（关联 base_student.id）',
  `graduate_year` SMALLINT UNSIGNED NOT NULL             COMMENT '毕业年份',
  `outcome_type`  VARCHAR(20) NOT NULL                   COMMENT '去向：signed签约就业/further_study升学深造/flexible灵活就业/unemployed未就业/other其他',
  `company_name`  VARCHAR(200) NOT NULL DEFAULT ''       COMMENT '就业单位',
  `post_name`     VARCHAR(100) NOT NULL DEFAULT ''       COMMENT '岗位',
  `agreement_file` VARCHAR(500) NOT NULL DEFAULT ''      COMMENT '三方协议（关联 base_file）',
  `major_match`   VARCHAR(10) NOT NULL DEFAULT 'unknown' COMMENT '专业就业匹配度：matched/related/not_matched/unknown',
  `archive_transfer` VARCHAR(10) NOT NULL DEFAULT 'none' COMMENT '档案调转登记：none未办理/processing办理中/done已调转',
  `further_school` VARCHAR(200) NOT NULL DEFAULT ''      COMMENT '升学学校（深造报备）',
  `operator_id`   BIGINT UNSIGNED NULL                   COMMENT '登记人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登记时间',
  PRIMARY KEY (`id`),
  KEY `idx_uni_emp_org` (`org_id`,`graduate_year`),
  KEY `idx_uni_emp_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='高校就业签约表（就业率/升学比例/专业匹配度年度报表）';


-- ---------------------------------------------------------------------
-- 8. 宿舍后勤（楼栋-楼层-宿舍-床位四级架构/住宿分配/查寝/报修/卫生评比）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `uni_dorm_building`;
CREATE TABLE `uni_dorm_building` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '楼栋ID',
  `org_id`        BIGINT UNSIGNED NOT NULL               COMMENT '机构ID（关联 sys_org.id）',
  `campus_id`     BIGINT UNSIGNED NULL                   COMMENT '校区（关联 sys_campus.id）',
  `building_code` VARCHAR(32) NOT NULL                   COMMENT '楼栋编码（机构内唯一）',
  `building_name` VARCHAR(100) NOT NULL                  COMMENT '楼栋名称',
  `dorm_type`     VARCHAR(20) NOT NULL DEFAULT 'undergrad' COMMENT '宿舍类型：undergrad本科生宿舍/postgrad研究生宿舍',
  `floors`        TINYINT UNSIGNED NOT NULL DEFAULT 0    COMMENT '楼层数',
  `manager_id`    BIGINT UNSIGNED NULL                   COMMENT '宿管人员（关联 base_teacher.id）',
  `status`        TINYINT UNSIGNED NOT NULL DEFAULT 1    COMMENT '状态：0停用/1启用',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dorm_building` (`org_id`,`building_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='宿舍楼栋表（校区-楼栋-楼层-宿舍四级架构）';

DROP TABLE IF EXISTS `uni_dorm_room`;
CREATE TABLE `uni_dorm_room` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '宿舍ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `building_id` BIGINT UNSIGNED NOT NULL                 COMMENT '楼栋（关联 uni_dorm_building.id）',
  `floor_no`    TINYINT UNSIGNED NOT NULL                COMMENT '楼层',
  `room_no`     VARCHAR(20) NOT NULL                     COMMENT '宿舍号',
  `bed_count`   TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '床位数',
  `occupied_count` TINYINT UNSIGNED NOT NULL DEFAULT 0   COMMENT '已住人数',
  `status`      TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0停用/1可用/2维修',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dorm_room` (`building_id`,`room_no`),
  KEY `idx_room_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='宿舍房间表（宿舍容量/床位编号管理）';

DROP TABLE IF EXISTS `uni_dorm_bed`;
CREATE TABLE `uni_dorm_bed` (
  `id`       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '床位ID',
  `org_id`   BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `room_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '宿舍（关联 uni_dorm_room.id）',
  `bed_no`   VARCHAR(20) NOT NULL                     COMMENT '床位编号',
  `status`   TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0停用/1空置/2已占用',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dorm_bed` (`room_id`,`bed_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='宿舍床位表';

DROP TABLE IF EXISTS `uni_dorm_student`;
CREATE TABLE `uni_dorm_student` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '住宿记录ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `room_id`      BIGINT UNSIGNED NOT NULL                COMMENT '宿舍（关联 uni_dorm_room.id）',
  `bed_id`       BIGINT UNSIGNED NULL                    COMMENT '床位（关联 uni_dorm_bed.id）',
  `school_year_id` BIGINT UNSIGNED NOT NULL              COMMENT '学年（关联 base_school_year.id）',
  `assign_type`  VARCHAR(10) NOT NULL DEFAULT 'auto'     COMMENT '分配方式：auto智能分配/manual人工/transfer调宿',
  `check_in_date` DATE NULL                              COMMENT '入住日期',
  `check_out_date` DATE NULL                             COMMENT '退宿日期',
  `holiday_stay` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '假期留校登记',
  `status`       TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '状态：0已退宿/1住宿中',
  `operator_id`  BIGINT UNSIGNED NULL                    COMMENT '操作人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_dorm_student` (`student_id`,`status`),
  KEY `idx_dorm_room` (`room_id`),
  KEY `idx_dorm_year` (`org_id`,`school_year_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生住宿分配表（入住/调宿/退宿/假期留校全台账）';

DROP TABLE IF EXISTS `uni_dorm_check`;
CREATE TABLE `uni_dorm_check` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '查寝ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `student_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '学生ID（关联 base_student.id）',
  `room_id`     BIGINT UNSIGNED NULL                     COMMENT '宿舍（关联 uni_dorm_room.id）',
  `check_date`  DATE NOT NULL                            COMMENT '查寝日期',
  `check_type`  VARCHAR(10) NOT NULL DEFAULT 'daily'     COMMENT '类型：daily每日查寝/night晚归/weekend周末留校',
  `status`      VARCHAR(20) NOT NULL DEFAULT 'present'   COMMENT '状态：present在寝/late晚归/absent不归/stay_over留宿异常/leave已请假/off_campus校外住宿登记',
  `note`        VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '备注',
  `is_alert`    TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '是否异常预警：0否/1是（异常住宿实时预警推送）',
  `checker_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '查寝人（辅导员/宿管，关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  KEY `idx_dorm_check_student` (`student_id`,`check_date`),
  KEY `idx_dorm_check_org` (`org_id`,`check_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='宿舍查寝考勤表（晚归/不归/留宿异常预警）';

DROP TABLE IF EXISTS `uni_repair`;
CREATE TABLE `uni_repair` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '报修ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `room_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '宿舍（关联 uni_dorm_room.id）',
  `applicant_id` BIGINT UNSIGNED NOT NULL                COMMENT '报修人（学生/宿管，关联 auth_user.id）',
  `repair_type` VARCHAR(20) NOT NULL                     COMMENT '类型：water水电/door门窗/furniture家具/aircon空调/network网络/other其他',
  `content`     VARCHAR(500) NOT NULL                    COMMENT '报修内容',
  `photo`       VARCHAR(500) NOT NULL DEFAULT ''         COMMENT '现场照片（关联 base_file）',
  `handler_id`  BIGINT UNSIGNED NULL                     COMMENT '维修人员（关联 auth_user.id，接单处理）',
  `status`      VARCHAR(10) NOT NULL DEFAULT 'pending'   COMMENT '状态：pending待受理/dispatched已派单/repairing维修中/finished已完工/verified已验收',
  `finish_note` VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '完工说明',
  `verify_by`   BIGINT UNSIGNED NULL                     COMMENT '验收人（关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报修时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_repair_org` (`org_id`,`status`),
  KEY `idx_repair_room` (`room_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='宿舍报修表（报修-派单-维修-验收闭环服务台账）';

DROP TABLE IF EXISTS `uni_dorm_hygiene`;
CREATE TABLE `uni_dorm_hygiene` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '卫生检查ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `room_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '宿舍（关联 uni_dorm_room.id）',
  `check_date`  DATE NOT NULL                            COMMENT '检查日期',
  `hygiene_score` DECIMAL(5,2) NOT NULL DEFAULT 0        COMMENT '卫生评分',
  `violation`   VARCHAR(500) NOT NULL DEFAULT ''         COMMENT '违规记录（违规电器等）',
  `rectify_note` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '整改要求',
  `checker_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '检查人（宿管/辅导员，关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  KEY `idx_hygiene_org` (`org_id`,`check_date`),
  KEY `idx_hygiene_room` (`room_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='宿舍卫生检查表（文明宿舍/优秀寝室评比支撑）';

-- ---------------------------------------------------------------------
-- 9. 高校健康与体质（年度体检/体测/心理测评/特殊体质专项管护）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `uni_health_record`;
CREATE TABLE `uni_health_record` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '健康记录ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`   BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `school_year_id` BIGINT UNSIGNED NOT NULL              COMMENT '学年（关联 base_school_year.id）',
  `record_type`  VARCHAR(20) NOT NULL                    COMMENT '类型：physical_exam年度体检/fitness_test体测成绩/psycho_test心理测评/special_care特殊体质专项管护/morning_check晨检',
  `height_cm`    DECIMAL(5,1) NULL                       COMMENT '身高（厘米）',
  `weight_kg`    DECIMAL(5,1) NULL                       COMMENT '体重（千克）',
  `score`        DECIMAL(6,2) NULL                       COMMENT '体测成绩',
  `result_detail` TEXT NULL                              COMMENT '体检/测评详情（密文存储）',
  `is_abnormal`  TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '是否异常：0否/1是（慢性病/特殊体质专项管护）',
  `recorder_id`  BIGINT UNSIGNED NOT NULL                COMMENT '记录人（校医/体育教师，关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  KEY `idx_uni_health_student` (`student_id`,`school_year_id`),
  KEY `idx_uni_health_org` (`org_id`,`record_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='高校健康体质记录表（年度体检/体育达标/心理测评归档）';
