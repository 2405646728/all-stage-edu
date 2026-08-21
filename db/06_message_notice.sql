-- =====================================================================
-- 06_message_notice.sql —— 家校互通与消息推送（纯展示/推送服务，零业务写入干预）
-- 对应文档：5.2.3 校园生活与家校互通（全园与班级分层通知、一对一消息）、
--           各学段「家校轻量化互通共育」模块、1.3.2 消息推送全局配置
-- 约定：本模块异常可独立熔断，不影响考勤/门禁/学籍等核心安全业务。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 1. 通知公告（全园(校)/班级分层发布，图文/文件/链接多形式，已读回执）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `msg_notice`;
CREATE TABLE `msg_notice` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `notice_type` VARCHAR(20) NOT NULL DEFAULT 'notice'    COMMENT '通知类型：notice普通通知/meal餐食公示/activity活动/security安全教育/weather天气提醒/tips温馨提示',
  `scope_type`  VARCHAR(10) NOT NULL DEFAULT 'org'       COMMENT '范围类型：org全园(校)/class班级分层/person定向人员',
  `title`       VARCHAR(200) NOT NULL                    COMMENT '标题',
  `content`     TEXT NOT NULL                            COMMENT '正文内容',
  `content_type` VARCHAR(10) NOT NULL DEFAULT 'text'     COMMENT '内容形式：text图文/file文件/link链接',
  `attachment`  VARCHAR(500) NOT NULL DEFAULT ''         COMMENT '附件地址（关联 base_file，逗号分隔）',
  `need_read_back` TINYINT UNSIGNED NOT NULL DEFAULT 1   COMMENT '是否需已读回执：0否/1是',
  `publish_status` VARCHAR(10) NOT NULL DEFAULT 'draft'  COMMENT '发布状态：draft草稿/published已发布/recalled已撤回',
  `publisher_id` BIGINT UNSIGNED NOT NULL                COMMENT '发布人（关联 auth_user.id；超管/校管/班主任分层发布）',
  `published_at` DATETIME NULL                           COMMENT '发布时间',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted`  TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '逻辑删除：0正常/1已删',
  PRIMARY KEY (`id`),
  KEY `idx_notice_org` (`org_id`,`publish_status`,`published_at`),
  KEY `idx_notice_type` (`org_id`,`notice_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='通知公告表（全园/班级分层推送，多形式）';

DROP TABLE IF EXISTS `msg_notice_scope`;
CREATE TABLE `msg_notice_scope` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `notice_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '通知ID（关联 msg_notice.id）',
  `class_id`   BIGINT UNSIGNED NULL                     COMMENT '班级范围（关联 base_class.id；org级为NULL）',
  `user_id`    BIGINT UNSIGNED NULL                     COMMENT '定向人员（关联 auth_user.id；person级用）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_notice_scope` (`notice_id`,`class_id`,`user_id`),
  KEY `idx_scope_class` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='通知推送范围表（精准统计家长查看状态）';

DROP TABLE IF EXISTS `msg_notice_read`;
CREATE TABLE `msg_notice_read` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `notice_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '通知ID（关联 msg_notice.id）',
  `user_id`    BIGINT UNSIGNED NOT NULL                 COMMENT '阅读人（关联 auth_user.id）',
  `read_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '阅读时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_notice_read` (`notice_id`,`user_id`),
  KEY `idx_read_notice` (`notice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='通知已读回执表（确保通知全覆盖、无遗漏）';

-- ---------------------------------------------------------------------
-- 2. 一对一消息（家长-班主任/保育员私信，家校沟通台账可溯源）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `msg_message`;
CREATE TABLE `msg_message` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `sender_id`   BIGINT UNSIGNED NOT NULL                 COMMENT '发送人（关联 auth_user.id）',
  `receiver_id` BIGINT UNSIGNED NOT NULL                 COMMENT '接收人（关联 auth_user.id）',
  `student_id`  BIGINT UNSIGNED NULL                     COMMENT '关联学生（家校沟通归属，关联 base_student.id）',
  `msg_type`    VARCHAR(10) NOT NULL DEFAULT 'text'      COMMENT '消息类型：text文字/image图片/file文件',
  `content`     TEXT NOT NULL                            COMMENT '消息内容',
  `file_url`    VARCHAR(500) NOT NULL DEFAULT ''         COMMENT '附件地址（关联 base_file）',
  `is_read`     TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '是否已读：0未读/1已读',
  `read_at`     DATETIME NULL                            COMMENT '阅读时间',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  PRIMARY KEY (`id`),
  KEY `idx_msg_org_time` (`org_id`,`created_at`),
  KEY `idx_msg_sender` (`sender_id`),
  KEY `idx_msg_receiver` (`receiver_id`,`is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='一对一消息表（独立即时通讯，实时留痕可溯源）';

-- ---------------------------------------------------------------------
-- 3. 推送模板与推送日志（系统通知/短信/公众号，全局统一配置）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `msg_push_template`;
CREATE TABLE `msg_push_template` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `template_code` VARCHAR(50) NOT NULL                   COMMENT '模板编码（唯一，如 leave_approve考勤通知/payment_remind欠费提醒/gate_alert安防预警）',
  `template_name` VARCHAR(100) NOT NULL                  COMMENT '模板名称',
  `channel`      VARCHAR(20) NOT NULL                    COMMENT '推送渠道：system系统消息/sms短信/wechat公众号/email邮件',
  `title_tpl`    VARCHAR(200) NOT NULL DEFAULT ''        COMMENT '标题模板（占位符）',
  `content_tpl`  TEXT NOT NULL                           COMMENT '内容模板（占位符）',
  `status`       TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '状态：0停用/1启用（全局推送开关与模板管控）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_push_template` (`template_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='消息推送模板表（全局推送规则统一配置，各学段复用）';

DROP TABLE IF EXISTS `msg_push_log`;
CREATE TABLE `msg_push_log` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '推送日志ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id；平台推送为0）',
  `template_code` VARCHAR(50) NOT NULL DEFAULT ''        COMMENT '模板编码（关联 msg_push_template.template_code）',
  `channel`     VARCHAR(20) NOT NULL                     COMMENT '渠道：system/sms/wechat/email',
  `biz_type`    VARCHAR(30) NOT NULL DEFAULT ''          COMMENT '业务来源：notice通知/message消息/attendance考勤/gate_alert安防/leave请假/fee缴费/health健康',
  `biz_id`      BIGINT UNSIGNED NOT NULL DEFAULT 0       COMMENT '业务数据ID',
  `receiver_id` BIGINT UNSIGNED NULL                     COMMENT '接收人（关联 auth_user.id）',
  `receiver_desc` VARCHAR(100) NOT NULL DEFAULT ''       COMMENT '接收方描述（手机号/公众号openid，脱敏）',
  `title`       VARCHAR(200) NOT NULL DEFAULT ''         COMMENT '推送标题',
  `content`     TEXT NULL                                COMMENT '推送内容快照',
  `status`      VARCHAR(10) NOT NULL DEFAULT 'sent'      COMMENT '推送状态：sent已发送/success成功/failed失败',
  `fail_reason` VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '失败原因',
  `sent_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '推送时间',
  PRIMARY KEY (`id`),
  KEY `idx_push_org` (`org_id`,`sent_at`),
  KEY `idx_push_receiver` (`receiver_id`),
  KEY `idx_push_biz` (`biz_type`,`biz_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='推送日志表（底层推送网关，全渠道留痕）';
