-- =====================================================================
-- 全学段一站式学生综合管理系统（幼儿园-大学全覆盖｜最终定稿冻结版）
-- 01_init_database.sql —— 建库与全局会话参数
-- 目标环境：MySQL 8.0.45（utf8mb4 / InnoDB）
-- 导入顺序：本文件必须第一个执行，随后按 02~13 顺序导入
-- =====================================================================

SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS `all_stage_edu`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE `all_stage_edu`;

-- 全局会话约束（严谨性兜底：本库内严格模式，时间统一 UTC+8 由应用层转换）
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,ERROR_FOR_DIVISION_BY_ZERO';
SET SESSION time_zone = '+08:00';
SET SESSION FOREIGN_KEY_CHECKS = 0;

-- 说明：本系统按冻结文档「模块彻底解耦、无联表强依赖」原则，
--       全部采用逻辑外键（关联列 + 索引 + COMMENT 标注），不建物理外键。
