-- =====================================================================
-- 14_test_data.sql —— 全学段测试/演示数据（六学段全覆盖）
-- 前置条件：01~13 已按顺序导入；库：all_stage_edu
-- 说明：
--   1) 所有测试账号初始密码统一为 123456（BCrypt 存储，已校验匹配）；
--   2) must_change_pwd=1（模拟批量开通强制首登改密，前端演示可忽略）；
--   3) 超级管理员 superadmin 由占位密码初始化为 123456 并激活；
--   4) 身份证号/学籍号等为虚构演示数据，仅用于测试环境；
--   5) 本文件可重复执行前请先 DROP DATABASE 重建（避免唯一键冲突），
--      或直接先执行 01 重建库后再 02~14 顺序导入。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 0. 激活超级管理员（占位密码 -> 123456，状态冻结 -> 正常）
-- ---------------------------------------------------------------------
UPDATE `auth_user` SET `password_hash`='$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2', `status`=1, `must_change_pwd`=1 WHERE `username`='superadmin';

-- ---------------------------------------------------------------------
-- 1. 六学段机构 + 校区（学段判定唯一依据：sys_org.stage）
-- ---------------------------------------------------------------------
INSERT INTO `sys_org` (`org_code`,`org_name`,`stage`,`school_type`,`province`,`city`,`district`,`address`,`contact_name`,`contact_phone`,`status`) VALUES
('KG01','阳光实验幼儿园','kindergarten','public','北京市','北京市','海淀区','中关村南大街1号','张园长','13900000001',1),
('PS01','明德实验小学','primary','public','北京市','北京市','海淀区','学院路2号','李校长','13900000002',1),
('MS01','启航实验初中','junior','public','北京市','北京市','海淀区','知春路3号','王校长','13900000003',1),
('HS01','致远高级中学','senior','private','北京市','北京市','海淀区','上地四街4号','刘校长','13900000004',1),
('VS01','精工职业技术学校','vocational','private','北京市','北京市','海淀区','西三旗5号','陈校长','13900000005',1),
('UN01','华信大学','university','public','北京市','北京市','海淀区','学院路37号','周校长','13900000006',1);

INSERT INTO `sys_campus` (`org_id`,`campus_code`,`campus_name`,`is_main`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'C01','阳光实验幼儿园总园',1,1),
((SELECT id FROM sys_org WHERE org_code='PS01'),'C01','明德实验小学本部',1,1),
((SELECT id FROM sys_org WHERE org_code='MS01'),'C01','启航实验初中本部',1,1),
((SELECT id FROM sys_org WHERE org_code='HS01'),'C01','致远高级中学校本部',1,1),
((SELECT id FROM sys_org WHERE org_code='VS01'),'C01','精工职校实训校区',1,1),
((SELECT id FROM sys_org WHERE org_code='UN01'),'C01','华信大学主校区',1,1);

-- ---------------------------------------------------------------------
-- 2. 学年 / 学期（统一 2025-2026 学年 第一学期）
-- ---------------------------------------------------------------------
INSERT INTO `base_school_year` (`org_id`,`year_name`,`start_date`,`end_date`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'2025-2026学年','2025-09-01','2026-08-31',1),
((SELECT id FROM sys_org WHERE org_code='PS01'),'2025-2026学年','2025-09-01','2026-08-31',1),
((SELECT id FROM sys_org WHERE org_code='MS01'),'2025-2026学年','2025-09-01','2026-08-31',1),
((SELECT id FROM sys_org WHERE org_code='HS01'),'2025-2026学年','2025-09-01','2026-08-31',1),
((SELECT id FROM sys_org WHERE org_code='VS01'),'2025-2026学年','2025-09-01','2026-08-31',1),
((SELECT id FROM sys_org WHERE org_code='UN01'),'2025-2026学年','2025-09-01','2026-08-31',1);

INSERT INTO `base_term` (`org_id`,`school_year_id`,`term_name`,`term_no`,`start_date`,`end_date`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND year_name='2025-2026学年'),'第一学期',1,'2025-09-01','2026-01-31',1),
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND year_name='2025-2026学年'),'第一学期',1,'2025-09-01','2026-01-31',1),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND year_name='2025-2026学年'),'第一学期',1,'2025-09-01','2026-01-31',1),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND year_name='2025-2026学年'),'第一学期',1,'2025-09-01','2026-01-31',1),
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND year_name='2025-2026学年'),'第一学期',1,'2025-09-01','2026-01-31',1),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND year_name='2025-2026学年'),'第一学期',1,'2025-09-01','2026-01-31',1);

-- ---------------------------------------------------------------------
-- 3. 年级 / 班级
-- ---------------------------------------------------------------------
INSERT INTO `base_grade` (`org_id`,`stage`,`grade_name`,`grade_no`,`school_year_id`,`class_capacity`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten','小班',1,(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01')),25,1),
((SELECT id FROM sys_org WHERE org_code='PS01'),'primary','三年级',3,(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01')),45,1),
((SELECT id FROM sys_org WHERE org_code='MS01'),'junior','七年级',7,(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01')),50,1),
((SELECT id FROM sys_org WHERE org_code='HS01'),'senior','高一',10,(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01')),50,1),
((SELECT id FROM sys_org WHERE org_code='VS01'),'vocational','职高一年级',1,(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01')),40,1),
((SELECT id FROM sys_org WHERE org_code='UN01'),'university','大二',14,(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),60,1),
((SELECT id FROM sys_org WHERE org_code='UN01'),'university','大四',16,(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),60,1);

INSERT INTO `base_class` (`org_id`,`stage`,`grade_id`,`class_name`,`class_type`,`class_capacity`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND grade_name='小班'),'小一班','normal',25,1),
((SELECT id FROM sys_org WHERE org_code='PS01'),'primary',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND grade_name='三年级'),'三年级1班','normal',45,1),
((SELECT id FROM sys_org WHERE org_code='MS01'),'junior',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND grade_name='七年级'),'七年级1班','normal',50,1),
((SELECT id FROM sys_org WHERE org_code='HS01'),'senior',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_name='高一'),'高一(1)班','normal',50,1),
((SELECT id FROM sys_org WHERE org_code='VS01'),'vocational',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND grade_name='职高一年级'),'数控技术1班','normal',40,1),
((SELECT id FROM sys_org WHERE org_code='UN01'),'university',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND grade_name='大二'),'计算机2201班','normal',60,1),
((SELECT id FROM sys_org WHERE org_code='UN01'),'university',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND grade_name='大四'),'计算机2204班','normal',60,1);

-- ---------------------------------------------------------------------
-- 4. 全平台测试账号（统一密码 123456，BCrypt）
-- ---------------------------------------------------------------------
INSERT INTO `auth_user` (`username`,`password_hash`,`real_name`,`user_type`,`org_id`,`stage`,`gender`,`phone`,`email`,`status`,`must_change_pwd`,`open_channel`) VALUES
('admin_kg','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','张园长','school_admin',(SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten',2,'13910000001','admin_kg@example.com',1,1,'manual'),
('admin_ps','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','李校长','school_admin',(SELECT id FROM sys_org WHERE org_code='PS01'),'primary',1,'13910000002','admin_ps@example.com',1,1,'manual'),
('admin_ms','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','王校长','school_admin',(SELECT id FROM sys_org WHERE org_code='MS01'),'junior',1,'13910000003','admin_ms@example.com',1,1,'manual'),
('admin_hs','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','刘校长','school_admin',(SELECT id FROM sys_org WHERE org_code='HS01'),'senior',1,'13910000004','admin_hs@example.com',1,1,'manual'),
('admin_vs','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','陈校长','school_admin',(SELECT id FROM sys_org WHERE org_code='VS01'),'vocational',1,'13910000005','admin_vs@example.com',1,1,'manual'),
('admin_un','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','周校长','school_admin',(SELECT id FROM sys_org WHERE org_code='UN01'),'university',1,'13910000006','admin_un@example.com',1,1,'manual'),
('t_kg01','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','王芳','teacher',(SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten',2,'13910000011','t_kg01@example.com',1,1,'manual'),
('t_ps01','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','马文','teacher',(SELECT id FROM sys_org WHERE org_code='PS01'),'primary',2,'13910000012','t_ps01@example.com',1,1,'manual'),
('t_ms01','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','徐静','teacher',(SELECT id FROM sys_org WHERE org_code='MS01'),'junior',2,'13910000013','t_ms01@example.com',1,1,'manual'),
('t_hs01','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','何峰','teacher',(SELECT id FROM sys_org WHERE org_code='HS01'),'senior',1,'13910000014','t_hs01@example.com',1,1,'manual'),
('t_vs01','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','罗师傅','teacher',(SELECT id FROM sys_org WHERE org_code='VS01'),'vocational',1,'13910000015','t_vs01@example.com',1,1,'manual'),
('t_un01','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','沈导员','teacher',(SELECT id FROM sys_org WHERE org_code='UN01'),'university',2,'13910000016','t_un01@example.com',1,1,'manual'),
('s_kg001','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','张一一','student',(SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten',1,'','s_kg001@example.com',1,1,'manual'),
('s_kg002','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','李二二','student',(SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten',1,'','s_kg002@example.com',1,1,'manual'),
('s_kg003','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','王三三','student',(SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten',2,'','s_kg003@example.com',1,1,'manual'),
('s_kg004','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','赵四四','student',(SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten',1,'','s_kg004@example.com',1,1,'manual'),
('s_ps001','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','陈小风','student',(SELECT id FROM sys_org WHERE org_code='PS01'),'primary',1,'','s_ps001@example.com',1,1,'manual'),
('s_ps002','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','刘小雨','student',(SELECT id FROM sys_org WHERE org_code='PS01'),'primary',2,'','s_ps002@example.com',1,1,'manual'),
('s_ps003','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','孙小阳','student',(SELECT id FROM sys_org WHERE org_code='PS01'),'primary',1,'','s_ps003@example.com',1,1,'manual'),
('s_ps004','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','周小星','student',(SELECT id FROM sys_org WHERE org_code='PS01'),'primary',2,'','s_ps004@example.com',1,1,'manual'),
('s_ms001','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','吴青','student',(SELECT id FROM sys_org WHERE org_code='MS01'),'junior',1,'','s_ms001@example.com',1,1,'manual'),
('s_ms002','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','郑澜','student',(SELECT id FROM sys_org WHERE org_code='MS01'),'junior',2,'','s_ms002@example.com',1,1,'manual'),
('s_ms003','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','冯远','student',(SELECT id FROM sys_org WHERE org_code='MS01'),'junior',1,'','s_ms003@example.com',1,1,'manual'),
('s_ms004','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','韩峰','student',(SELECT id FROM sys_org WHERE org_code='MS01'),'junior',1,'','s_ms004@example.com',1,1,'manual'),
('s_hs001','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','林志远','student',(SELECT id FROM sys_org WHERE org_code='HS01'),'senior',1,'','s_hs001@example.com',1,1,'manual'),
('s_hs002','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','杨帆','student',(SELECT id FROM sys_org WHERE org_code='HS01'),'senior',1,'','s_hs002@example.com',1,1,'manual'),
('s_hs003','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','朱明','student',(SELECT id FROM sys_org WHERE org_code='HS01'),'senior',1,'','s_hs003@example.com',1,1,'manual'),
('s_hs004','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','秦朗','student',(SELECT id FROM sys_org WHERE org_code='HS01'),'senior',2,'','s_hs004@example.com',1,1,'manual'),
('s_vs001','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','赵铁柱','student',(SELECT id FROM sys_org WHERE org_code='VS01'),'vocational',1,'','s_vs001@example.com',1,1,'manual'),
('s_vs002','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','钱学工','student',(SELECT id FROM sys_org WHERE org_code='VS01'),'vocational',1,'','s_vs002@example.com',1,1,'manual'),
('s_vs003','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','孙巧手','student',(SELECT id FROM sys_org WHERE org_code='VS01'),'vocational',2,'','s_vs003@example.com',1,1,'manual'),
('s_vs004','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','李焊工','student',(SELECT id FROM sys_org WHERE org_code='VS01'),'vocational',1,'','s_vs004@example.com',1,1,'manual'),
('s_un001','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','王思睿','student',(SELECT id FROM sys_org WHERE org_code='UN01'),'university',1,'','s_un001@example.com',1,1,'manual'),
('s_un002','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','李泽言','student',(SELECT id FROM sys_org WHERE org_code='UN01'),'university',1,'','s_un002@example.com',1,1,'manual'),
('s_un003','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','张沐辰','student',(SELECT id FROM sys_org WHERE org_code='UN01'),'university',1,'','s_un003@example.com',1,1,'manual'),
('s_un004','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','陈嘉怡','student',(SELECT id FROM sys_org WHERE org_code='UN01'),'university',2,'','s_un004@example.com',1,1,'manual'),
('s_un101','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','刘子涵','student',(SELECT id FROM sys_org WHERE org_code='UN01'),'university',2,'','s_un101@example.com',1,1,'manual'),
('s_un102','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','周雨桐','student',(SELECT id FROM sys_org WHERE org_code='UN01'),'university',2,'','s_un102@example.com',1,1,'manual'),
('p_kg01','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','张爸爸','parent',(SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten',1,'13910000101','p_kg01@example.com',1,1,'manual'),
('p_ps01','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','陈妈妈','parent',(SELECT id FROM sys_org WHERE org_code='PS01'),'primary',2,'13910000102','p_ps01@example.com',1,1,'manual'),
('p_ms01','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','吴爸爸','parent',(SELECT id FROM sys_org WHERE org_code='MS01'),'junior',1,'13910000103','p_ms01@example.com',1,1,'manual'),
('p_hs01','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','林妈妈','parent',(SELECT id FROM sys_org WHERE org_code='HS01'),'senior',2,'13910000104','p_hs01@example.com',1,1,'manual'),
('p_vs01','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','赵爸爸','parent',(SELECT id FROM sys_org WHERE org_code='VS01'),'vocational',1,'13910000105','p_vs01@example.com',1,1,'manual'),
('p_un01','$2b$10$r1Mpi0zb67JwcYFpsklsBu011nNYXSBwen88TiEHxo8XWDoe6phu2','王爸爸','parent',(SELECT id FROM sys_org WHERE org_code='UN01'),'university',1,'13910000106','p_un01@example.com',1,1,'manual');

-- ---------------------------------------------------------------------
-- 5. 用户角色绑定（六级角色自动匹配）
-- ---------------------------------------------------------------------
INSERT INTO `auth_user_role` (`user_id`,`role_id`,`org_id`,`status`)
SELECT u.id, r.id, u.org_id, 1 FROM `auth_user` u JOIN `sys_role` r ON r.role_code=
CASE u.user_type WHEN 'school_admin' THEN 'SCHOOL_ADMIN' WHEN 'teacher' THEN 'TEACHER_STAFF' WHEN 'student' THEN 'STUDENT' WHEN 'parent' THEN 'PARENT' END
WHERE u.username <> 'superadmin';


-- ---------------------------------------------------------------------
-- 6. 学生主档（学号机构内唯一，身份证为虚构演示数据）
-- ---------------------------------------------------------------------
INSERT INTO `base_student` (`org_id`,`stage`,`student_no`,`user_id`,`name`,`gender`,`birth_date`,`id_card`,`nation`,`address`,`admit_date`,`study_status`,`boarder`,`current_class_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten','KG2025001',(SELECT id FROM auth_user WHERE username='s_kg001'),'张一一',1,'2022-03-12','110101202203120011','汉族','北京市海淀区', '2025-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班')),
((SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten','KG2025002',(SELECT id FROM auth_user WHERE username='s_kg002'),'李二二',1,'2022-06-05','110101202206050022','汉族','北京市海淀区', '2025-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班')),
((SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten','KG2025003',(SELECT id FROM auth_user WHERE username='s_kg003'),'王三三',2,'2022-01-28','110101202201280023','汉族','北京市海淀区', '2025-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班')),
((SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten','KG2025004',(SELECT id FROM auth_user WHERE username='s_kg004'),'赵四四',1,'2022-08-19','110101202208190024','汉族','北京市海淀区', '2025-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班')),
((SELECT id FROM sys_org WHERE org_code='PS01'),'primary','PS2017001',(SELECT id FROM auth_user WHERE username='s_ps001'),'陈小风',1,'2017-04-11','110101201704110031','汉族','北京市海淀区','2022-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班')),
((SELECT id FROM sys_org WHERE org_code='PS01'),'primary','PS2017002',(SELECT id FROM auth_user WHERE username='s_ps002'),'刘小雨',2,'2017-07-23','110101201707230042','汉族','北京市海淀区','2022-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班')),
((SELECT id FROM sys_org WHERE org_code='PS01'),'primary','PS2017003',(SELECT id FROM auth_user WHERE username='s_ps003'),'孙小阳',1,'2017-02-09','110101201702090053','汉族','北京市海淀区','2022-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班')),
((SELECT id FROM sys_org WHERE org_code='PS01'),'primary','PS2017004',(SELECT id FROM auth_user WHERE username='s_ps004'),'周小星',2,'2017-11-30','110101201711300064','汉族','北京市海淀区','2022-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班')),
((SELECT id FROM sys_org WHERE org_code='MS01'),'junior','MS2025001',(SELECT id FROM auth_user WHERE username='s_ms001'),'吴青',1,'2013-05-17','110101201305170071','汉族','北京市海淀区','2025-09-01','normal',1,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班')),
((SELECT id FROM sys_org WHERE org_code='MS01'),'junior','MS2025002',(SELECT id FROM auth_user WHERE username='s_ms002'),'郑澜',2,'2013-09-03','110101201309030082','汉族','北京市海淀区','2025-09-01','normal',1,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班')),
((SELECT id FROM sys_org WHERE org_code='MS01'),'junior','MS2025003',(SELECT id FROM auth_user WHERE username='s_ms003'),'冯远',1,'2013-01-25','110101201301250093','汉族','北京市海淀区','2025-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班')),
((SELECT id FROM sys_org WHERE org_code='MS01'),'junior','MS2025004',(SELECT id FROM auth_user WHERE username='s_ms004'),'韩峰',1,'2013-10-08','110101201310080104','汉族','北京市海淀区','2025-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班')),
((SELECT id FROM sys_org WHERE org_code='HS01'),'senior','HS2025001',(SELECT id FROM auth_user WHERE username='s_hs001'),'林志远',1,'2010-06-14','110101201006140111','汉族','北京市海淀区','2025-09-01','normal',1,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='高一(1)班')),
((SELECT id FROM sys_org WHERE org_code='HS01'),'senior','HS2025002',(SELECT id FROM auth_user WHERE username='s_hs002'),'杨帆',1,'2010-03-21','110101201003210122','汉族','北京市海淀区','2025-09-01','normal',1,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='高一(1)班')),
((SELECT id FROM sys_org WHERE org_code='HS01'),'senior','HS2025003',(SELECT id FROM auth_user WHERE username='s_hs003'),'朱明',1,'2010-08-02','110101201008020133','汉族','北京市海淀区','2025-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='高一(1)班')),
((SELECT id FROM sys_org WHERE org_code='HS01'),'senior','HS2025004',(SELECT id FROM auth_user WHERE username='s_hs004'),'秦朗',2,'2010-12-16','110101201012160144','汉族','北京市海淀区','2025-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='高一(1)班')),
((SELECT id FROM sys_org WHERE org_code='VS01'),'vocational','VS2025001',(SELECT id FROM auth_user WHERE username='s_vs001'),'赵铁柱',1,'2010-04-09','110101201004090151','汉族','北京市昌平区','2025-09-01','normal',1,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND class_name='数控技术1班')),
((SELECT id FROM sys_org WHERE org_code='VS01'),'vocational','VS2025002',(SELECT id FROM auth_user WHERE username='s_vs002'),'钱学工',1,'2010-07-27','110101201007270162','汉族','北京市昌平区','2025-09-01','normal',1,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND class_name='数控技术1班')),
((SELECT id FROM sys_org WHERE org_code='VS01'),'vocational','VS2025003',(SELECT id FROM auth_user WHERE username='s_vs003'),'孙巧手',2,'2010-02-14','110101201002140173','汉族','北京市昌平区','2025-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND class_name='数控技术1班')),
((SELECT id FROM sys_org WHERE org_code='VS01'),'vocational','VS2025004',(SELECT id FROM auth_user WHERE username='s_vs004'),'李焊工',1,'2010-09-11','110101201009110184','汉族','北京市昌平区','2025-09-01','normal',1,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND class_name='数控技术1班')),
((SELECT id FROM sys_org WHERE org_code='UN01'),'university','UN2023001',(SELECT id FROM auth_user WHERE username='s_un001'),'王思睿',1,'2005-05-06','110101200505060201','汉族','北京市朝阳区','2023-09-01','normal',1,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND class_name='计算机2201班')),
((SELECT id FROM sys_org WHERE org_code='UN01'),'university','UN2023002',(SELECT id FROM auth_user WHERE username='s_un002'),'李泽言',1,'2005-01-19','110101200501190212','汉族','北京市朝阳区','2023-09-01','normal',1,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND class_name='计算机2201班')),
((SELECT id FROM sys_org WHERE org_code='UN01'),'university','UN2023003',(SELECT id FROM auth_user WHERE username='s_un003'),'张沐辰',1,'2005-10-02','110101200510020223','汉族','北京市朝阳区','2023-09-01','normal',0,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND class_name='计算机2201班')),
((SELECT id FROM sys_org WHERE org_code='UN01'),'university','UN2023004',(SELECT id FROM auth_user WHERE username='s_un004'),'陈嘉怡',2,'2005-08-25','110101200508250234','汉族','北京市朝阳区','2023-09-01','normal',1,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND class_name='计算机2201班')),
((SELECT id FROM sys_org WHERE org_code='UN01'),'university','UN2021001',(SELECT id FROM auth_user WHERE username='s_un101'),'刘子涵',2,'2003-12-07','110101200312070241','汉族','北京市朝阳区','2021-09-01','normal',1,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND class_name='计算机2204班')),
((SELECT id FROM sys_org WHERE org_code='UN01'),'university','UN2021002',(SELECT id FROM auth_user WHERE username='s_un102'),'周雨桐',2,'2003-04-29','110101200304290252','汉族','北京市朝阳区','2021-09-01','normal',1,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND class_name='计算机2204班'));

-- ---------------------------------------------------------------------
-- 7. 学籍（学籍号全局唯一：加学段前缀）
-- ---------------------------------------------------------------------
INSERT INTO `base_student_enrollment` (`org_id`,`student_id`,`enroll_no`,`stage`,`schooling_years`,`enroll_date`,`enroll_batch`,`current_grade_id`,`current_class_id`,`enroll_status`)
SELECT s.org_id, s.id,
       CASE s.stage WHEN 'kindergarten' THEN CONCAT('KGXJ',LPAD(ROW_NUMBER() OVER (PARTITION BY s.org_id ORDER BY s.id),4,'0'))
                    WHEN 'primary'     THEN CONCAT('PSXJ',LPAD(ROW_NUMBER() OVER (PARTITION BY s.org_id ORDER BY s.id),4,'0'))
                    WHEN 'junior'      THEN CONCAT('MSXJ',LPAD(ROW_NUMBER() OVER (PARTITION BY s.org_id ORDER BY s.id),4,'0'))
                    WHEN 'senior'      THEN CONCAT('HSXJ',LPAD(ROW_NUMBER() OVER (PARTITION BY s.org_id ORDER BY s.id),4,'0'))
                    WHEN 'vocational'  THEN CONCAT('VSXJ',LPAD(ROW_NUMBER() OVER (PARTITION BY s.org_id ORDER BY s.id),4,'0'))
                    ELSE CONCAT('UNXJ',LPAD(ROW_NUMBER() OVER (PARTITION BY s.org_id ORDER BY s.id),4,'0')) END,
       s.stage,
       CASE s.stage WHEN 'kindergarten' THEN 3 WHEN 'primary' THEN 6 WHEN 'junior' THEN 3 WHEN 'senior' THEN 3 WHEN 'vocational' THEN 3 ELSE 4 END,
       s.admit_date, '2025批次', c.grade_id, c.id, 'normal'
FROM base_student s
JOIN base_class c ON c.id = s.current_class_id;

-- ---------------------------------------------------------------------
-- 8. 班级成员关系（2025-2026 学年）
-- ---------------------------------------------------------------------
INSERT INTO `base_class_student` (`org_id`,`student_id`,`class_id`,`school_year_id`,`enter_type`,`enter_date`,`status`)
SELECT s.org_id, s.id, s.current_class_id, y.id, 'assigned', s.admit_date, 1
FROM base_student s
JOIN base_school_year y ON y.org_id = s.org_id AND y.year_name='2025-2026学年';

-- ---------------------------------------------------------------------
-- 9. 师资（每学段 1 名班主任，绑定班级）
-- ---------------------------------------------------------------------
INSERT INTO `base_teacher` (`org_id`,`stage`,`staff_no`,`user_id`,`name`,`gender`,`phone`,`hire_date`,`work_status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'kindergarten','TKG001',(SELECT id FROM auth_user WHERE username='t_kg01'),'王芳',2,'13910000011','2020-08-20','active'),
((SELECT id FROM sys_org WHERE org_code='PS01'),'primary','TPS001',(SELECT id FROM auth_user WHERE username='t_ps01'),'马文',2,'13910000012','2018-08-20','active'),
((SELECT id FROM sys_org WHERE org_code='MS01'),'junior','TMS001',(SELECT id FROM auth_user WHERE username='t_ms01'),'徐静',2,'13910000013','2015-08-20','active'),
((SELECT id FROM sys_org WHERE org_code='HS01'),'senior','THS001',(SELECT id FROM auth_user WHERE username='t_hs01'),'何峰',1,'13910000014','2014-08-20','active'),
((SELECT id FROM sys_org WHERE org_code='VS01'),'vocational','TVS001',(SELECT id FROM auth_user WHERE username='t_vs01'),'罗师傅',1,'13910000015','2012-08-20','active'),
((SELECT id FROM sys_org WHERE org_code='UN01'),'university','TUN001',(SELECT id FROM auth_user WHERE username='t_un01'),'沈导员',2,'13910000016','2020-08-20','active');

INSERT INTO `base_teacher_post` (`org_id`,`teacher_id`,`post_type`,`grade_id`,`class_id`,`subject_code`,`is_primary`,`assigned_at`,`post_status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_teacher WHERE staff_no='TKG001'),'head_teacher',NULL,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班'),'',1,'2025-09-01',1),
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM base_teacher WHERE staff_no='TPS001'),'head_teacher',NULL,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班'),'chinese',1,'2025-09-01',1),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_teacher WHERE staff_no='TMS001'),'head_teacher',NULL,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班'),'math',1,'2025-09-01',1),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_teacher WHERE staff_no='THS001'),'head_teacher',NULL,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='高一(1)班'),'physics',1,'2025-09-01',1),
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM base_teacher WHERE staff_no='TVS001'),'head_teacher',NULL,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND class_name='数控技术1班'),'major_course',1,'2025-09-01',1),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_teacher WHERE staff_no='TUN001'),'counselor',NULL,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND class_name='计算机2201班'),'',1,'2025-09-01',1);

-- ---------------------------------------------------------------------
-- 10. 监护人绑定（含接送授权）与健康档案
-- ---------------------------------------------------------------------
INSERT INTO `base_guardian` (`org_id`,`name`,`phone`,`relation`,`is_emergency`,`user_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'张爸爸','13910000101','father',1,(SELECT id FROM auth_user WHERE username='p_kg01')),
((SELECT id FROM sys_org WHERE org_code='KG01'),'李奶奶','13910000111','grandmother',0,NULL),
((SELECT id FROM sys_org WHERE org_code='PS01'),'陈妈妈','13910000102','mother',1,(SELECT id FROM auth_user WHERE username='p_ps01')),
((SELECT id FROM sys_org WHERE org_code='MS01'),'吴爸爸','13910000103','father',1,(SELECT id FROM auth_user WHERE username='p_ms01')),
((SELECT id FROM sys_org WHERE org_code='HS01'),'林妈妈','13910000104','mother',1,(SELECT id FROM auth_user WHERE username='p_hs01')),
((SELECT id FROM sys_org WHERE org_code='VS01'),'赵爸爸','13910000105','father',1,(SELECT id FROM auth_user WHERE username='p_vs01')),
((SELECT id FROM sys_org WHERE org_code='UN01'),'王爸爸','13910000106','father',1,(SELECT id FROM auth_user WHERE username='p_un01'));

INSERT INTO `base_student_guardian` (`org_id`,`student_id`,`guardian_id`,`is_primary`,`can_pickup`,`bind_status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),(SELECT g.id FROM base_guardian g WHERE g.org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND g.name='张爸爸'),1,1,1),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),(SELECT g.id FROM base_guardian g WHERE g.org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND g.name='李奶奶'),0,1,1),
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM base_student WHERE student_no='PS2017001'),(SELECT g.id FROM base_guardian g WHERE g.org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND g.name='陈妈妈'),1,0,1),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_student WHERE student_no='MS2025001'),(SELECT g.id FROM base_guardian g WHERE g.org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND g.name='吴爸爸'),1,0,1),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025001'),(SELECT g.id FROM base_guardian g WHERE g.org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND g.name='林妈妈'),1,0,1),
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM base_student WHERE student_no='VS2025001'),(SELECT g.id FROM base_guardian g WHERE g.org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND g.name='赵爸爸'),1,0,1),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT g.id FROM base_guardian g WHERE g.org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND g.name='王爸爸'),1,0,1);

INSERT INTO `base_student_health` (`org_id`,`student_id`,`allergy_history`,`disease_history`,`diet_taboo`,`sport_taboo`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),'花生过敏','无','忌花生制品','无'),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025003'),'粉尘过敏','哮喘史','无','剧烈运动禁忌'),
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM base_student WHERE student_no='PS2017002'),'无','无','无','无'),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_student WHERE student_no='MS2025002'),'青霉素过敏','无','无','中考体育备选项目：游泳'),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025001'),'无','无','无','无');


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
-- 11. 门禁设备（先于考勤/通行记录插入，供其引用）
-- ---------------------------------------------------------------------
INSERT INTO `sys_gate_device` (`org_id`,`device_code`,`device_name`,`device_type`,`model`,`vendor`,`location`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'DEV-KG01','阳光园大门闸机','gate','HIK-DS-K3Y411','海康威视','园区大门',1),
((SELECT id FROM sys_org WHERE org_code='PS01'),'DEV-PS01','明德小学校门闸机','gate','HIK-DS-K3Y411','海康威视','学校大门',1),
((SELECT id FROM sys_org WHERE org_code='MS01'),'DEV-MS01','启航初中校门闸机','face','ZKT-F7','中控智慧','学校大门',1),
((SELECT id FROM sys_org WHERE org_code='HS01'),'DEV-HS01','致远高中校门闸机','face','ZKT-F7','中控智慧','学校大门',1),
((SELECT id FROM sys_org WHERE org_code='VS01'),'DEV-VS01','精工职校实训楼门禁','door','HIK-DS-K1T804','海康威视','实训楼入口',1),
((SELECT id FROM sys_org WHERE org_code='UN01'),'DEV-UN01','华信大学东门闸机','gate','ZKT-SG55','中控智慧','东门',1);

-- ---------------------------------------------------------------------
-- 12. 考勤与请假（各学段代表数据：签到/签退/迟到/请假审批）
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
INSERT INTO `att_student_record` (`org_id`,`student_id`,`class_id`,`att_date`,`sign_in_time`,`sign_out_time`,`stay_minutes`,`sign_in_way`,`sign_out_way`,`device_id`,`device_name`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班'),'2025-09-08','2025-09-08 08:02:00','2025-09-08 17:05:00',543,'face','face',(SELECT id FROM sys_gate_device WHERE device_code='DEV-KG01'),'大门闸机','normal'),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025002'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班'),'2025-09-08','2025-09-08 08:25:00','2025-09-08 17:10:00',525,'face','card',(SELECT id FROM sys_gate_device WHERE device_code='DEV-KG01'),'大门闸机','late'),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025003'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班'),'2025-09-08',NULL,NULL,0,NULL,NULL,NULL,'','leave'),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025004'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班'),'2025-09-08','2025-09-08 08:00:00','2025-09-08 17:02:00',542,'card','card',(SELECT id FROM sys_gate_device WHERE device_code='DEV-KG01'),'大门闸机','normal'),
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM base_student WHERE student_no='PS2017001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班'),'2025-09-08','2025-09-08 07:45:00','2025-09-08 16:40:00',535,'card','card',(SELECT id FROM sys_gate_device WHERE device_code='DEV-PS01'),'校门闸机','normal'),
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM base_student WHERE student_no='PS2017002'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班'),'2025-09-08','2025-09-08 07:58:00','2025-09-08 16:35:00',517,'card','card',(SELECT id FROM sys_gate_device WHERE device_code='DEV-PS01'),'校门闸机','normal'),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_student WHERE student_no='MS2025001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班'),'2025-09-08','2025-09-08 07:10:00','2025-09-08 18:30:00',680,'face','face',(SELECT id FROM sys_gate_device WHERE device_code='DEV-MS01'),'校门闸机','normal'),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_student WHERE student_no='MS2025002'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班'),'2025-09-08','2025-09-08 07:35:00','2025-09-08 18:28:00',653,'face','face',(SELECT id FROM sys_gate_device WHERE device_code='DEV-MS01'),'校门闸机','late'),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='高一(1)班'),'2025-09-08','2025-09-08 06:50:00','2025-09-08 21:20:00',870,'face','face',(SELECT id FROM sys_gate_device WHERE device_code='DEV-HS01'),'校门闸机','normal'),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025002'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='高一(1)班'),'2025-09-08','2025-09-08 06:55:00','2025-09-08 21:15:00',860,'face','face',(SELECT id FROM sys_gate_device WHERE device_code='DEV-HS01'),'校门闸机','normal'),
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM base_student WHERE student_no='VS2025001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND class_name='数控技术1班'),'2025-09-08','2025-09-08 07:40:00','2025-09-08 17:30:00',590,'card','card',(SELECT id FROM sys_gate_device WHERE device_code='DEV-VS01'),'实训楼门禁','normal'),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023001'),NULL,'2025-09-08','2025-09-08 08:10:00','2025-09-08 12:00:00',230,'face','face',(SELECT id FROM sys_gate_device WHERE device_code='DEV-UN01'),'东门闸机','normal');

INSERT INTO `att_leave` (`org_id`,`student_id`,`leave_type`,`start_time`,`end_time`,`duration_hours`,`reason`,`apply_source`,`apply_by`,`approve_status`,`approve_by`,`approve_at`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025003'),'sick','2025-09-08 08:00:00','2025-09-08 17:00:00',9,'感冒发烧，在家休息','parent',(SELECT id FROM auth_user WHERE username='p_kg01'),'approved',(SELECT id FROM auth_user WHERE username='t_kg01'),'2025-09-07 20:00:00'),
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM base_student WHERE student_no='PS2017003'),'personal','2025-09-09 13:00:00','2025-09-09 17:00:00',4,'家中有事','parent',(SELECT id FROM auth_user WHERE username='p_ps01'),'pending',NULL,NULL),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_student WHERE student_no='MS2025004'),'sick','2025-09-08 08:00:00','2025-09-08 17:00:00',9,'肠胃不适','staff',(SELECT id FROM auth_user WHERE username='t_ms01'),'approved',(SELECT id FROM auth_user WHERE username='t_ms01'),'2025-09-08 07:30:00'),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025004'),'personal','2025-09-10 18:00:00','2025-09-10 21:00:00',3,'晚自习请假回家','parent',(SELECT id FROM auth_user WHERE username='p_hs01'),'pending',NULL,NULL);

-- ---------------------------------------------------------------------
-- 12. 门禁设备 / 通行权限 / 通行记录 / 预警 / 访客
-- ---------------------------------------------------------------------

INSERT INTO `gate_permission` (`org_id`,`person_type`,`person_id`,`permission`,`grant_mode`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'student',(SELECT id FROM base_student WHERE student_no='KG2025001'),'in_out','auto',1),
((SELECT id FROM sys_org WHERE org_code='KG01'),'guardian',(SELECT g.id FROM base_guardian g WHERE g.org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND g.name='张爸爸'),'in_out','auto',1),
((SELECT id FROM sys_org WHERE org_code='PS01'),'student',(SELECT id FROM base_student WHERE student_no='PS2017001'),'in_out','auto',1),
((SELECT id FROM sys_org WHERE org_code='MS01'),'student',(SELECT id FROM base_student WHERE student_no='MS2025001'),'in_out','auto',1),
((SELECT id FROM sys_org WHERE org_code='HS01'),'student',(SELECT id FROM base_student WHERE student_no='HS2025001'),'in_out','auto',1),
((SELECT id FROM sys_org WHERE org_code='VS01'),'student',(SELECT id FROM base_student WHERE student_no='VS2025001'),'area','auto',1),
((SELECT id FROM sys_org WHERE org_code='UN01'),'student',(SELECT id FROM base_student WHERE student_no='UN2023001'),'in_out','auto',1);

INSERT INTO `gate_pass_record` (`org_id`,`person_type`,`person_id`,`person_name`,`device_id`,`pass_time`,`direction`,`pass_way`,`result`,`fail_reason`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'student',(SELECT id FROM base_student WHERE student_no='KG2025001'),'张一一',(SELECT id FROM sys_gate_device WHERE device_code='DEV-KG01'),'2025-09-08 08:02:01','in','face','valid',''),
((SELECT id FROM sys_org WHERE org_code='KG01'),'stranger',NULL,'陌生人员',(SELECT id FROM sys_gate_device WHERE device_code='DEV-KG01'),'2025-09-08 10:11:23','in','face','invalid','非授权陌生人员'),
((SELECT id FROM sys_org WHERE org_code='PS01'),'student',(SELECT id FROM base_student WHERE student_no='PS2017001'),'陈小风',(SELECT id FROM sys_gate_device WHERE device_code='DEV-PS01'),'2025-09-08 07:45:02','in','card','valid',''),
((SELECT id FROM sys_org WHERE org_code='MS01'),'student',(SELECT id FROM base_student WHERE student_no='MS2025001'),'吴青',(SELECT id FROM sys_gate_device WHERE device_code='DEV-MS01'),'2025-09-08 07:10:03','in','face','valid',''),
((SELECT id FROM sys_org WHERE org_code='HS01'),'student',(SELECT id FROM base_student WHERE student_no='HS2025001'),'林志远',(SELECT id FROM sys_gate_device WHERE device_code='DEV-HS01'),'2025-09-08 21:20:10','out','face','valid',''),
((SELECT id FROM sys_org WHERE org_code='VS01'),'student',(SELECT id FROM base_student WHERE student_no='VS2025001'),'赵铁柱',(SELECT id FROM sys_gate_device WHERE device_code='DEV-VS01'),'2025-09-08 07:40:05','in','card','valid',''),
((SELECT id FROM sys_org WHERE org_code='UN01'),'student',(SELECT id FROM base_student WHERE student_no='UN2023001'),'王思睿',(SELECT id FROM sys_gate_device WHERE device_code='DEV-UN01'),'2025-09-08 08:10:02','in','face','valid','');

INSERT INTO `gate_alert` (`org_id`,`pass_record_id`,`alert_type`,`alert_level`,`content`,`notify_target`,`status`,`handled_by`,`handled_at`,`handle_note`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM gate_pass_record WHERE person_type='stranger' AND fail_reason='非授权陌生人员'),'stranger','error','陌生人员尝试刷脸入校被拦截','1',1,(SELECT id FROM auth_user WHERE username='t_kg01'),'2025-09-08 10:20:00','安保到场核验，系家长访客，已人工登记放行');

INSERT INTO `gate_visitor` (`org_id`,`name`,`phone`,`visit_purpose`,`interviewee_id`,`invite_by`,`visit_start`,`approve_status`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'设备巡检员','13810001111','门禁设备季度巡检',(SELECT id FROM auth_user WHERE username='admin_kg'),(SELECT id FROM auth_user WHERE username='admin_kg'),'2025-09-09 09:00:00','approved',0);

-- ---------------------------------------------------------------------
-- 13. 通知 / 消息 / 推送日志
-- ---------------------------------------------------------------------
INSERT INTO `msg_notice` (`org_id`,`notice_type`,`scope_type`,`title`,`content`,`publish_status`,`publisher_id`,`published_at`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'notice','org','开学温馨提示','请家长为幼儿准备备用衣物并贴好姓名贴。','published',(SELECT id FROM auth_user WHERE username='admin_kg'),'2025-09-01 09:00:00'),
((SELECT id FROM sys_org WHERE org_code='KG01'),'notice','class','小一班家长会通知','9月12日（周五）18:30 在一楼多功能厅召开家长会。','published',(SELECT id FROM auth_user WHERE username='t_kg01'),'2025-09-05 10:00:00'),
((SELECT id FROM sys_org WHERE org_code='PS01'),'notice','org','国庆假期安排','10月1日至7日放假，10月8日正常上课。','published',(SELECT id FROM auth_user WHERE username='admin_ps'),'2025-09-20 09:00:00'),
((SELECT id FROM sys_org WHERE org_code='MS01'),'security','org','校园防欺凌教育通知','本周五开展防欺凌主题班会，请家长配合教育。','published',(SELECT id FROM auth_user WHERE username='admin_ms'),'2025-09-10 09:00:00'),
((SELECT id FROM sys_org WHERE org_code='HS01'),'tips','org','高一年级选科说明','9月15日起开放新高考选科通道，详情见附件。','published',(SELECT id FROM auth_user WHERE username='admin_hs'),'2025-09-12 09:00:00'),
((SELECT id FROM sys_org WHERE org_code='VS01'),'notice','org','实训安全须知','进入实训场地须穿戴劳保用品，严禁违规操作。','published',(SELECT id FROM auth_user WHERE username='admin_vs'),'2025-09-01 08:30:00'),
((SELECT id FROM sys_org WHERE org_code='UN01'),'notice','org','奖助学金申请通知','2025-2026学年奖助学金申请通道已开启。','published',(SELECT id FROM auth_user WHERE username='admin_un'),'2025-09-10 09:00:00');

INSERT INTO `msg_message` (`org_id`,`sender_id`,`receiver_id`,`student_id`,`msg_type`,`content`,`is_read`,`read_at`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM auth_user WHERE username='p_kg01'),(SELECT id FROM auth_user WHERE username='t_kg01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),'text','王老师您好，张一一今天有点咳嗽，麻烦多关注，谢谢！',1,'2025-09-08 08:30:00'),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM auth_user WHERE username='t_kg01'),(SELECT id FROM auth_user WHERE username='p_kg01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),'text','收到！晨检时我会重点观察，请放心。',1,'2025-09-08 08:35:00');

-- ---------------------------------------------------------------------
-- 14. 收费项目 / 账单 / 缴费 / 财务日志（各学段代表项目）
-- ---------------------------------------------------------------------
INSERT INTO `fin_fee_item` (`org_id`,`item_code`,`item_name`,`fee_type`,`charge_cycle`,`default_amount`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'BYF','保教费','fixed','term',4500.00,1),
((SELECT id FROM sys_org WHERE org_code='KG01'),'HSF','伙食费','meal','month',600.00,1),
((SELECT id FROM sys_org WHERE org_code='PS01'),'KHFF','课后服务费','service','term',800.00,1),
((SELECT id FROM sys_org WHERE org_code='MS01'),'ZSF','住宿费','boarding','term',1200.00,1),
((SELECT id FROM sys_org WHERE org_code='MS01'),'YWF','延时服务费','service','term',500.00,1),
((SELECT id FROM sys_org WHERE org_code='HS01'),'XF','学费','tuition','term',9800.00,1),
((SELECT id FROM sys_org WHERE org_code='HS01'),'ZSF2','住宿费','boarding','term',1600.00,1),
((SELECT id FROM sys_org WHERE org_code='VS01'),'SXHC','实训耗材费','training','term',700.00,1),
((SELECT id FROM sys_org WHERE org_code='UN01'),'XUE','学年学费','tuition','year',12000.00,1),
((SELECT id FROM sys_org WHERE org_code='UN01'),'SU','住宿费','boarding','year',1500.00,1);

INSERT INTO `fin_bill` (`org_id`,`bill_no`,`student_id`,`class_id`,`fee_item_id`,`school_year_id`,`term_id`,`bill_amount`,`paid_amount`,`bill_status`,`due_date`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'B-KG-0001',(SELECT id FROM base_student WHERE student_no='KG2025001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班'),(SELECT id FROM fin_fee_item WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND item_code='BYF'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01')),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND term_no=1),4500.00,4500.00,'paid','2025-09-30'),
((SELECT id FROM sys_org WHERE org_code='KG01'),'B-KG-0002',(SELECT id FROM base_student WHERE student_no='KG2025002'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班'),(SELECT id FROM fin_fee_item WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND item_code='BYF'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01')),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND term_no=1),4500.00,1500.00,'partial','2025-09-30'),
((SELECT id FROM sys_org WHERE org_code='PS01'),'B-PS-0001',(SELECT id FROM base_student WHERE student_no='PS2017001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班'),(SELECT id FROM fin_fee_item WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND item_code='KHFF'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01')),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND term_no=1),800.00,800.00,'paid','2025-10-15'),
((SELECT id FROM sys_org WHERE org_code='MS01'),'B-MS-0001',(SELECT id FROM base_student WHERE student_no='MS2025001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班'),(SELECT id FROM fin_fee_item WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND item_code='ZSF'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01')),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND term_no=1),1200.00,0.00,'unpaid','2025-10-15'),
((SELECT id FROM sys_org WHERE org_code='HS01'),'B-HS-0001',(SELECT id FROM base_student WHERE student_no='HS2025001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='高一(1)班'),(SELECT id FROM fin_fee_item WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND item_code='XF'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01')),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND term_no=1),9800.00,9800.00,'paid','2025-09-25'),
((SELECT id FROM sys_org WHERE org_code='VS01'),'B-VS-0001',(SELECT id FROM base_student WHERE student_no='VS2025001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND class_name='数控技术1班'),(SELECT id FROM fin_fee_item WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND item_code='SXHC'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01')),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND term_no=1),700.00,0.00,'unpaid','2025-10-20'),
((SELECT id FROM sys_org WHERE org_code='UN01'),'B-UN-0001',(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND class_name='计算机2201班'),(SELECT id FROM fin_fee_item WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND item_code='XUE'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),NULL,12000.00,12000.00,'paid','2025-10-31'),
((SELECT id FROM sys_org WHERE org_code='UN01'),'B-UN-0002',(SELECT id FROM base_student WHERE student_no='UN2023002'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND class_name='计算机2201班'),(SELECT id FROM fin_fee_item WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND item_code='XUE'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),NULL,12000.00,12000.00,'paid','2025-10-31');

INSERT INTO `fin_payment` (`org_id`,`bill_id`,`student_id`,`pay_no`,`pay_type`,`pay_amount`,`pay_way`,`pay_time`,`operator_id`,`remark`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM fin_bill WHERE bill_no='B-KG-0001'),(SELECT id FROM base_student WHERE student_no='KG2025001'),'P-KG-0001','normal',4500.00,'wechat','2025-09-03 10:12:00',(SELECT id FROM auth_user WHERE username='admin_kg'),'保教费全缴'),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM fin_bill WHERE bill_no='B-KG-0002'),(SELECT id FROM base_student WHERE student_no='KG2025002'),'P-KG-0002','normal',1500.00,'alipay','2025-09-04 09:30:00',(SELECT id FROM auth_user WHERE username='admin_kg'),'首期缴费'),
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM fin_bill WHERE bill_no='B-PS-0001'),(SELECT id FROM base_student WHERE student_no='PS2017001'),'P-PS-0001','normal',800.00,'wechat','2025-09-08 11:00:00',(SELECT id FROM auth_user WHERE username='admin_ps'),''),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM fin_bill WHERE bill_no='B-HS-0001'),(SELECT id FROM base_student WHERE student_no='HS2025001'),'P-HS-0001','normal',9800.00,'bank','2025-09-15 15:40:00',(SELECT id FROM auth_user WHERE username='admin_hs'),'转账缴费'),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM fin_bill WHERE bill_no='B-UN-0001'),(SELECT id FROM base_student WHERE student_no='UN2023001'),'P-UN-0001','normal',12000.00,'bank','2025-09-20 09:15:00',(SELECT id FROM auth_user WHERE username='admin_un'),'学年学费'),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM fin_bill WHERE bill_no='B-UN-0002'),(SELECT id FROM base_student WHERE student_no='UN2023002'),'P-UN-0002','normal',12000.00,'wechat','2025-09-21 14:22:00',(SELECT id FROM auth_user WHERE username='admin_un'),'学年学费');


-- ---------------------------------------------------------------------
-- 15. 幼儿园专属：接送授权 / 接送记录 / 餐食 / 午休 / 活动 / 成长纪实
-- ---------------------------------------------------------------------
INSERT INTO `kind_pickup_authorization` (`org_id`,`student_id`,`guardian_id`,`pickup_type`,`apply_by`,`approve_status`,`approve_by`,`approve_at`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),(SELECT g.id FROM base_guardian g WHERE g.org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND g.name='张爸爸'),'fixed',(SELECT id FROM auth_user WHERE username='p_kg01'),'approved',(SELECT id FROM auth_user WHERE username='t_kg01'),'2025-09-01 10:00:00',1),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),(SELECT g.id FROM base_guardian g WHERE g.org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND g.name='李奶奶'),'fixed',(SELECT id FROM auth_user WHERE username='p_kg01'),'approved',(SELECT id FROM auth_user WHERE username='t_kg01'),'2025-09-01 10:00:00',1),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),NULL,'temp',(SELECT id FROM auth_user WHERE username='p_kg01'),'pending',NULL,NULL,1);

INSERT INTO `kind_pickup_record` (`org_id`,`student_id`,`guardian_id`,`auth_id`,`pickup_name`,`pickup_time`,`direction`,`verify_way`,`verify_result`,`device_id`,`is_alert`,`alert_note`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),(SELECT g.id FROM base_guardian g WHERE g.org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND g.name='张爸爸'),(SELECT id FROM kind_pickup_authorization WHERE pickup_type='fixed' AND guardian_id=(SELECT g.id FROM base_guardian g WHERE g.org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND g.name='张爸爸') LIMIT 1),'张爸爸','2025-09-08 17:05:30','out','face','passed',(SELECT id FROM sys_gate_device WHERE device_code='DEV-KG01'),0,''),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025004'),NULL,NULL,'赵妈妈','2025-09-08 17:20:00','out','manual','manual_verify',NULL,1,'临时接送人未预先授权，班主任核验证件后放行');

INSERT INTO `kind_meal` (`org_id`,`meal_date`,`meal_type`,`menu_content`,`photo`,`nutrition_note`,`taboo_note`,`publisher_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'2025-09-08','breakfast','牛奶、鸡蛋、奶黄包、苹果','','蛋白质+碳水均衡，含钙丰富','花生过敏幼儿（张一一）已单独替换点心',(SELECT id FROM auth_user WHERE username='t_kg01')),
((SELECT id FROM sys_org WHERE org_code='KG01'),'2025-09-08','lunch','米饭、番茄炒蛋、清蒸鱼、时蔬、冬瓜汤','','两荤一素一汤','鱼类过敏者已标注',(SELECT id FROM auth_user WHERE username='t_kg01')),
((SELECT id FROM sys_org WHERE org_code='KG01'),'2025-09-08','snack','酸奶、坚果','','下午加餐','坚果过敏者已替换为水果',(SELECT id FROM auth_user WHERE username='t_kg01'));

INSERT INTO `kind_nap_record` (`org_id`,`student_id`,`nap_date`,`sleep_minutes`,`nap_status`,`performance`,`recorder_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),'2025-09-08',95,'normal','入睡快，睡姿良好',(SELECT id FROM auth_user WHERE username='t_kg01')),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025002'),'2025-09-08',60,'difficult','入睡较慢，老师安抚后入睡',(SELECT id FROM auth_user WHERE username='t_kg01'));

INSERT INTO `kind_activity_record` (`org_id`,`class_id`,`activity_type`,`title`,`content`,`activity_date`,`publisher_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班'),'outdoor','户外游戏：小青蛙跳荷叶','锻炼幼儿下肢力量与平衡能力，幼儿参与积极。','2025-09-08',(SELECT id FROM auth_user WHERE username='t_kg01')),
((SELECT id FROM sys_org WHERE org_code='KG01'),NULL,'festival','中秋节手工活动','全园开展灯笼制作与月饼分享活动。','2025-09-26',(SELECT id FROM auth_user WHERE username='admin_kg'));

INSERT INTO `kind_growth_record` (`org_id`,`student_id`,`class_id`,`record_type`,`title`,`content`,`publisher_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班'),'performance','入园适应表现优秀','今天主动帮老师收玩具，语言表达清晰，情绪稳定。',(SELECT id FROM auth_user WHERE username='t_kg01')),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025003'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND class_name='小一班'),'comment','九月成长点评','本月社交能力进步明显，愿意与同伴分享玩具。',(SELECT id FROM auth_user WHERE username='t_kg01'));

-- ---------------------------------------------------------------------
-- 16. 幼儿园专属：晨午检 / 异常健康上报 / 安全巡查整改
-- ---------------------------------------------------------------------
INSERT INTO `kind_health_check` (`org_id`,`student_id`,`check_date`,`check_type`,`temperature`,`mental_state`,`hygiene`,`symptom`,`is_abnormal`,`recorder_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),'2025-09-08','morning',36.6,'normal','normal','',0,(SELECT id FROM auth_user WHERE username='t_kg01')),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025002'),'2025-09-08','morning',37.9,'tired','normal','低烧、轻微咳嗽',1,(SELECT id FROM auth_user WHERE username='t_kg01')),
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025001'),'2025-09-08','noon',36.5,'normal','normal','',0,(SELECT id FROM auth_user WHERE username='t_kg01'));

INSERT INTO `kind_health_abnormal` (`org_id`,`student_id`,`symptom`,`occurred_at`,`handle_measure`,`follow_note`,`status`,`reporter_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),(SELECT id FROM base_student WHERE student_no='KG2025002'),'低烧37.9℃、轻微咳嗽','2025-09-08 08:10:00','复测体温、通知家长接回就医','家长已接回，医嘱为普通感冒，建议居家观察1天','closed',(SELECT id FROM auth_user WHERE username='t_kg01'));

INSERT INTO `kind_safety_inspect` (`org_id`,`inspect_type`,`hazard_desc`,`location`,`risk_level`,`rectify_owner_id`,`rectify_deadline`,`rectify_evidence`,`status`,`reporter_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'facility','滑梯连接处螺丝松动','户外活动区','high',(SELECT id FROM auth_user WHERE username='admin_kg'),'2025-09-10','', 'assigned',(SELECT id FROM auth_user WHERE username='t_kg01')),
((SELECT id FROM sys_org WHERE org_code='KG01'),'device','南门摄像头画面模糊','南门岗亭','low',(SELECT id FROM auth_user WHERE username='admin_kg'),'2025-09-15','','rectified',(SELECT id FROM auth_user WHERE username='admin_kg'));


-- ---------------------------------------------------------------------
-- 17. 教务：课程 / 课表（小学/初中/普高）
-- ---------------------------------------------------------------------
INSERT INTO `edu_course` (`org_id`,`stage`,`grade_id`,`subject_code`,`course_name`,`course_type`,`periods_week`,`credit`,`assess_way`,`term_id`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='PS01'),'primary',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND grade_name='三年级'),'chinese','语文','required',7,0,'exam',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND term_no=1),1),
((SELECT id FROM sys_org WHERE org_code='PS01'),'primary',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND grade_name='三年级'),'math','数学','required',5,0,'exam',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND term_no=1),1),
((SELECT id FROM sys_org WHERE org_code='PS01'),'primary',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND grade_name='三年级'),'art','创意美术','club',2,0,'level',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND term_no=1),1),
((SELECT id FROM sys_org WHERE org_code='MS01'),'junior',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND grade_name='七年级'),'math','数学','required',6,0,'exam',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND term_no=1),1),
((SELECT id FROM sys_org WHERE org_code='MS01'),'junior',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND grade_name='七年级'),'english','英语','exam_core',5,0,'exam',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND term_no=1),1),
((SELECT id FROM sys_org WHERE org_code='HS01'),'senior',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_name='高一'),'physics','物理','gaokao',5,2,'exam',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND term_no=1),1),
((SELECT id FROM sys_org WHERE org_code='HS01'),'senior',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_name='高一'),'chemistry','化学','gaokao',4,2,'exam',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND term_no=1),1);

INSERT INTO `edu_schedule_plan` (`org_id`,`term_id`,`class_id`,`course_id`,`teacher_id`,`room`,`weekday`,`section_no`,`start_week`,`end_week`,`schedule_type`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND term_no=1),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班'),(SELECT id FROM edu_course WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND course_name='语文'),(SELECT id FROM base_teacher WHERE staff_no='TPS001'),'301教室',1,1,1,20,'normal',(SELECT id FROM auth_user WHERE username='admin_ps')),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND term_no=1),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班'),(SELECT id FROM edu_course WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND course_name='数学'),(SELECT id FROM base_teacher WHERE staff_no='TMS001'),'101教室',2,3,1,20,'normal',(SELECT id FROM auth_user WHERE username='admin_ms')),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND term_no=1),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='高一(1)班'),(SELECT id FROM edu_course WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND course_name='物理'),(SELECT id FROM base_teacher WHERE staff_no='THS001'),'物-201',3,2,1,20,'normal',(SELECT id FROM auth_user WHERE username='admin_hs'));

INSERT INTO `edu_teaching_record` (`org_id`,`class_id`,`course_id`,`teacher_id`,`teach_date`,`content`,`class_performance`,`attendance_note`) VALUES
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班'),(SELECT id FROM edu_course WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND course_name='语文'),(SELECT id FROM base_teacher WHERE staff_no='TPS001'),'2025-09-08','《秋天的雨》第一课时','课堂朗读积极，小组讨论有序','全班到齐');

-- ---------------------------------------------------------------------
-- 18. 考试与成绩（小学单元测 / 初中月考 / 普高模考）
-- ---------------------------------------------------------------------
INSERT INTO `exam_plan` (`org_id`,`exam_name`,`exam_type`,`term_id`,`grade_id`,`exam_date`,`total_score`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='PS01'),'三年级语文第一单元测试','unit',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND term_no=1),(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND grade_name='三年级'),'2025-09-25',100,'finished'),
((SELECT id FROM sys_org WHERE org_code='MS01'),'七年级9月月考','monthly',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND term_no=1),(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND grade_name='七年级'),'2025-09-28',120,'finished'),
((SELECT id FROM sys_org WHERE org_code='HS01'),'高一物理模考（一）','model',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND term_no=1),(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_name='高一'),'2025-09-27',100,'finished');

INSERT INTO `exam_subject` (`exam_id`,`subject_code`,`full_score`,`weight`) VALUES
((SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND exam_name='三年级语文第一单元测试'),'chinese',100,1.00),
((SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND exam_name='七年级9月月考'),'math',120,1.00),
((SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND exam_name='七年级9月月考'),'english',120,1.00),
((SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND exam_name='高一物理模考（一）'),'physics',100,1.00);

INSERT INTO `exam_score` (`org_id`,`exam_id`,`exam_subject_id`,`student_id`,`class_id`,`score`,`grade_level`,`class_rank`,`grade_rank`,`is_absent`,`entry_by`) VALUES
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND exam_name='三年级语文第一单元测试'),(SELECT id FROM exam_subject WHERE exam_id=(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND exam_name='三年级语文第一单元测试') AND subject_code='chinese'),(SELECT id FROM base_student WHERE student_no='PS2017001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班'),95,'A',1,3,0,(SELECT id FROM auth_user WHERE username='t_ps01')),
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND exam_name='三年级语文第一单元测试'),(SELECT id FROM exam_subject WHERE exam_id=(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND exam_name='三年级语文第一单元测试') AND subject_code='chinese'),(SELECT id FROM base_student WHERE student_no='PS2017002'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班'),88,'A',2,5,0,(SELECT id FROM auth_user WHERE username='t_ps01')),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND exam_name='七年级9月月考'),(SELECT id FROM exam_subject WHERE exam_id=(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND exam_name='七年级9月月考') AND subject_code='math'),(SELECT id FROM base_student WHERE student_no='MS2025001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班'),108,'A',1,8,0,(SELECT id FROM auth_user WHERE username='t_ms01')),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND exam_name='七年级9月月考'),(SELECT id FROM exam_subject WHERE exam_id=(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND exam_name='七年级9月月考') AND subject_code='math'),(SELECT id FROM base_student WHERE student_no='MS2025002'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班'),76,'C',3,45,0,(SELECT id FROM auth_user WHERE username='t_ms01')),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND exam_name='高一物理模考（一）'),(SELECT id FROM exam_subject WHERE exam_id=(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND exam_name='高一物理模考（一）') AND subject_code='physics'),(SELECT id FROM base_student WHERE student_no='HS2025001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='高一(1)班'),92,'A',1,6,0,(SELECT id FROM auth_user WHERE username='t_hs01')),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND exam_name='高一物理模考（一）'),(SELECT id FROM exam_subject WHERE exam_id=(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND exam_name='高一物理模考（一）') AND subject_code='physics'),(SELECT id FROM base_student WHERE student_no='HS2025002'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='高一(1)班'),61,'D',3,88,0,(SELECT id FROM auth_user WHERE username='t_hs01'));

-- ---------------------------------------------------------------------
-- 19. 学情支撑：薄弱点 / 学业预警 / 分层标注
-- ---------------------------------------------------------------------
INSERT INTO `edu_weak_point` (`org_id`,`student_id`,`subject_code`,`weak_desc`,`source_exam_id`,`improve_plan`,`status`,`created_by`) VALUES
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_student WHERE student_no='MS2025002'),'math','一元一次方程应用题失分严重',(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND exam_name='七年级9月月考'),'每日2道应用题专项训练，每周五检查','open',(SELECT id FROM auth_user WHERE username='t_ms01')),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025002'),'physics','牛顿第二定律受力分析薄弱',(SELECT id FROM exam_plan WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND exam_name='高一物理模考（一）'),'分层补差小组专项辅导','open',(SELECT id FROM auth_user WHERE username='t_hs01'));

INSERT INTO `edu_study_warning` (`org_id`,`student_id`,`warning_type`,`warning_level`,`content`,`notify_target`,`status`,`handled_by`,`handled_at`,`handle_note`) VALUES
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025002'),'model_fail','warn','物理模考61分，低于合格线，触发学业预警',CONCAT((SELECT id FROM auth_user WHERE username='p_hs01')),1,(SELECT id FROM auth_user WHERE username='t_hs01'),'2025-09-28 16:00:00','已与家长沟通，安排补差辅导');

INSERT INTO `edu_tier_student` (`org_id`,`student_id`,`term_id`,`tier_type`,`mark_line`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025001'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND term_no=1),'excellent','模考年级前10%',(SELECT id FROM auth_user WHERE username='t_hs01')),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025002'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND term_no=1),'weak','模考低于合格线',(SELECT id FROM auth_user WHERE username='t_hs01'));

-- ---------------------------------------------------------------------
-- 20. 德育：奖惩 / 班级考核 / 活动 / 谈心 / 综评
-- ---------------------------------------------------------------------
INSERT INTO `moral_score_rule` (`org_id`,`dimension`,`rule_name`,`score_value`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='PS01'),'discipline','课堂纪律表扬','2',1),
((SELECT id FROM sys_org WHERE org_code='PS01'),'hygiene','乱扔垃圾','-1',1),
((SELECT id FROM sys_org WHERE org_code='MS01'),'style','自习课专注表现优秀','3',1);

INSERT INTO `moral_record` (`org_id`,`student_id`,`class_id`,`record_type`,`dimension`,`score`,`reason`,`handle_result`,`recorder_id`,`occurred_at`) VALUES
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM base_student WHERE student_no='PS2017001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班'),'reward','discipline',2,'课堂纪律好，主动举手发言','班级表扬',(SELECT id FROM auth_user WHERE username='t_ps01'),'2025-09-08 15:00:00'),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_student WHERE student_no='MS2025004'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班'),'punish','discipline',-3,'课堂使用手机','口头警告并没收手机一天',(SELECT id FROM auth_user WHERE username='t_ms01'),'2025-09-09 10:00:00');

INSERT INTO `moral_class_eval` (`org_id`,`class_id`,`eval_period`,`period_start`,`period_end`,`discipline_score`,`hygiene_score`,`attendance_score`,`activity_score`,`study_style_score`,`total_score`,`rank_no`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班'),'week','2025-09-01','2025-09-07',18,19,20,15,16,88,2,(SELECT id FROM auth_user WHERE username='t_ms01'));

INSERT INTO `moral_activity` (`org_id`,`student_id`,`class_id`,`activity_type`,`title`,`content`,`activity_date`,`performance`,`recorder_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='PS01'),NULL,(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND class_name='三年级1班'),'class_meeting','主题班会：安全第一课','交通安全与校园安全教育，学生互动踊跃。','2025-09-05','整体表现良好',(SELECT id FROM auth_user WHERE username='t_ps01')),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_student WHERE student_no='MS2025001'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND class_name='七年级1班'),'volunteer','社区志愿服务','参与社区敬老志愿服务2小时。','2025-09-14','积极主动，获社区表扬',(SELECT id FROM auth_user WHERE username='t_ms01'));

INSERT INTO `moral_talk` (`org_id`,`student_id`,`talk_type`,`talk_content`,`student_state`,`follow_plan`,`is_key_student`,`talker_id`,`talked_at`) VALUES
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_student WHERE student_no='MS2025004'),'heart','针对课堂纪律问题谈心谈话','情绪平稳，认识到问题','下周继续观察课堂表现',0,(SELECT id FROM auth_user WHERE username='t_ms01'),'2025-09-09 16:30:00');

INSERT INTO `moral_comprehensive_eval` (`org_id`,`student_id`,`term_id`,`eval_standard`,`morality_score`,`study_score`,`health_score`,`art_score`,`practice_score`,`total_score`,`comment`,`eval_status`,`evaluator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='PS01'),(SELECT id FROM base_student WHERE student_no='PS2017001'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='PS01') AND term_no=1),'k12',92,95,90,88,85,450,'学习认真，乐于助人，是班级小干部。','settled',(SELECT id FROM auth_user WHERE username='t_ps01')),
((SELECT id FROM sys_org WHERE org_code='MS01'),(SELECT id FROM base_student WHERE student_no='MS2025001'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='MS01') AND term_no=1),'k12',90,93,88,86,90,447,'综合素质优秀，具备学生干部潜质。','settled',(SELECT id FROM auth_user WHERE username='t_ms01'));

-- ---------------------------------------------------------------------
-- 21. 普高专属：选科规则 / 学生选科 / 分层班级 / 走班成员 / 赋分规则 / 备考台账
-- ---------------------------------------------------------------------
INSERT INTO `high_selection_rule` (`org_id`,`grade_id`,`rule_mode`,`valid_combos`,`open_status`,`select_start`,`select_end`,`min_students`,`reselect_times`,`status`,`created_by`) VALUES
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_name='高一'),'3+1+2','["物化生","物化地","物政生","历政地","历生地"]',1,'2025-09-15 08:00:00','2025-10-15 20:00:00',20,1,1,(SELECT id FROM auth_user WHERE username='admin_hs'));

INSERT INTO `high_selection_choice` (`org_id`,`student_id`,`rule_id`,`combo_code`,`combo_detail`,`choice_round`,`status`,`audit_by`,`audit_at`) VALUES
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025001'),(SELECT id FROM high_selection_rule WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_id=(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_name='高一')),'物化生','物理+化学+生物',1,'confirmed',(SELECT id FROM auth_user WHERE username='t_hs01'),'2025-09-18 10:00:00'),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025002'),(SELECT id FROM high_selection_rule WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_id=(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_name='高一')),'物化地','物理+化学+地理',1,'confirmed',(SELECT id FROM auth_user WHERE username='t_hs01'),'2025-09-18 10:05:00'),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025003'),(SELECT id FROM high_selection_rule WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_id=(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_name='高一')),'历政地','历史+政治+地理',1,'pending',NULL,NULL),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025004'),(SELECT id FROM high_selection_rule WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_id=(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_name='高一')),'物化生','物理+化学+生物',1,'confirmed',(SELECT id FROM auth_user WHERE username='t_hs01'),'2025-09-18 10:10:00');

INSERT INTO `base_class` (`org_id`,`stage`,`grade_id`,`class_name`,`class_type`,`class_capacity`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='HS01'),'senior',(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND grade_name='高一'),'物化生走班A班','walk',30,1);

INSERT INTO `high_tier_class` (`org_id`,`class_id`,`tier_type`,`base_on`,`term_id`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='高一(1)班'),'parallel','入学成绩+第一次模考',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND term_no=1),(SELECT id FROM auth_user WHERE username='admin_hs'));

INSERT INTO `high_walk_class_member` (`org_id`,`walk_class_id`,`student_id`,`subject_code`,`term_id`,`status`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='物化生走班A班'),(SELECT id FROM base_student WHERE student_no='HS2025001'),'physics',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND term_no=1),1,(SELECT id FROM auth_user WHERE username='admin_hs')),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND class_name='物化生走班A班'),(SELECT id FROM base_student WHERE student_no='HS2025004'),'chemistry',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01') AND term_no=1),1,(SELECT id FROM auth_user WHERE username='admin_hs'));

INSERT INTO `high_score_conversion` (`org_id`,`subject_code`,`grade_band`,`rank_from`,`rank_to`,`score_from`,`score_to`) VALUES
((SELECT id FROM sys_org WHERE org_code='HS01'),'chemistry','A',0,15,86,100),
((SELECT id FROM sys_org WHERE org_code='HS01'),'chemistry','B',15,50,71,85),
((SELECT id FROM sys_org WHERE org_code='HS01'),'chemistry','C',50,85,56,70),
((SELECT id FROM sys_org WHERE org_code='HS01'),'chemistry','D',85,98,41,55),
((SELECT id FROM sys_org WHERE org_code='HS01'),'chemistry','E',98,100,30,40);

INSERT INTO `high_gaokao_prep` (`org_id`,`student_id`,`school_year_id`,`prep_plan`,`target_school`,`register_qualify`,`mock_summary`,`prep_status`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025001'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01')),'物理培优班+竞赛辅导','清华大学','unchecked','第一次模考物理92分，年级前10','preparing',(SELECT id FROM auth_user WHERE username='t_hs01')),
((SELECT id FROM sys_org WHERE org_code='HS01'),(SELECT id FROM base_student WHERE student_no='HS2025002'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='HS01')),'物理补差专项计划','北京工业大学','unchecked','第一次模考物理61分，需重点攻坚','preparing',(SELECT id FROM auth_user WHERE username='t_hs01'));


-- ---------------------------------------------------------------------
-- 22. 职高专属：专业 / 实训场地设备 / 实训计划记录 / 考证 / 校企 / 实习 / 就业
-- ---------------------------------------------------------------------
INSERT INTO `voc_major` (`org_id`,`major_code`,`major_name`,`major_direction`,`schooling_years`,`special_risk`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='VS01'),'SK01','数控技术应用','数控车床/加工中心操作',3,'机械加工实训须佩戴护目镜，严禁戴手套操作旋转设备',1);

UPDATE `base_class` SET `major_id`=(SELECT id FROM voc_major WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND major_code='SK01') WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND class_name='数控技术1班';

INSERT INTO `voc_training_site` (`org_id`,`site_code`,`site_name`,`major_id`,`capacity`,`location`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='VS01'),'SX01','数控实训车间',(SELECT id FROM voc_major WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND major_code='SK01'),40,'实训楼1层',1);

INSERT INTO `voc_training_device` (`org_id`,`site_id`,`device_code`,`device_name`,`device_model`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM voc_training_site WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND site_code='SX01'),'SK-CK6140-01','数控车床','CK6140','idle'),
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM voc_training_site WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND site_code='SX01'),'SK-VMC850-01','加工中心','VMC850','in_use'),
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM voc_training_site WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND site_code='SX01'),'SK-VMC850-02','加工中心','VMC850','maintenance');

INSERT INTO `voc_device_borrow` (`org_id`,`device_id`,`borrower_id`,`class_id`,`borrow_time`,`plan_return`,`status`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM voc_training_device WHERE device_code='SK-CK6140-01'),(SELECT id FROM auth_user WHERE username='t_vs01'),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND class_name='数控技术1班'),'2025-09-08 09:00:00','2025-09-08 17:00:00','returned',(SELECT id FROM auth_user WHERE username='t_vs01'));

INSERT INTO `voc_training_plan` (`org_id`,`term_id`,`class_id`,`major_id`,`project_name`,`content`,`teacher_id`,`site_id`,`start_date`,`end_date`) VALUES
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND term_no=1),(SELECT id FROM base_class WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND class_name='数控技术1班'),(SELECT id FROM voc_major WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND major_code='SK01'),'外圆车削实训','外圆车削基本操作与工艺参数设定',(SELECT id FROM base_teacher WHERE staff_no='TVS001'),(SELECT id FROM voc_training_site WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND site_code='SX01'),'2025-09-08','2025-09-12');

INSERT INTO `voc_training_record` (`org_id`,`plan_id`,`student_id`,`training_date`,`operation_note`,`operation_score`,`attendance`,`recorder_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM voc_training_plan WHERE project_name='外圆车削实训'),(SELECT id FROM base_student WHERE student_no='VS2025001'),'2025-09-08','完成工件外圆粗车与精车，表面粗糙度达标',92,'present',(SELECT id FROM auth_user WHERE username='t_vs01')),
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM voc_training_plan WHERE project_name='外圆车削实训'),(SELECT id FROM base_student WHERE student_no='VS2025002'),'2025-09-08','操作规范，但进给量设置偏大，已现场纠正',85,'present',(SELECT id FROM auth_user WHERE username='t_vs01')),
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM voc_training_plan WHERE project_name='外圆车削实训'),(SELECT id FROM base_student WHERE student_no='VS2025003'),'2025-09-08','加工流程完整，尺寸控制良好',90,'present',(SELECT id FROM auth_user WHERE username='t_vs01')),
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM voc_training_plan WHERE project_name='外圆车削实训'),(SELECT id FROM base_student WHERE student_no='VS2025004'),'2025-09-08','迟到10分钟，操作基本规范',80,'late',(SELECT id FROM auth_user WHERE username='t_vs01'));

INSERT INTO `voc_certificate` (`org_id`,`student_id`,`cert_name`,`cert_level`,`cert_org`,`exam_date`,`score`,`result`,`cert_no`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM base_student WHERE student_no='VS2025001'),'数控车工职业资格证','四级/中级','人力资源和社会保障局','2025-10-18',86,'passed','SK2025-0088',(SELECT id FROM auth_user WHERE username='t_vs01')),
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM base_student WHERE student_no='VS2025002'),'数控车工职业资格证','四级/中级','人力资源和社会保障局','2025-10-18',58,'failed','',(SELECT id FROM auth_user WHERE username='t_vs01'));

INSERT INTO `voc_company` (`org_id`,`company_name`,`qualification`,`coop_project`,`post_desc`,`mentor_name`,`mentor_phone`,`coop_start`,`coop_end`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='VS01'),'北京精工机械制造有限公司','ISO9001认证，校企合作基地','数控加工顶岗实习','数控操作工', '刘工','13810002222','2024-09-01','2027-08-31',1);

INSERT INTO `voc_internship` (`org_id`,`student_id`,`company_id`,`post_name`,`agreement_file`,`start_date`,`mentor_id`,`company_score`,`company_comment`,`intern_status`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM base_student WHERE student_no='VS2025001'),(SELECT id FROM voc_company WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND company_name LIKE '北京精工%'),'数控操作实习生','','2026-03-01',(SELECT id FROM base_teacher WHERE staff_no='TVS001'),NULL,'','reported',(SELECT id FROM auth_user WHERE username='t_vs01'));

INSERT INTO `voc_internship_checkin` (`org_id`,`internship_id`,`checkin_date`,`checkin_time`,`location`,`checkin_way`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM voc_internship WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND intern_status='reported'),'2026-03-02','2026-03-02 08:30:00','精工机械数控车间','app','on_duty');

INSERT INTO `voc_internship_report` (`org_id`,`internship_id`,`report_type`,`report_period`,`content`,`submitted_at`) VALUES
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM voc_internship WHERE org_id=(SELECT id FROM sys_org WHERE org_code='VS01') AND intern_status='reported'),'weekly','2026-W10','本周完成外圆加工实训任务，学习工艺卡片编制。','2026-03-08 18:00:00');

INSERT INTO `voc_employment` (`org_id`,`student_id`,`graduate_year`,`outcome_type`,`company_name`,`post_name`,`major_match`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='VS01'),(SELECT id FROM base_student WHERE student_no='VS2025001'),2028,'employed','北京精工机械制造有限公司','数控操作工','matched',(SELECT id FROM auth_user WHERE username='t_vs01'));


-- ---------------------------------------------------------------------
-- 23. 高校专属：院系 / 专业 / 培养方案 / 开课选课 / 成绩绩点
-- ---------------------------------------------------------------------
INSERT INTO `uni_department` (`org_id`,`dept_code`,`dept_name`,`leader_id`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),'CS','计算机学院',(SELECT id FROM base_teacher WHERE staff_no='TUN001'),1);

INSERT INTO `uni_major` (`org_id`,`dept_id`,`major_code`,`major_name`,`schooling_years`,`degree_type`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_department WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND dept_code='CS'),'080901','计算机科学与技术',4,'bachelor',1);

UPDATE `base_class` SET `department_id`=(SELECT id FROM uni_department WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND dept_code='CS'), `major_id`=(SELECT id FROM uni_major WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND major_code='080901') WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND class_name IN ('计算机2201班','计算机2204班');

INSERT INTO `uni_training_program` (`org_id`,`major_id`,`grade_id`,`program_name`,`min_credits`,`deduction_rule`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_major WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND major_code='080901'),(SELECT id FROM base_grade WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND grade_name='大二'),'计算机科学与技术2023级培养方案',160,'科创竞赛获奖可抵扣创新实践学分，最多4学分',1);

INSERT INTO `uni_program_course` (`program_id`,`course_code`,`course_name`,`course_type`,`credit`,`required_flag`,`advised_term`) VALUES
((SELECT id FROM uni_training_program WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND program_name LIKE '计算机科学与技术2023级%'),'CS201','数据结构','required',4,1,3),
((SELECT id FROM uni_training_program WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND program_name LIKE '计算机科学与技术2023级%'),'CS202','操作系统','required',4,1,4),
((SELECT id FROM uni_training_program WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND program_name LIKE '计算机科学与技术2023级%'),'CS301','人工智能导论','elective',2,0,5),
((SELECT id FROM uni_training_program WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND program_name LIKE '计算机科学与技术2023级%'),'PE102','大学体育（羽毛球）','public',1,0,3);

INSERT INTO `uni_course_offer` (`org_id`,`term_id`,`program_course_id`,`course_no`,`teacher_id`,`capacity`,`selected_count`,`select_start`,`select_end`,`class_hours`,`room`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),(SELECT id FROM uni_program_course WHERE course_code='CS201'),'CS201-01',(SELECT id FROM base_teacher WHERE staff_no='TUN001'),60,4,'2025-09-01 08:00:00','2025-09-10 18:00:00',64,'教学楼A301','open'),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),(SELECT id FROM uni_program_course WHERE course_code='CS301'),'CS301-01',(SELECT id FROM base_teacher WHERE staff_no='TUN001'),30,2,'2025-09-01 08:00:00','2025-09-10 18:00:00',32,'教学楼B202','open');

INSERT INTO `uni_course_select` (`org_id`,`student_id`,`offer_id`,`term_id`,`select_status`,`select_time`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM uni_course_offer WHERE course_no='CS201-01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),'selected','2025-09-03 09:00:00',(SELECT id FROM auth_user WHERE username='s_un001')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023002'),(SELECT id FROM uni_course_offer WHERE course_no='CS201-01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),'selected','2025-09-03 09:05:00',(SELECT id FROM auth_user WHERE username='s_un002')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023003'),(SELECT id FROM uni_course_offer WHERE course_no='CS201-01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),'selected','2025-09-03 09:10:00',(SELECT id FROM auth_user WHERE username='s_un003')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023004'),(SELECT id FROM uni_course_offer WHERE course_no='CS201-01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),'selected','2025-09-03 09:15:00',(SELECT id FROM auth_user WHERE username='s_un004')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM uni_course_offer WHERE course_no='CS301-01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),'selected','2025-09-03 10:00:00',(SELECT id FROM auth_user WHERE username='s_un001')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023002'),(SELECT id FROM uni_course_offer WHERE course_no='CS301-01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),'dropped','2025-09-06 14:00:00',(SELECT id FROM auth_user WHERE username='s_un002'));


-- ---------------------------------------------------------------------
-- 24. 高校专属：成绩绩点 / 综测 / 评奖 / 科创 / 社团 / 活动
-- ---------------------------------------------------------------------
INSERT INTO `uni_score` (`org_id`,`student_id`,`offer_id`,`term_id`,`usual_score`,`exam_score`,`practice_score`,`total_score`,`grade_point`,`credit`,`status`,`entry_by`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM uni_course_offer WHERE course_no='CS201-01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),95,88,90,91,4.0,4,'normal',(SELECT id FROM auth_user WHERE username='t_un01')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023002'),(SELECT id FROM uni_course_offer WHERE course_no='CS201-01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),80,72,85,78,2.8,4,'normal',(SELECT id FROM auth_user WHERE username='t_un01')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023003'),(SELECT id FROM uni_course_offer WHERE course_no='CS201-01'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),70,55,65,62,1.5,4,'makeup',(SELECT id FROM auth_user WHERE username='t_un01'));

INSERT INTO `uni_makeup_retake` (`org_id`,`student_id`,`score_id`,`apply_type`,`term_id`,`apply_status`,`new_score`,`new_credit`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023003'),(SELECT id FROM uni_score WHERE student_id=(SELECT id FROM base_student WHERE student_no='UN2023003') AND status='makeup'),'makeup',(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),'approved',70,4,(SELECT id FROM auth_user WHERE username='t_un01'));

INSERT INTO `uni_academic_warning` (`org_id`,`student_id`,`term_id`,`warning_type`,`warning_level`,`content`,`counselor_id`,`status`,`handle_note`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023003'),(SELECT id FROM base_term WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01') AND term_no=1),'fail','low','数据结构挂科，触发低年级学业预警',(SELECT id FROM base_teacher WHERE staff_no='TUN001'),1,'已安排补考，需重点跟进');

INSERT INTO `uni_eval_item` (`org_id`,`student_id`,`school_year_id`,`item_type`,`item_name`,`evidence_file`,`apply_score`,`audit_status`,`audit_by`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),'innovation','ACM校赛一等奖','',8,'approved',(SELECT id FROM auth_user WHERE username='t_un01')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023002'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),'volunteer','社区义务维修志愿服务20小时','',4,'approved',(SELECT id FROM auth_user WHERE username='t_un01'));

INSERT INTO `uni_comprehensive_eval` (`org_id`,`student_id`,`school_year_id`,`study_score`,`moral_score`,`innovation_score`,`sport_score`,`volunteer_score`,`practice_score`,`total_score`,`rank_no`,`audit_status`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),38,18,10,8,5,8,87,3,'settled'),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023002'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),34,17,2,9,6,7,75,26,'settled');

INSERT INTO `uni_scholarship` (`org_id`,`project_name`,`project_level`,`student_id`,`school_year_id`,`amount`,`status`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),'国家励志奖学金','nation',(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),5000,'approved',(SELECT id FROM auth_user WHERE username='admin_un'));

INSERT INTO `uni_innovation` (`org_id`,`student_id`,`tutor_id`,`project_type`,`project_name`,`progress_note`,`award_level`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM base_teacher WHERE staff_no='TUN001'),'innovation','基于深度学习的校园安防巡检系统','已完成需求分析与原型设计，进入开发阶段','','ongoing'),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023002'),(SELECT id FROM base_teacher WHERE staff_no='TUN001'),'competition','ACM国际大学生程序设计竞赛','校赛一等奖','校赛一等奖','awarded');

INSERT INTO `uni_club` (`org_id`,`club_name`,`club_type`,`leader_student_id`,`advisor_id`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),'ACM算法社','学术科技',(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM base_teacher WHERE staff_no='TUN001'),1),
((SELECT id FROM sys_org WHERE org_code='UN01'),'羽毛球协会','文体',(SELECT id FROM base_student WHERE student_no='UN2023002'),NULL,1);

INSERT INTO `uni_club_member` (`club_id`,`student_id`,`role`,`status`) VALUES
((SELECT id FROM uni_club WHERE club_name='ACM算法社'),(SELECT id FROM base_student WHERE student_no='UN2023001'),'leader',1),
((SELECT id FROM uni_club WHERE club_name='ACM算法社'),(SELECT id FROM base_student WHERE student_no='UN2023002'),'member',1),
((SELECT id FROM uni_club WHERE club_name='羽毛球协会'),(SELECT id FROM base_student WHERE student_no='UN2023002'),'leader',1);

INSERT INTO `uni_activity` (`org_id`,`club_id`,`activity_type`,`title`,`content`,`activity_date`,`recorder_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_club WHERE club_name='ACM算法社'),'club','ACM新生赛宣讲会','面向大一新生介绍竞赛规则与训练安排。','2025-09-20',(SELECT id FROM auth_user WHERE username='s_un001'));


-- ---------------------------------------------------------------------
-- 25. 高校专属：论文 / 答辩 / 学位预审 / 就业
-- ---------------------------------------------------------------------
INSERT INTO `uni_thesis` (`org_id`,`student_id`,`tutor_id`,`topic`,`stage`,`duplicate_rate`,`duplicate_pass`,`guide_note`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2021001'),(SELECT id FROM base_teacher WHERE staff_no='TUN001'),'基于微服务的校园综合管理平台设计','final',8.5,1,'已完成三轮修改，论文结构规范'),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2021002'),(SELECT id FROM base_teacher WHERE staff_no='TUN001'),'高校学生行为画像分析研究','final',12.3,1,'查重合格，进入答辩准备');

INSERT INTO `uni_thesis_defense` (`org_id`,`thesis_id`,`defense_type`,`defense_date`,`committee`,`score`,`result`,`opinion`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_thesis WHERE student_id=(SELECT id FROM base_student WHERE student_no='UN2021001')),'final','2026-06-10 09:00:00','王教授、李教授、沈导员',88,'passed','答辩通过，建议优化第三章实验对比',(SELECT id FROM auth_user WHERE username='t_un01')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_thesis WHERE student_id=(SELECT id FROM base_student WHERE student_no='UN2021002')),'final','2026-06-10 10:30:00','王教授、李教授、沈导员',76,'passed','答辩通过',(SELECT id FROM auth_user WHERE username='t_un01'));

INSERT INTO `uni_degree_precheck` (`org_id`,`student_id`,`check_year`,`credit_check`,`gpa_check`,`thesis_check`,`discipline_check`,`fee_check`,`overall_result`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2021001'),2026,'passed','passed','passed','passed','passed','degree_qualified',(SELECT id FROM auth_user WHERE username='t_un01')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2021002'),2026,'passed','passed','passed','passed','passed','degree_qualified',(SELECT id FROM auth_user WHERE username='t_un01'));

INSERT INTO `uni_employment` (`org_id`,`student_id`,`graduate_year`,`outcome_type`,`company_name`,`post_name`,`agreement_file`,`major_match`,`archive_transfer`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2021001'),2026,'signed','北京云图科技有限公司','后端开发工程师','','matched','processing',(SELECT id FROM auth_user WHERE username='t_un01')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2021002'),2026,'further_study','','','','matched','none',(SELECT id FROM auth_user WHERE username='t_un01'));

-- ---------------------------------------------------------------------
-- 26. 高校专属：宿舍 / 查寝 / 报修 / 卫生 / 健康体测
-- ---------------------------------------------------------------------
INSERT INTO `uni_dorm_building` (`org_id`,`building_code`,`building_name`,`dorm_type`,`floors`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),'DORM-03','3号学生公寓','undergrad',6,1);

INSERT INTO `uni_dorm_room` (`org_id`,`building_id`,`floor_no`,`room_no`,`bed_count`,`occupied_count`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_dorm_building WHERE building_code='DORM-03'),3,'301',4,4,1),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_dorm_building WHERE building_code='DORM-03'),3,'302',4,2,1);

INSERT INTO `uni_dorm_bed` (`org_id`,`room_id`,`bed_no`,`status`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_dorm_room WHERE room_no='301'),'301-1',2),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_dorm_room WHERE room_no='301'),'301-2',2),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_dorm_room WHERE room_no='301'),'301-3',2),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_dorm_room WHERE room_no='301'),'301-4',2),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_dorm_room WHERE room_no='302'),'302-1',2),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_dorm_room WHERE room_no='302'),'302-2',2);

INSERT INTO `uni_dorm_student` (`org_id`,`student_id`,`room_id`,`bed_id`,`school_year_id`,`assign_type`,`check_in_date`,`status`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM uni_dorm_room WHERE room_no='301'),(SELECT id FROM uni_dorm_bed WHERE bed_no='301-1'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),'auto','2025-09-01',1,(SELECT id FROM auth_user WHERE username='admin_un')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023002'),(SELECT id FROM uni_dorm_room WHERE room_no='301'),(SELECT id FROM uni_dorm_bed WHERE bed_no='301-2'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),'auto','2025-09-01',1,(SELECT id FROM auth_user WHERE username='admin_un')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023003'),(SELECT id FROM uni_dorm_room WHERE room_no='301'),(SELECT id FROM uni_dorm_bed WHERE bed_no='301-3'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),'auto','2025-09-01',1,(SELECT id FROM auth_user WHERE username='admin_un')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023004'),(SELECT id FROM uni_dorm_room WHERE room_no='301'),(SELECT id FROM uni_dorm_bed WHERE bed_no='301-4'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),'auto','2025-09-01',1,(SELECT id FROM auth_user WHERE username='admin_un')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2021001'),(SELECT id FROM uni_dorm_room WHERE room_no='302'),(SELECT id FROM uni_dorm_bed WHERE bed_no='302-1'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),'auto','2023-09-01',1,(SELECT id FROM auth_user WHERE username='admin_un')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2021002'),(SELECT id FROM uni_dorm_room WHERE room_no='302'),(SELECT id FROM uni_dorm_bed WHERE bed_no='302-2'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),'auto','2023-09-01',1,(SELECT id FROM auth_user WHERE username='admin_un'));

INSERT INTO `uni_dorm_check` (`org_id`,`student_id`,`room_id`,`check_date`,`check_type`,`status`,`note`,`is_alert`,`checker_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM uni_dorm_room WHERE room_no='301'),'2025-09-08','daily','present','',0,(SELECT id FROM auth_user WHERE username='t_un01')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023003'),(SELECT id FROM uni_dorm_room WHERE room_no='301'),'2025-09-08','night','late','23:40 才返回宿舍',1,(SELECT id FROM auth_user WHERE username='t_un01'));

INSERT INTO `uni_repair` (`org_id`,`room_id`,`applicant_id`,`repair_type`,`content`,`handler_id`,`status`,`finish_note`,`verify_by`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_dorm_room WHERE room_no='301'),(SELECT id FROM auth_user WHERE username='s_un001'),'aircon','宿舍空调不制冷',NULL,'finished','更换滤网并补充制冷剂',(SELECT id FROM auth_user WHERE username='s_un001')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_dorm_room WHERE room_no='302'),(SELECT id FROM auth_user WHERE username='s_un101'),'water','卫生间水龙头漏水',(SELECT id FROM auth_user WHERE username='admin_un'),'dispatched','',NULL);

INSERT INTO `uni_dorm_hygiene` (`org_id`,`room_id`,`check_date`,`hygiene_score`,`violation`,`rectify_note`,`checker_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_dorm_room WHERE room_no='301'),'2025-09-10',92,'','保持',(SELECT id FROM auth_user WHERE username='t_un01')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM uni_dorm_room WHERE room_no='302'),'2025-09-10',75,'发现违规使用电煮锅','没收并通报，限期整改',(SELECT id FROM auth_user WHERE username='t_un01'));

INSERT INTO `uni_health_record` (`org_id`,`student_id`,`school_year_id`,`record_type`,`height_cm`,`weight_kg`,`score`,`result_detail`,`is_abnormal`,`recorder_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),'fitness_test',178,68,82,'肺活量4100ml，50米7.2s',0,(SELECT id FROM auth_user WHERE username='t_un01')),
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023004'),(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),'physical_exam',165,50,0,'轻度贫血，建议营养科复查',1,(SELECT id FROM auth_user WHERE username='t_un01'));

-- ---------------------------------------------------------------------
-- 27. 财务减免（高校奖学金抵扣）与操作留痕样例
-- ---------------------------------------------------------------------
INSERT INTO `fin_reduction` (`org_id`,`student_id`,`bill_id`,`reduce_type`,`reduce_amount`,`school_year_id`,`audit_status`,`audit_by`,`audit_at`,`operator_id`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),(SELECT id FROM base_student WHERE student_no='UN2023001'),(SELECT id FROM fin_bill WHERE bill_no='B-UN-0001'),'scholarship',5000,(SELECT id FROM base_school_year WHERE org_id=(SELECT id FROM sys_org WHERE org_code='UN01')),'approved',(SELECT id FROM auth_user WHERE username='admin_un'),'2025-10-10 10:00:00',(SELECT id FROM auth_user WHERE username='admin_un'));

INSERT INTO `fin_ledger_log` (`org_id`,`action`,`target_table`,`target_id`,`bill_no`,`amount_before`,`amount_after`,`detail`,`operator_id`,`operator_name`) VALUES
((SELECT id FROM sys_org WHERE org_code='UN01'),'create','fin_bill',(SELECT id FROM fin_bill WHERE bill_no='B-UN-0001'),'B-UN-0001',NULL,12000.00,'生成学年学费账单',(SELECT id FROM auth_user WHERE username='admin_un'),'admin_un'),
((SELECT id FROM sys_org WHERE org_code='UN01'),'reduce','fin_reduction',(SELECT id FROM fin_reduction WHERE bill_id=(SELECT id FROM fin_bill WHERE bill_no='B-UN-0001')),'B-UN-0001',12000.00,7000.00,'国家励志奖学金抵扣5000元',(SELECT id FROM auth_user WHERE username='admin_un'),'admin_un');

-- ---------------------------------------------------------------------
-- 28. 系统运维样例：模块开关 / 操作日志 / 告警 / 登录日志
-- ---------------------------------------------------------------------
INSERT INTO `sys_org_module_switch` (`org_id`,`module_code`,`enabled`,`updated_by`) VALUES
((SELECT id FROM sys_org WHERE org_code='KG01'),'pickup',1,(SELECT id FROM auth_user WHERE username='superadmin')),
((SELECT id FROM sys_org WHERE org_code='KG01'),'meal',1,(SELECT id FROM auth_user WHERE username='superadmin')),
((SELECT id FROM sys_org WHERE org_code='KG01'),'exam',0,(SELECT id FROM auth_user WHERE username='superadmin')),
((SELECT id FROM sys_org WHERE org_code='HS01'),'selection',1,(SELECT id FROM auth_user WHERE username='superadmin'));

INSERT INTO `sys_log_operation` (`user_id`,`username`,`org_id`,`biz_type`,`action`,`target_table`,`target_id`,`ip`) VALUES
((SELECT id FROM auth_user WHERE username='superadmin'),'superadmin',(SELECT id FROM sys_org WHERE org_code='KG01'),'org','create','sys_org',(SELECT id FROM sys_org WHERE org_code='KG01'),'127.0.0.1'),
((SELECT id FROM auth_user WHERE username='admin_kg'),'admin_kg',(SELECT id FROM sys_org WHERE org_code='KG01'),'business','create','base_student',(SELECT id FROM base_student WHERE student_no='KG2025001'),'127.0.0.1'),
((SELECT id FROM auth_user WHERE username='superadmin'),'superadmin',(SELECT id FROM sys_org WHERE org_code='KG01'),'config','update','sys_org_module_switch',(SELECT id FROM sys_org_module_switch WHERE org_id=(SELECT id FROM sys_org WHERE org_code='KG01') AND module_code='exam'),'127.0.0.1');

INSERT INTO `sys_alert` (`alert_level`,`alert_type`,`module_code`,`title`,`content`,`org_id`,`status`,`handled_by`,`handled_at`,`handle_remark`,`occurred_at`) VALUES
('warn','device','gate','幼儿园门禁设备偶发离线','DEV-KG01 于 09-08 出现2次心跳超时，自动重连成功',(SELECT id FROM sys_org WHERE org_code='KG01'),2,(SELECT id FROM auth_user WHERE username='superadmin'),'2025-09-08 12:00:00','网络波动，设备已恢复在线，巡检正常','2025-09-08 11:30:00'),
('error','security','gate','陌生人员入校拦截','幼儿园大门陌生人员刷脸尝试入校被拦截',(SELECT id FROM sys_org WHERE org_code='KG01'),2,(SELECT id FROM auth_user WHERE username='superadmin'),'2025-09-08 10:25:00','安保已核验放行，已登记访客台账','2025-09-08 10:11:23');

INSERT INTO `sys_log_login` (`user_id`,`username`,`org_id`,`login_type`,`login_result`,`ip`,`login_at`) VALUES
((SELECT id FROM auth_user WHERE username='superadmin'),'superadmin',NULL,'password',1,'127.0.0.1','2025-09-01 08:00:00'),
((SELECT id FROM auth_user WHERE username='admin_kg'),'admin_kg',(SELECT id FROM sys_org WHERE org_code='KG01'),'password',1,'127.0.0.1','2025-09-08 08:00:00'),
((SELECT id FROM auth_user WHERE username='s_kg001'),'s_kg001',(SELECT id FROM sys_org WHERE org_code='KG01'),'password',1,'127.0.0.1','2025-09-08 08:05:00'),
((SELECT id FROM auth_user WHERE username='p_kg01'),'p_kg01',(SELECT id FROM sys_org WHERE org_code='KG01'),'password',0,'127.0.0.1','2025-09-08 08:06:00');