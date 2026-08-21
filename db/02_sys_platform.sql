-- =====================================================================
-- 02_sys_platform.sql —— 平台超级管理员层（全局顶层管控 · 永久冻结）
-- 对应文档：第一板块 1.1~1.7（机构入驻/学段管控/全局参数/权限终审/
--           运维日志/API网关与门禁硬件管控/版本迭代/热补丁/告警）
-- 说明：本层为平台全局表（sys_ 前缀），独立于各学段业务数据。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 1. 入驻机构（学段判定唯一依据：stage 字段，单机构单学段，CHECK 锁定）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_org`;
CREATE TABLE `sys_org` (
  `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '机构ID（数据隔离主键）',
  `org_code`       VARCHAR(32)  NOT NULL                COMMENT '机构编码（平台唯一）',
  `org_name`       VARCHAR(100) NOT NULL                COMMENT '机构名称',
  `stage`          VARCHAR(20)  NOT NULL                COMMENT '学段（唯一判定依据）：kindergarten幼儿园/primary小学/junior初中/senior普高/vocational职高/university大学',
  `school_type`    VARCHAR(20)  NOT NULL DEFAULT 'public' COMMENT '办学主体：public公办/private民办/group集团办学',
  `province`       VARCHAR(32)  NOT NULL DEFAULT ''     COMMENT '省',
  `city`           VARCHAR(32)  NOT NULL DEFAULT ''     COMMENT '市',
  `district`       VARCHAR(32)  NOT NULL DEFAULT ''     COMMENT '区县',
  `address`        VARCHAR(200) NOT NULL DEFAULT ''     COMMENT '详细地址',
  `legal_person`   VARCHAR(50)  NOT NULL DEFAULT ''     COMMENT '法定代表人',
  `contact_name`   VARCHAR(50)  NOT NULL DEFAULT ''     COMMENT '机构联系人',
  `contact_phone`  VARCHAR(20)  NOT NULL DEFAULT ''     COMMENT '机构联系电话',
  `status`         TINYINT UNSIGNED NOT NULL DEFAULT 0  COMMENT '机构状态：0待审核/1正常/2禁用/3注销',
  `service_start`  DATE         NULL                    COMMENT '服务时效开始日期',
  `service_end`    DATE         NULL                    COMMENT '服务时效截止日期',
  `audit_remark`   VARCHAR(255) NOT NULL DEFAULT ''     COMMENT '入驻审核备注',
  `audit_by`       BIGINT UNSIGNED NULL                 COMMENT '审核人（关联 auth_user.id）',
  `audit_at`       DATETIME     NULL                    COMMENT '审核时间',
  `created_by`     BIGINT UNSIGNED NULL                 COMMENT '创建人（关联 auth_user.id）',
  `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by`     BIGINT UNSIGNED NULL                 COMMENT '最后更新人',
  `updated_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted`     TINYINT UNSIGNED NOT NULL DEFAULT 0  COMMENT '逻辑删除：0正常/1已删',
  `deleted_at`     DATETIME     NULL                    COMMENT '删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_org_code` (`org_code`),
  KEY `idx_org_stage` (`stage`),
  KEY `idx_org_status` (`status`),
  CONSTRAINT `chk_org_stage` CHECK (`stage` IN ('kindergarten','primary','junior','senior','vocational','university')),
  CONSTRAINT `chk_org_status` CHECK (`status` IN (0,1,2,3))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='平台入驻机构表（学段判定唯一依据，单机构固定单学段）';

-- ---------------------------------------------------------------------
-- 2. 校区（多校区入驻；业务表可通过 campus_id 进一步隔离）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_campus`;
CREATE TABLE `sys_campus` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '校区ID',
  `org_id`       BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `campus_code`  VARCHAR(32)  NOT NULL                   COMMENT '校区编码（机构内唯一）',
  `campus_name`  VARCHAR(100) NOT NULL                   COMMENT '校区名称',
  `address`      VARCHAR(200) NOT NULL DEFAULT ''        COMMENT '校区地址',
  `contact_name` VARCHAR(50)  NOT NULL DEFAULT ''        COMMENT '校区负责人',
  `contact_phone` VARCHAR(20) NOT NULL DEFAULT ''        COMMENT '校区联系电话',
  `is_main`      TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '是否主校区：0否/1是',
  `status`       TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '状态：0停用/1启用',
  `created_by`   BIGINT UNSIGNED NULL                    COMMENT '创建人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by`   BIGINT UNSIGNED NULL                    COMMENT '最后更新人',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted`   TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '逻辑删除：0正常/1已删',
  `deleted_at`   DATETIME NULL                           COMMENT '删除时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_campus` (`org_id`,`campus_code`),
  KEY `idx_campus_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='校区表（多校区入驻支撑）';

-- ---------------------------------------------------------------------
-- 3. 功能模块注册表（可插拔模块总清单；学段模块开关挂接本表）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_module`;
CREATE TABLE `sys_module` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '模块ID',
  `module_code`  VARCHAR(50)  NOT NULL                   COMMENT '模块编码（唯一，如 base/attendance/pickup/gate/fee/selection/thesis）',
  `module_name`  VARCHAR(100) NOT NULL                   COMMENT '模块名称',
  `stage_scope`  VARCHAR(100) NOT NULL DEFAULT 'ALL'     COMMENT '适用学段：ALL全部 或 逗号分隔如 kindergarten,primary',
  `is_plugin`    TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '是否插件化模块：0核心/1可插拔',
  `default_on`   TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '新机构默认开关：0关/1开',
  `sort_no`      INT NOT NULL DEFAULT 0                  COMMENT '排序号',
  `description`  VARCHAR(255) NOT NULL DEFAULT ''        COMMENT '模块说明',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_module_code` (`module_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='功能模块注册表（可插拔模块总清单）';

-- ---------------------------------------------------------------------
-- 4. 机构模块开关（学段模块全局开关：单机构、多模块灵活启停）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_org_module_switch`;
CREATE TABLE `sys_org_module_switch` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `org_id`      BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `module_code` VARCHAR(50)  NOT NULL                   COMMENT '模块编码（关联 sys_module.module_code）',
  `enabled`     TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '开关：0停用(熔断)/1启用',
  `updated_by`  BIGINT UNSIGNED NULL                    COMMENT '操作人（关联 auth_user.id）',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_org_module` (`org_id`,`module_code`),
  KEY `idx_module_org` (`module_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='机构学段模块开关表（模块启停/熔断，不影响核心业务）';

-- ---------------------------------------------------------------------
-- 5. 全局基础字典（通用字典全局复用：学籍状态/学科/岗位/奖惩类型等）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type` (
  `id`        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '字典类型ID',
  `type_code` VARCHAR(50)  NOT NULL                   COMMENT '字典类型编码（唯一，如 student_status/subject_type/reward_type）',
  `type_name` VARCHAR(100) NOT NULL                   COMMENT '字典类型名称',
  `is_frozen` TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '是否冻结：0可维护/1冻结（冻结后仅超管可改）',
  `remark`    VARCHAR(255) NOT NULL DEFAULT ''        COMMENT '说明',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dict_type` (`type_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='全局字典类型表';

DROP TABLE IF EXISTS `sys_dict_item`;
CREATE TABLE `sys_dict_item` (
  `id`        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '字典项ID',
  `type_code` VARCHAR(50)  NOT NULL                   COMMENT '字典类型编码（关联 sys_dict_type.type_code）',
  `item_code` VARCHAR(50)  NOT NULL                   COMMENT '字典项编码（类型内唯一）',
  `item_name` VARCHAR(100) NOT NULL                   COMMENT '字典项名称',
  `stage`     VARCHAR(20)  NULL                       COMMENT '适用学段：NULL=全学段通用；否则按学段差异化渲染',
  `sort_no`   INT NOT NULL DEFAULT 0                  COMMENT '排序号',
  `extra_json` JSON NULL                              COMMENT '扩展属性（学段差异化渲染配置）',
  `status`    TINYINT UNSIGNED NOT NULL DEFAULT 1     COMMENT '状态：0停用/1启用',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dict_item` (`type_code`,`item_code`,`stage`),
  KEY `idx_dict_type` (`type_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='全局字典项表（学段差异化渲染支撑）';

-- ---------------------------------------------------------------------
-- 6. 全局底层参数（登录时效/密码复杂度/加密规则/接口频率/推送配置等）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_global_param`;
CREATE TABLE `sys_global_param` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '参数ID',
  `param_group` VARCHAR(50)  NOT NULL                   COMMENT '参数分组：login_security安全/crypto加密/api_limit接口频率/push推送/log_retention日志留存',
  `param_key`   VARCHAR(100) NOT NULL                   COMMENT '参数键（组内唯一）',
  `param_value` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '参数值',
  `value_type`  VARCHAR(20)  NOT NULL DEFAULT 'string'  COMMENT '值类型：string/int/bool/json',
  `is_platform_only` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '是否仅平台级（不可被机构覆盖）：0否/1是',
  `description` VARCHAR(255) NOT NULL DEFAULT ''        COMMENT '参数说明',
  `updated_by`  BIGINT UNSIGNED NULL                    COMMENT '最后更新人（关联 auth_user.id）',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_global_param` (`param_group`,`param_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='全局底层参数配置表（系统核心冻结规则）';

-- ---------------------------------------------------------------------
-- 7. IP 黑白名单（恶意访问拦截）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_ip_rule`;
CREATE TABLE `sys_ip_rule` (
  `id`        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `rule_type` VARCHAR(10) NOT NULL                     COMMENT '规则类型：white白名单/black黑名单',
  `ip_cidr`   VARCHAR(45) NOT NULL                     COMMENT 'IP或CIDR网段',
  `remark`    VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '说明',
  `status`    TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0停用/1启用',
  `created_by` BIGINT UNSIGNED NULL                    COMMENT '创建人（关联 auth_user.id）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ip_rule` (`rule_type`,`ip_cidr`),
  CONSTRAINT `chk_ip_rule_type` CHECK (`rule_type` IN ('white','black'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='IP黑白名单表（安全拦截）';

-- ---------------------------------------------------------------------
-- 8. 角色权限（金字塔六级角色体系 + 菜单/按钮/数据三级颗粒度）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_code`  VARCHAR(50)  NOT NULL                   COMMENT '角色编码（唯一）：SUPER_ADMIN/SCHOOL_ADMIN/TEACHER_STAFF/STUDENT/PARENT/VISITOR/自定义',
  `role_name`  VARCHAR(50)  NOT NULL                   COMMENT '角色名称',
  `role_level` TINYINT UNSIGNED NOT NULL               COMMENT '金字塔层级：1超级开发者管理员/2学校校级管理员/3教职工班主任/4学生/5家长/6访客临时角色',
  `is_builtin` TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '是否内置角色：0自定义/1内置（内置不可删）',
  `scope`      VARCHAR(10) NOT NULL DEFAULT 'org'      COMMENT '作用域：platform平台级/org机构级',
  `description` VARCHAR(255) NOT NULL DEFAULT ''       COMMENT '角色说明',
  `created_by` BIGINT UNSIGNED NULL                    COMMENT '创建人（关联 auth_user.id）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_code` (`role_code`),
  CONSTRAINT `chk_role_level` CHECK (`role_level` BETWEEN 1 AND 6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色表（金字塔六级角色权限体系）';

DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '菜单/权限点ID',
  `parent_id`   BIGINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '父级ID（0=根）',
  `menu_code`   VARCHAR(100) NOT NULL                  COMMENT '权限编码（唯一）',
  `menu_name`   VARCHAR(100) NOT NULL                  COMMENT '名称',
  `menu_type`   VARCHAR(10) NOT NULL DEFAULT 'menu'    COMMENT '类型：dir目录/menu菜单/button按钮',
  `stage_scope` VARCHAR(100) NOT NULL DEFAULT 'ALL'    COMMENT '适用学段：ALL或逗号分隔',
  `route_path`  VARCHAR(200) NOT NULL DEFAULT ''       COMMENT '前端路由',
  `sort_no`     INT NOT NULL DEFAULT 0                 COMMENT '排序号',
  `status`      TINYINT UNSIGNED NOT NULL DEFAULT 1    COMMENT '状态：0停用/1启用',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_menu_code` (`menu_code`),
  KEY `idx_menu_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='菜单/权限点表（菜单权限+按钮操作权限）';

DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `role_id`    BIGINT UNSIGNED NOT NULL                COMMENT '角色ID（关联 sys_role.id）',
  `menu_id`    BIGINT UNSIGNED NOT NULL                COMMENT '权限点ID（关联 sys_menu.id）',
  `perm_type`  VARCHAR(10) NOT NULL DEFAULT 'menu'     COMMENT '权限颗粒度：menu菜单/button按钮/data数据',
  `data_scope` VARCHAR(20) NOT NULL DEFAULT 'self'     COMMENT '数据范围：all_platform全平台/all_org全校/class本班/self本人',
  `granted_by` BIGINT UNSIGNED NULL                    COMMENT '授权人（关联 auth_user.id，权限终审留痕）',
  `granted_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '授权时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_menu` (`role_id`,`menu_id`),
  KEY `idx_perm_menu` (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色权限表（菜单/按钮/数据三级颗粒度管控，权限终审留痕）';

-- ---------------------------------------------------------------------
-- 9. 统一 API 网关（接口启停/密钥/权限校验/流量管控）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_api_gateway`;
CREATE TABLE `sys_api_gateway` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '接口ID',
  `api_code`    VARCHAR(100) NOT NULL                  COMMENT '接口编码（唯一）',
  `api_name`    VARCHAR(100) NOT NULL                  COMMENT '接口名称',
  `api_path`    VARCHAR(200) NOT NULL                  COMMENT '接口路径',
  `api_method`  VARCHAR(10)  NOT NULL DEFAULT 'GET'    COMMENT '请求方法：GET/POST/PUT/DELETE',
  `status`      TINYINT UNSIGNED NOT NULL DEFAULT 1    COMMENT '状态：0停用/1启用',
  `rate_limit`  INT NOT NULL DEFAULT 0                 COMMENT '限流（次/分钟，0=不限）',
  `need_sign`   TINYINT UNSIGNED NOT NULL DEFAULT 1    COMMENT '是否需签名校验：0否/1是',
  `description` VARCHAR(255) NOT NULL DEFAULT ''       COMMENT '说明',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_api_code` (`api_code`),
  KEY `idx_api_path` (`api_path`,`api_method`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='统一API网关接口表（政务/第三方/硬件标准化对接）';

DROP TABLE IF EXISTS `sys_api_secret`;
CREATE TABLE `sys_api_secret` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '密钥ID',
  `api_id`       BIGINT UNSIGNED NOT NULL               COMMENT '接口ID（关联 sys_api_gateway.id）',
  `app_name`     VARCHAR(100) NOT NULL                  COMMENT '接入方名称',
  `app_key`      VARCHAR(64)  NOT NULL                  COMMENT '接入方AppKey（唯一）',
  `app_secret`   VARCHAR(200) NOT NULL                  COMMENT 'AppSecret（应用层加密存储）',
  `status`       TINYINT UNSIGNED NOT NULL DEFAULT 1    COMMENT '状态：0停用/1启用',
  `whitelist_ip` VARCHAR(500) NOT NULL DEFAULT ''       COMMENT '接入方IP白名单（逗号分隔）',
  `expire_at`    DATETIME NULL                          COMMENT '密钥有效期',
  `created_by`   BIGINT UNSIGNED NULL                   COMMENT '创建人（关联 auth_user.id）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_api_key` (`app_key`),
  KEY `idx_api_secret` (`api_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='API接入密钥表';

-- ---------------------------------------------------------------------
-- 10. 门禁硬件全局注册（超级管理员统一管控，全学段复用）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_gate_device`;
CREATE TABLE `sys_gate_device` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '设备ID',
  `org_id`        BIGINT UNSIGNED NOT NULL              COMMENT '机构ID（关联 sys_org.id；0=平台级未分配）',
  `device_code`   VARCHAR(64)  NOT NULL                 COMMENT '设备编码（唯一，硬件SN）',
  `device_name`   VARCHAR(100) NOT NULL                 COMMENT '设备名称',
  `device_type`   VARCHAR(20)  NOT NULL                 COMMENT '设备类型：gate闸机/door门禁/face人脸终端/card刷卡器',
  `model`         VARCHAR(100) NOT NULL DEFAULT ''      COMMENT '设备型号（型号兼容）',
  `vendor`        VARCHAR(100) NOT NULL DEFAULT ''      COMMENT '厂商',
  `location`      VARCHAR(200) NOT NULL DEFAULT ''      COMMENT '安装位置（校门/教学楼/实训场地等）',
  `ip`            VARCHAR(45)  NOT NULL DEFAULT ''      COMMENT '设备IP',
  `port`          INT NOT NULL DEFAULT 0                COMMENT '设备端口',
  `status`        TINYINT UNSIGNED NOT NULL DEFAULT 0   COMMENT '设备状态：0离线/1在线/2故障/3停用',
  `last_online_at` DATETIME NULL                        COMMENT '最近在线时间',
  `param_json`    JSON NULL                             COMMENT '设备参数配置（硬件对接参数）',
  `created_by`    BIGINT UNSIGNED NULL                  COMMENT '录入人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted`    TINYINT UNSIGNED NOT NULL DEFAULT 0   COMMENT '逻辑删除：0正常/1已删',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_device_code` (`device_code`),
  KEY `idx_device_org` (`org_id`),
  KEY `idx_device_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='门禁硬件设备全局注册表（超管统一管控，学段复用）';

-- ---------------------------------------------------------------------
-- 11. 政务数据上报（模板/字段映射/上报频率）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_gov_report_template`;
CREATE TABLE `sys_gov_report_template` (
  `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `template_code`  VARCHAR(50)  NOT NULL                COMMENT '模板编码（唯一）',
  `template_name`  VARCHAR(100) NOT NULL                COMMENT '模板名称',
  `target`         VARCHAR(50)  NOT NULL                COMMENT '上报对象：edu_bureau教育局/edu_dept教育厅/gov_platform政务平台',
  `stage_scope`    VARCHAR(100) NOT NULL DEFAULT 'ALL'  COMMENT '适用学段',
  `report_frequency` VARCHAR(10) NOT NULL DEFAULT 'monthly' COMMENT '上报频率：daily/weekly/monthly/quarterly/yearly',
  `template_json`  JSON NULL                            COMMENT '模板结构（含字段映射规则）',
  `status`         TINYINT UNSIGNED NOT NULL DEFAULT 1  COMMENT '状态：0停用/1启用',
  `created_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_report_template` (`template_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='政务数据上报模板表（教育局/教育厅对接）';

DROP TABLE IF EXISTS `sys_gov_report_field`;
CREATE TABLE `sys_gov_report_field` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '字段映射ID',
  `template_id`   BIGINT UNSIGNED NOT NULL              COMMENT '模板ID（关联 sys_gov_report_template.id）',
  `source_table`  VARCHAR(64)  NOT NULL                 COMMENT '来源数据表',
  `source_column` VARCHAR(64)  NOT NULL                 COMMENT '来源字段',
  `target_field`  VARCHAR(64)  NOT NULL                 COMMENT '上报目标字段',
  `transform_rule` VARCHAR(255) NOT NULL DEFAULT ''     COMMENT '转换规则（应用层执行）',
  `sort_no`       INT NOT NULL DEFAULT 0                COMMENT '排序号',
  PRIMARY KEY (`id`),
  KEY `idx_report_field` (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='政务上报字段映射表';

-- ---------------------------------------------------------------------
-- 12. 系统版本迭代 + 灰度发布 + 热补丁
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_version`;
CREATE TABLE `sys_version` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '版本ID',
  `version_no`   VARCHAR(30) NOT NULL                    COMMENT '版本号（唯一）',
  `version_name` VARCHAR(100) NOT NULL                   COMMENT '版本名称',
  `release_note` VARCHAR(1000) NOT NULL DEFAULT ''       COMMENT '发布说明（漏洞修复/功能迭代）',
  `is_hotpatch`  TINYINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '是否热补丁：0否/1是（无需停服）',
  `release_type` VARCHAR(10) NOT NULL DEFAULT 'patch'    COMMENT '发布类型：full全量/patch补丁',
  `status`       VARCHAR(20) NOT NULL DEFAULT 'draft'    COMMENT '状态：draft草稿/gray灰度中/published全量发布/rolled_back已回滚',
  `published_by` BIGINT UNSIGNED NULL                    COMMENT '发布人（关联 auth_user.id）',
  `published_at` DATETIME NULL                           COMMENT '发布时间',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_version_no` (`version_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统版本迭代表（热补丁/灰度上线支撑）';

DROP TABLE IF EXISTS `sys_version_org`;
CREATE TABLE `sys_version_org` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `version_id` BIGINT UNSIGNED NOT NULL                 COMMENT '版本ID（关联 sys_version.id）',
  `org_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（灰度指定机构试用）',
  `gray_status` VARCHAR(20) NOT NULL DEFAULT 'graying'  COMMENT '灰度状态：graying试用中/applied已应用/rolled_back已回滚',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_version_org` (`version_id`,`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='版本机构灰度发布表';

DROP TABLE IF EXISTS `sys_hotpatch`;
CREATE TABLE `sys_hotpatch` (
  `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '补丁ID',
  `patch_code`     VARCHAR(50) NOT NULL                  COMMENT '补丁编码（唯一）',
  `module_code`    VARCHAR(50) NOT NULL                  COMMENT '修复模块（关联 sys_module.module_code，单模块精准更新）',
  `patch_content`  TEXT NULL                             COMMENT '补丁内容/资源包地址',
  `fix_desc`       VARCHAR(500) NOT NULL DEFAULT ''      COMMENT '修复内容说明',
  `compare_before` TEXT NULL                             COMMENT '修复前对比（溯源归档）',
  `compare_after`  TEXT NULL                             COMMENT '修复后对比',
  `status`         VARCHAR(20) NOT NULL DEFAULT 'draft'  COMMENT '状态：draft草稿/applied已部署/verified修复核验通过/rolled_back已回滚',
  `applied_by`     BIGINT UNSIGNED NULL                  COMMENT '部署人（关联 auth_user.id）',
  `applied_at`     DATETIME NULL                         COMMENT '部署时间',
  `verified_at`    DATETIME NULL                         COMMENT '修复核验时间（修复完成报告闭环）',
  `rollback_at`    DATETIME NULL                         COMMENT '回滚时间',
  `created_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_patch_code` (`patch_code`),
  KEY `idx_patch_module` (`module_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='热补丁记录表（无感知热更新，版本溯源归档）';

-- ---------------------------------------------------------------------
-- 13. 数据备份 / 告警中心 / 日志审计（合规刚需，永久留存）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `sys_backup_record`;
CREATE TABLE `sys_backup_record` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '备份ID',
  `backup_type`   VARCHAR(10) NOT NULL                    COMMENT '触发方式：manual手动/auto定时',
  `backup_mode`   VARCHAR(10) NOT NULL DEFAULT 'full'     COMMENT '备份模式：full全量/incremental增量',
  `target_desc`   VARCHAR(255) NOT NULL DEFAULT ''        COMMENT '备份范围说明（全库/定点）',
  `file_path`     VARCHAR(500) NOT NULL                   COMMENT '备份文件存储路径',
  `file_size`     BIGINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '文件大小（字节）',
  `status`        VARCHAR(10) NOT NULL DEFAULT 'running'  COMMENT '状态：running/success/failed',
  `started_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
  `finished_at`   DATETIME NULL                           COMMENT '完成时间',
  `restored_at`   DATETIME NULL                           COMMENT '定点恢复时间（恢复留痕）',
  `operator_id`   BIGINT UNSIGNED NULL                    COMMENT '操作人（关联 auth_user.id）',
  `remark`        VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_backup_time` (`started_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='数据备份与恢复记录表';

DROP TABLE IF EXISTS `sys_alert`;
CREATE TABLE `sys_alert` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '告警ID',
  `alert_level`  VARCHAR(10) NOT NULL DEFAULT 'warn'      COMMENT '告警级别：info轻微/warn中级/error严重/fatal高危红色预警',
  `alert_type`   VARCHAR(20) NOT NULL                     COMMENT '异常类型：interface接口/db数据库/device设备离线/login异常登录/patch补丁/security安全',
  `module_code`  VARCHAR(50)  NOT NULL DEFAULT ''         COMMENT '异常模块（熔断定位）',
  `title`        VARCHAR(200) NOT NULL                    COMMENT '告警标题',
  `content`      TEXT NULL                                COMMENT '告警内容（报错代码行/操作路径/设备信息）',
  `trace_text`   TEXT NULL                                COMMENT '异常堆栈（精准定位）',
  `user_id`      BIGINT UNSIGNED NULL                     COMMENT '相关用户（关联 auth_user.id）',
  `org_id`       BIGINT UNSIGNED NULL                     COMMENT '相关机构（关联 sys_org.id）',
  `status`       TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '处理状态：0未处理/1处理中/2已解决/3忽略',
  `handled_by`   BIGINT UNSIGNED NULL                     COMMENT '处理人（关联 auth_user.id）',
  `handled_at`   DATETIME NULL                            COMMENT '处理时间',
  `handle_remark` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '处理备注（自愈/熔断/修复闭环）',
  `occurred_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发生时间',
  PRIMARY KEY (`id`),
  KEY `idx_alert_level` (`alert_level`,`status`),
  KEY `idx_alert_time` (`occurred_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='智能异常告警表（实时推送开发者超管，分级处理）';

DROP TABLE IF EXISTS `sys_log_login`;
CREATE TABLE `sys_log_login` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id`     BIGINT UNSIGNED NULL                     COMMENT '用户ID（关联 auth_user.id）',
  `username`    VARCHAR(64) NOT NULL                     COMMENT '登录账号',
  `org_id`      BIGINT UNSIGNED NULL                     COMMENT '机构ID（关联 sys_org.id）',
  `login_type`  VARCHAR(10) NOT NULL DEFAULT 'password'  COMMENT '登录方式：password密码/sms短信/scan扫码',
  `login_result` TINYINT UNSIGNED NOT NULL               COMMENT '结果：0失败/1成功',
  `fail_reason` VARCHAR(100) NOT NULL DEFAULT ''         COMMENT '失败原因（异常登录捕获）',
  `ip`          VARCHAR(45) NOT NULL DEFAULT ''          COMMENT '登录IP',
  `user_agent`  VARCHAR(500) NOT NULL DEFAULT ''         COMMENT '浏览器/设备信息',
  `device_info` VARCHAR(200) NOT NULL DEFAULT ''         COMMENT '设备信息',
  `login_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  PRIMARY KEY (`id`),
  KEY `idx_login_user` (`user_id`,`login_at`),
  KEY `idx_login_org` (`org_id`),
  KEY `idx_login_ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='登录日志表（永久留存，异常登录审计）';

DROP TABLE IF EXISTS `sys_log_operation`;
CREATE TABLE `sys_log_operation` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id`       BIGINT UNSIGNED NULL                   COMMENT '操作人（关联 auth_user.id）',
  `username`      VARCHAR(64) NOT NULL DEFAULT ''        COMMENT '操作人账号（冗余，防账号注销后不可溯源）',
  `org_id`        BIGINT UNSIGNED NULL                   COMMENT '机构ID（关联 sys_org.id；平台操作为NULL）',
  `biz_type`      VARCHAR(20) NOT NULL                   COMMENT '业务类型：org机构/user账号/config配置/module模块/device硬件/api接口/patch补丁/backup备份/business业务/finance财务',
  `action`        VARCHAR(50) NOT NULL                   COMMENT '操作动作：create/update/delete/import/export/audit/enable/disable/reset等',
  `target_table`  VARCHAR(64) NOT NULL DEFAULT ''        COMMENT '目标数据表',
  `target_id`     BIGINT UNSIGNED NULL                   COMMENT '目标数据ID',
  `detail_before` TEXT NULL                              COMMENT '操作前内容（数据修改留痕）',
  `detail_after`  TEXT NULL                              COMMENT '操作后内容',
  `ip`            VARCHAR(45) NOT NULL DEFAULT ''        COMMENT '操作IP',
  `operated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `idx_op_user` (`user_id`,`operated_at`),
  KEY `idx_op_org` (`org_id`),
  KEY `idx_op_target` (`target_table`,`target_id`),
  KEY `idx_op_time` (`operated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='全量操作日志表（全操作留痕，永久留存可溯源）';

DROP TABLE IF EXISTS `sys_log_api`;
CREATE TABLE `sys_log_api` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `api_code`      VARCHAR(100) NOT NULL DEFAULT ''       COMMENT '接口编码（关联 sys_api_gateway.api_code）',
  `api_path`      VARCHAR(200) NOT NULL                  COMMENT '接口路径',
  `method`        VARCHAR(10) NOT NULL                   COMMENT '请求方法',
  `org_id`        BIGINT UNSIGNED NULL                   COMMENT '机构ID（关联 sys_org.id）',
  `user_id`       BIGINT UNSIGNED NULL                   COMMENT '调用人（关联 auth_user.id）',
  `request_param` TEXT NULL                              COMMENT '请求参数摘要（敏感字段脱敏后记录）',
  `response_code` INT NULL                               COMMENT '响应码（4xx/5xx异常捕获）',
  `cost_ms`       INT NOT NULL DEFAULT 0                 COMMENT '耗时（毫秒）',
  `ip`            VARCHAR(45) NOT NULL DEFAULT ''        COMMENT '调用IP',
  `called_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '调用时间',
  PRIMARY KEY (`id`),
  KEY `idx_api_log` (`api_code`,`called_at`),
  KEY `idx_api_time` (`called_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='接口调用日志表（API网关流量审计）';
