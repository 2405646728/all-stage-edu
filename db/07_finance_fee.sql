-- =====================================================================
-- 07_finance_fee.sql —— 收费台账与财务合规（全学段独立财务闭环）
-- 对应文档：5.2.4 校园收费台账体系、各学段「收费台账与财务模块」、
--           10.1.7 高校收费/学费抵扣/奖助补贴
-- 约定：财务体系独立运转，仅读取学生在读/班级基础数据，无业务权限干预；
--       财务日志与业务日志、运维日志隔离存储，永久溯源。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 1. 收费项目配置（保教费/伙食费/杂费/课后服务费/学费/住宿费/实训耗材费等）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `fin_fee_item`;
CREATE TABLE `fin_fee_item` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '收费项目ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `item_code`   VARCHAR(32) NOT NULL                     COMMENT '项目编码（机构内唯一）',
  `item_name`   VARCHAR(100) NOT NULL                    COMMENT '项目名称（保教费/伙食费/杂费/课后服务费/学费/住宿费/实训耗材费等）',
  `fee_type`    VARCHAR(20) NOT NULL                     COMMENT '收费类型：tuition学费/fixed固定收费/meal伙食据实/one_time一次性杂费/service服务费/boarding住宿费/material教辅资料/training实训耗材',
  `stage_scope` VARCHAR(100) NOT NULL DEFAULT 'ALL'      COMMENT '适用学段：ALL或逗号分隔',
  `charge_cycle` VARCHAR(10) NOT NULL DEFAULT 'term'     COMMENT '计费周期：month按月/term按学期/year按学年/one_time一次性',
  `default_amount` DECIMAL(12,2) NOT NULL DEFAULT 0      COMMENT '默认标准金额（元）',
  `description` VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '收费说明',
  `status`      TINYINT UNSIGNED NOT NULL DEFAULT 1      COMMENT '状态：0停用/1启用',
  `created_by`  BIGINT UNSIGNED NULL                     COMMENT '创建人（关联 auth_user.id）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted`  TINYINT UNSIGNED NOT NULL DEFAULT 0      COMMENT '逻辑删除：0正常/1已删',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_fee_item` (`org_id`,`item_code`),
  KEY `idx_fee_item_org` (`org_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收费项目配置表（合规收费项目自定义，杜绝违规收费）';

-- ---------------------------------------------------------------------
-- 2. 收费标准（班级批量计费 + 单人调费，标准完全独立存储）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `fin_fee_standard`;
CREATE TABLE `fin_fee_standard` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '标准ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `fee_item_id` BIGINT UNSIGNED NOT NULL                 COMMENT '收费项目（关联 fin_fee_item.id）',
  `school_year_id` BIGINT UNSIGNED NOT NULL              COMMENT '学年（关联 base_school_year.id）',
  `term_id`     BIGINT UNSIGNED NULL                     COMMENT '学期（关联 base_term.id；年收费为NULL）',
  `scope_type`  VARCHAR(10) NOT NULL DEFAULT 'class'     COMMENT '适用范围：class班级批量/student单人调费/org全机构/major专业批量',
  `class_id`    BIGINT UNSIGNED NULL                     COMMENT '班级ID（class范围，关联 base_class.id）',
  `student_id`  BIGINT UNSIGNED NULL                     COMMENT '学生ID（student单人调费，关联 base_student.id）',
  `major_id`    BIGINT UNSIGNED NULL                     COMMENT '专业ID（专业批量计费，职高/高校）',
  `amount`      DECIMAL(12,2) NOT NULL                   COMMENT '收费标准金额（元）',
  `operator_id` BIGINT UNSIGNED NULL                     COMMENT '操作人（关联 auth_user.id，调整留痕）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_standard_org` (`org_id`,`fee_item_id`),
  KEY `idx_standard_class` (`class_id`),
  KEY `idx_standard_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收费标准表（班级批量计费/单人调费/阶段性收费）';

-- ---------------------------------------------------------------------
-- 3. 学生账单（自动归集已缴/未缴/欠费/补缴状态）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `fin_bill`;
CREATE TABLE `fin_bill` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '账单ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `bill_no`       VARCHAR(40) NOT NULL                    COMMENT '账单编号（唯一）',
  `student_id`    BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `class_id`      BIGINT UNSIGNED NULL                    COMMENT '班级ID（统计维度，关联 base_class.id）',
  `fee_item_id`   BIGINT UNSIGNED NOT NULL                COMMENT '收费项目（关联 fin_fee_item.id）',
  `standard_id`   BIGINT UNSIGNED NULL                    COMMENT '收费标准（关联 fin_fee_standard.id）',
  `school_year_id` BIGINT UNSIGNED NOT NULL               COMMENT '学年（关联 base_school_year.id）',
  `term_id`       BIGINT UNSIGNED NULL                    COMMENT '学期（关联 base_term.id）',
  `bill_amount`   DECIMAL(12,2) NOT NULL                  COMMENT '应缴金额（元）',
  `reduced_amount` DECIMAL(12,2) NOT NULL DEFAULT 0       COMMENT '减免/抵扣金额（元，奖学金抵扣/学费减免）',
  `paid_amount`   DECIMAL(12,2) NOT NULL DEFAULT 0        COMMENT '已缴金额（元）',
  `bill_status`   VARCHAR(10) NOT NULL DEFAULT 'unpaid'   COMMENT '账单状态：unpaid未缴/partial部分缴/paid已缴/waived已减免/refunded已退/void已作废',
  `due_date`      DATE NULL                               COMMENT '缴费截止日期',
  `remark`        VARCHAR(255) NOT NULL DEFAULT ''        COMMENT '备注',
  `created_by`    BIGINT UNSIGNED NULL                    COMMENT '生成人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '生成时间',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_bill_no` (`bill_no`),
  KEY `idx_bill_student` (`student_id`,`bill_status`),
  KEY `idx_bill_org` (`org_id`,`school_year_id`),
  KEY `idx_bill_class` (`class_id`),
  KEY `idx_bill_item` (`fee_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生缴费账单表（缴费状态管理与欠费统计）';

-- ---------------------------------------------------------------------
-- 4. 缴费记录（缴费/补缴/退款流水，全程留痕）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `fin_payment`;
CREATE TABLE `fin_payment` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '缴费记录ID',
  `org_id`      BIGINT UNSIGNED NOT NULL                 COMMENT '机构ID（关联 sys_org.id）',
  `bill_id`     BIGINT UNSIGNED NOT NULL                 COMMENT '账单ID（关联 fin_bill.id）',
  `student_id`  BIGINT UNSIGNED NOT NULL                 COMMENT '学生ID（关联 base_student.id）',
  `pay_no`      VARCHAR(40) NOT NULL                     COMMENT '缴费流水号（唯一，对接支付渠道）',
  `pay_type`    VARCHAR(10) NOT NULL DEFAULT 'normal'    COMMENT '缴费类型：normal正常缴费/arrears补缴/refund退款/adjust调整',
  `pay_amount`  DECIMAL(12,2) NOT NULL                   COMMENT '缴费金额（元，退款为负数）',
  `pay_way`     VARCHAR(20) NOT NULL DEFAULT 'offline'   COMMENT '缴费方式：offline线下/cash现金/wechat微信/alipay支付宝/bank银行转账/deduction抵扣核销',
  `pay_time`    DATETIME NOT NULL                        COMMENT '缴费时间',
  `receipt_file` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '凭证（关联 base_file）',
  `operator_id` BIGINT UNSIGNED NOT NULL                 COMMENT '经办人（关联 auth_user.id）',
  `remark`      VARCHAR(255) NOT NULL DEFAULT ''         COMMENT '备注',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '录入时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_pay_no` (`pay_no`),
  KEY `idx_pay_bill` (`bill_id`),
  KEY `idx_pay_student` (`student_id`,`pay_time`),
  KEY `idx_pay_org` (`org_id`,`pay_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='缴费记录表（缴费/补缴/退款全流水）';

-- ---------------------------------------------------------------------
-- 5. 减免抵扣（奖学金抵扣/学费减免/助学金/助学贷款，高校及全学段扶贫场景）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `fin_reduction`;
CREATE TABLE `fin_reduction` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '减免ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `student_id`    BIGINT UNSIGNED NOT NULL                COMMENT '学生ID（关联 base_student.id）',
  `bill_id`       BIGINT UNSIGNED NULL                    COMMENT '抵扣账单（关联 fin_bill.id；NULL=预存减免额度）',
  `reduce_type`   VARCHAR(20) NOT NULL                    COMMENT '减免类型：scholarship奖学金抵扣/grant助学金/loan助学贷款/waiver学费减免/poverty贫困生帮扶',
  `reduce_amount` DECIMAL(12,2) NOT NULL                  COMMENT '减免金额（元）',
  `school_year_id` BIGINT UNSIGNED NOT NULL               COMMENT '学年（关联 base_school_year.id）',
  `evidence_file` VARCHAR(500) NOT NULL DEFAULT ''        COMMENT '佐证材料（关联 base_file）',
  `audit_status`  VARCHAR(10) NOT NULL DEFAULT 'pending'  COMMENT '审核状态：pending/approved/rejected',
  `audit_by`      BIGINT UNSIGNED NULL                    COMMENT '审核人（关联 auth_user.id）',
  `audit_at`      DATETIME NULL                           COMMENT '审核时间',
  `operator_id`   BIGINT UNSIGNED NOT NULL                COMMENT '经办人（关联 auth_user.id）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_reduce_student` (`student_id`,`school_year_id`),
  KEY `idx_reduce_org` (`org_id`,`audit_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='减免抵扣表（奖助抵扣台账，精准核算实际缴费）';

-- ---------------------------------------------------------------------
-- 6. 财务操作日志（独立日志体系：所有新增/调整/核销/批量操作永久留存）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `fin_ledger_log`;
CREATE TABLE `fin_ledger_log` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `org_id`        BIGINT UNSIGNED NOT NULL                COMMENT '机构ID（关联 sys_org.id）',
  `action`        VARCHAR(20) NOT NULL                    COMMENT '操作：create录入/adjust调整/offset补缴核销/write_off核销/reduce减免/batch批量/export导出/refund退款',
  `target_table`  VARCHAR(64) NOT NULL DEFAULT ''         COMMENT '目标数据表（fin_bill/fin_payment/fin_standard等）',
  `target_id`     BIGINT UNSIGNED NULL                    COMMENT '目标数据ID',
  `bill_no`       VARCHAR(40) NOT NULL DEFAULT ''         COMMENT '涉及账单号',
  `amount_before` DECIMAL(12,2) NULL                      COMMENT '调整前金额（元）',
  `amount_after`  DECIMAL(12,2) NULL                      COMMENT '调整后金额（元）',
  `detail`        TEXT NULL                               COMMENT '操作明细（调整内容）',
  `operator_id`   BIGINT UNSIGNED NOT NULL                COMMENT '操作人（关联 auth_user.id）',
  `operator_name` VARCHAR(64) NOT NULL DEFAULT ''         COMMENT '操作人账号（冗余溯源）',
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `idx_finlog_org` (`org_id`,`created_at`),
  KEY `idx_finlog_bill` (`bill_no`),
  KEY `idx_finlog_target` (`target_table`,`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='财务操作日志表（与业务/运维日志隔离存储，审计合规）';
