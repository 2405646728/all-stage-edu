-- =====================================================================
-- 03_auth_account.sql —— 全平台账号体系（账号便捷开通机制 · 权限分层管控）
-- 对应文档：12.3 金字塔六级角色权限体系 / 12.4 权限颗粒度 /
--           12.5 账号便捷开通机制（Excel批量导入/班级批量生成/台账同步建号/
--           单条开通/邮箱推送一键开通 + 异常容错）
-- 安全约定：password_hash 为 BCrypt 摘要（JDK21 后端生成），严禁明文。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 1. 全平台用户表（六角色统一账号体系）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `auth_user`;
CREATE TABLE `auth_user` (
  `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID（全平台唯一）',
  `username`       VARCHAR(64)  NOT NULL                 COMMENT '登录账号（学号/工号/手机号/邮箱，平台唯一）',
  `password_hash`  VARCHAR(100) NULL                     COMMENT '密码BCrypt摘要（占位 __INIT_REQUIRED__ 表示须初始化强密码）',
  `real_name`      VARCHAR(50)  NOT NULL DEFAULT ''      COMMENT '真实姓名',
  `user_type`      VARCHAR(20)  NOT NULL                 COMMENT '账号身份：super_admin超管/school_admin校管/teacher教师/staff职工/student学生/parent家长/visitor访客',
  `org_id`         BIGINT UNSIGNED NULL                  COMMENT '机构ID（关联 sys_org.id；平台超管为NULL）',
  `campus_id`      BIGINT UNSIGNED NULL                  COMMENT '校区ID（关联 sys_campus.id）',
  `stage`          VARCHAR(20)  NULL                     COMMENT '所属学段（冗余自机构，便于查询）',
  `gender`         TINYINT UNSIGNED NOT NULL DEFAULT 0   COMMENT '性别：0未知/1男/2女',
  `id_card`        VARCHAR(64)  NOT NULL DEFAULT ''      COMMENT '身份证号（应用层加密存储）',
  `phone`          VARCHAR(20)  NOT NULL DEFAULT ''      COMMENT '手机号',
  `email`          VARCHAR(100) NOT NULL DEFAULT ''      COMMENT '邮箱（邮箱推送开通用）',
  `avatar`         VARCHAR(500) NOT NULL DEFAULT ''      COMMENT '头像地址（关联 base_file）',
  `status`         TINYINT UNSIGNED NOT NULL DEFAULT 1   COMMENT '账号状态：0冻结/1正常/2未激活(待邮箱确认)/3锁定(异常登录)',
  `must_change_pwd` TINYINT UNSIGNED NOT NULL DEFAULT 1  COMMENT '是否强制首登改密：0否/1是（批量开通默认1）',
  `pwd_updated_at` DATETIME NULL                         COMMENT '最近改密时间',
  `last_login_at`  DATETIME NULL                         COMMENT '最近登录时间',
  `login_fail_count` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '连续登录失败次数（恶意访问拦截）',
  `locked_until`   DATETIME NULL                         COMMENT '锁定截止时间',
  `open_channel`   VARCHAR(20) NOT NULL DEFAULT 'manual' COMMENT '开通渠道：manual单条/excel批量/class_batch班级生成/sync台账同步/email邮箱推送',
  `open_batch_id`  BIGINT UNSIGNED NULL                  COMMENT '开通批次ID（关联 auth_open_batch.id）',
  `remark`         VARCHAR(255) NOT NULL DEFAULT ''      COMMENT '备注',
  `created_by`     BIGINT UNSIGNED NULL                  COMMENT '开通人（关联 auth_user.id）',
  `created_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by`     BIGINT UNSIGNED NULL                  COMMENT '最后更新人',
  `updated_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted`     TINYINT UNSIGNED NOT NULL DEFAULT 0   COMMENT '逻辑删除：0正常/1已删',
  `deleted_at`     DATETIME NULL                         COMMENT '删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  KEY `idx_user_org` (`org_id`),
  KEY `idx_user_type` (`user_type`),
  KEY `idx_user_phone` (`phone`),
  KEY `idx_user_stage` (`stage`),
  CONSTRAINT `chk_user_type` CHECK (`user_type` IN ('super_admin','school_admin','teacher','staff','student','parent','visitor')),
  CONSTRAINT `chk_user_status` CHECK (`status` IN (0,1,2,3))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='全平台用户账号表（六角色统一账号体系，学号/工号唯一标识）';

-- ---------------------------------------------------------------------
-- 2. 用户角色绑定（一人多角色；权限自动匹配）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `auth_user_role`;
CREATE TABLE `auth_user_role` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '用户ID（关联 auth_user.id）',
  `role_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '角色ID（关联 sys_role.id）',
  `org_id`      BIGINT UNSIGNED NULL                    COMMENT '角色作用机构（NULL=全局角色；数据隔离范围）',
  `scope_id`    BIGINT UNSIGNED NULL                    COMMENT '管辖范围ID（班级ID/院系ID等，配合data_scope）',
  `granted_by`  BIGINT UNSIGNED NULL                    COMMENT '授权人（关联 auth_user.id，特殊权限终审留痕）',
  `granted_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '授权时间',
  `status`      TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '状态：0失效/1有效',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role_scope` (`user_id`,`role_id`,`org_id`,`scope_id`),
  KEY `idx_user_role` (`user_id`),
  KEY `idx_role_user` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户角色绑定表（一人多岗，权限自动匹配）';

-- ---------------------------------------------------------------------
-- 3. 批量开通批次与明细（Excel导入/班级生成/台账同步/邮箱推送统一落账）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `auth_open_batch`;
CREATE TABLE `auth_open_batch` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '批次ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（权限边界：仅本机构）',
  `batch_no`      VARCHAR(40) NOT NULL                    COMMENT '批次号（唯一）',
  `open_mode`     VARCHAR(20) NOT NULL                    COMMENT '开通模式：excel批量/class_batch班级生成/sync台账同步/manual单条/email邮箱推送',
  `total_count`   INT NOT NULL DEFAULT 0                  COMMENT '总数',
  `success_count` INT NOT NULL DEFAULT 0                  COMMENT '成功数（部分成功部分报错容错）',
  `fail_count`    INT NOT NULL DEFAULT 0                  COMMENT '失败数',
  `status`        VARCHAR(20) NOT NULL DEFAULT 'running'  COMMENT '状态：running进行中/success完成/partial部分成功/failed失败/revoked已撤回',
  `error_file`    VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '异常数据报错清单地址',
  `revoked_by`    BIGINT UNSIGNED NULL                    COMMENT '撤回人（批量操作可撤回）',
  `revoked_at`    DATETIME NULL                           COMMENT '撤回时间',
  `operator_id`   BIGINT UNSIGNED NOT NULL                COMMENT '操作人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_open_batch_no` (`batch_no`),
  KEY `idx_open_batch_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='账号批量开通批次表（全操作留痕）';

DROP TABLE IF EXISTS `auth_open_item`;
CREATE TABLE `auth_open_item` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `batch_id`    BIGINT UNSIGNED NOT NULL                 COMMENT '批次ID（关联 auth_open_batch.id）',
  `row_no`      INT NOT NULL                             COMMENT '源数据行号（Excel行号定位）',
  `username`    VARCHAR(64)  NOT NULL                    COMMENT '账号（学号/工号）',
  `real_name`   VARCHAR(50)  NOT NULL DEFAULT ''         COMMENT '姓名',
  `user_type`   VARCHAR(20)  NOT NULL                    COMMENT '身份：teacher/staff/student/parent',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID',
  `scope_desc`  VARCHAR(200) NOT NULL DEFAULT ''         COMMENT '归属班级/部门（权限自动匹配依据）',
  `phone`       VARCHAR(20)  NOT NULL DEFAULT ''         COMMENT '手机号',
  `email`       VARCHAR(100) NOT NULL DEFAULT ''         COMMENT '邮箱（邮箱推送模式必填）',
  `raw_data`    JSON NULL                                COMMENT '原始导入数据（溯源）',
  `result`      VARCHAR(10) NOT NULL DEFAULT 'pending'   COMMENT '结果：pending待处理/success成功/fail失败',
  `fail_reason` VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '失败原因（重复/格式错误等，异常清单标注）',
  `user_id`     BIGINT UNSIGNED NULL                     COMMENT '生成账号ID（关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_open_item_batch` (`batch_id`),
  KEY `idx_open_item_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='账号批量开通明细表（部分成功容错、报错清单）';

-- ---------------------------------------------------------------------
-- 4. 邮箱推送一键开通（发邮即带全量信息、用户一键确认、开通回执留存）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `auth_email_invite`;
CREATE TABLE `auth_email_invite` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '邀请ID',
  `batch_id`     BIGINT UNSIGNED NULL                    COMMENT '批次ID（关联 auth_open_batch.id）',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID',
  `email`        VARCHAR(100) NOT NULL                   COMMENT '收件邮箱',
  `real_name`    VARCHAR(50)  NOT NULL DEFAULT ''        COMMENT '姓名',
  `user_type`    VARCHAR(20)  NOT NULL                   COMMENT '身份',
  `scope_desc`   VARCHAR(200) NOT NULL DEFAULT ''        COMMENT '归属班级/部门',
  `invite_token` VARCHAR(128) NOT NULL                   COMMENT '确认令牌（唯一，防钓鱼校验）',
  `mail_content` TEXT NULL                               COMMENT '邮件正文快照（官方模板：账号信息/登录地址/防伪标识）',
  `status`       VARCHAR(20) NOT NULL DEFAULT 'sent'     COMMENT '状态：sent已推送/confirmed已确认开通/expired过期/bounced邮件拒收/resend已补发/manual_done人工兜底开通',
  `push_at`      DATETIME NULL                           COMMENT '推送时间',
  `confirm_at`   DATETIME NULL                           COMMENT '用户确认时间（开通回执）',
  `user_id`      BIGINT UNSIGNED NULL                    COMMENT '开通账号ID（关联 auth_user.id）',
  `created_by`   BIGINT UNSIGNED NULL                    COMMENT '操作人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_email_invite` (`invite_token`),
  KEY `idx_email_batch` (`batch_id`),
  KEY `idx_email_status` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='邮箱推送一键开通表（异常兜底：补发/人工开通标记）';
