-- =====================================================================
-- 13_init_data.sql —— 初始化数据（仅基础字典/内置角色/模块注册/超管占位）
-- 对应文档：12.2 学段判定、12.3 金字塔六级角色、1.3.2 全局基础字典、
--           1.3.6 模块化功能启停
-- 安全须知：超级管理员占位账号 password_hash 为 '__INIT_REQUIRED__'，
--           必须由后端启动引导初始化强密码后方可登录（强制首登改密）。
--           本文件不预置任何机构/学生/收费等业务数据。
-- =====================================================================
USE `all_stage_edu`;

-- ---------------------------------------------------------------------
-- 1. 字典类型
-- ---------------------------------------------------------------------
INSERT INTO `sys_dict_type` (`type_code`,`type_name`,`is_frozen`,`remark`) VALUES
('stage','学段','1','学段判定唯一依据（机构绑定）'),
('student_status','学籍状态','1','在园(读)/休学/离园(校)/毕业/退学/注销'),
('guardian_relation','亲属关系','1','监护人关系'),
('leave_type','请假类型','1','事假/病假/年假/丧假/其他'),
('fee_type','收费类型','1','学费/固定/伙食/一次性/服务/住宿/资料/实训'),
('exam_type','考试类型','1','单元测/周测/月考/期中/期末/模考/联考/高考模拟/中考模拟/技能/考证'),
('moral_dimension','德育维度','1','纪律/卫生/礼仪/学习/劳动/安全/出勤/学风/课堂/仪容/实践'),
('post_type','岗位类型','1','班主任/任课/保育员/校医/行政/后勤/辅导员/专业教师/实训指导/导师/心理辅导'),
('subject_type','学科类型','1','语数英物化生政史地体音美等'),
('course_type','课程类型','1','必修/选修/社团/中考核心/高考学科/专业/实训/公共/实践'),
('att_status','考勤状态','1','正常/迟到/早退/缺勤/请假/未签退异常'),
('record_type','奖惩类型','1','奖励/违纪/整改/好人好事/文明表现'),
('notice_type','通知类型','1','普通通知/餐食公示/活动/安全教育/天气提醒/温馨提示'),
('device_type','门禁设备类型','1','闸机/门禁/人脸终端/刷卡器'),
('boarder_type','住宿类型','1','走读/寄宿'),
('alert_type','告警类型','1','接口/数据库/设备/登录/补丁/安全');

-- ---------------------------------------------------------------------
-- 2. 字典项（学段为 NULL 表示全学段通用）
-- ---------------------------------------------------------------------
INSERT INTO `sys_dict_item` (`type_code`,`item_code`,`item_name`,`stage`,`sort_no`) VALUES
('stage','kindergarten','幼儿园',NULL,1),
('stage','primary','小学',NULL,2),
('stage','junior','初中',NULL,3),
('stage','senior','普高',NULL,4),
('stage','vocational','职高',NULL,5),
('stage','university','大学',NULL,6),

('student_status','normal','在园/在读',NULL,1),
('student_status','suspended','休学',NULL,2),
('student_status','left','离园/离校',NULL,3),
('student_status','graduated','毕业',NULL,4),
('student_status','withdrawn','退学',NULL,5),
('student_status','deregistered','注销',NULL,6),

('guardian_relation','father','父亲',NULL,1),
('guardian_relation','mother','母亲',NULL,2),
('guardian_relation','grandfather','祖父/外祖父',NULL,3),
('guardian_relation','grandmother','祖母/外祖母',NULL,4),
('guardian_relation','other','其他',NULL,5),

('leave_type','personal','事假',NULL,1),
('leave_type','sick','病假',NULL,2),
('leave_type','annual','年假',NULL,3),
('leave_type','bereavement','丧假',NULL,4),
('leave_type','other','其他',NULL,5),

('fee_type','tuition','学费',NULL,1),
('fee_type','fixed','保教费/固定收费',NULL,2),
('fee_type','meal','伙食费（据实）',NULL,3),
('fee_type','one_time','杂费（一次性）',NULL,4),
('fee_type','service','课后服务费/延时服务',NULL,5),
('fee_type','boarding','住宿费/寄宿费',NULL,6),
('fee_type','material','教辅资料费',NULL,7),
('fee_type','training','实训耗材费',NULL,8),

('exam_type','unit','单元测',NULL,1),
('exam_type','weekly','周测',NULL,2),
('exam_type','monthly','月考',NULL,3),
('exam_type','midterm','期中',NULL,4),
('exam_type','final','期末',NULL,5),
('exam_type','model','模考',NULL,6),
('exam_type','union','联考',NULL,7),
('exam_type','mock','高考全真模拟',NULL,8),
('exam_type','zhongkao','中考全真模拟',NULL,9),
('exam_type','skill','技能实操考核',NULL,10),
('exam_type','cert','职业资格考证',NULL,11),

('moral_dimension','discipline','纪律',NULL,1),
('moral_dimension','hygiene','卫生',NULL,2),
('moral_dimension','etiquette','礼仪',NULL,3),
('moral_dimension','study','学习',NULL,4),
('moral_dimension','labor','劳动',NULL,5),
('moral_dimension','safety','安全',NULL,6),
('moral_dimension','attendance','出勤',NULL,7),
('moral_dimension','style','学风',NULL,8),
('moral_dimension','classroom','课堂',NULL,9),
('moral_dimension','dress','仪容仪表',NULL,10),
('moral_dimension','practice','劳动实践',NULL,11),

('post_type','head_teacher','班主任',NULL,1),
('post_type','subject_teacher','任课教师',NULL,2),
('post_type','life_teacher','保育员',NULL,3),
('post_type','nurse','校医',NULL,4),
('post_type','admin','行政人员',NULL,5),
('post_type','logistics','后勤人员',NULL,6),
('post_type','counselor','辅导员',NULL,7),
('post_type','major_teacher','专业任课教师',NULL,8),
('post_type','training_teacher','实训指导教师',NULL,9),
('post_type','tutor','导师',NULL,10),
('post_type','psychologist','心理辅导教师',NULL,11),

('subject_type','chinese','语文',NULL,1),
('subject_type','math','数学',NULL,2),
('subject_type','english','英语',NULL,3),
('subject_type','physics','物理',NULL,4),
('subject_type','chemistry','化学',NULL,5),
('subject_type','biology','生物',NULL,6),
('subject_type','politics','政治',NULL,7),
('subject_type','history','历史',NULL,8),
('subject_type','geography','地理',NULL,9),
('subject_type','pe','体育',NULL,10),
('subject_type','music','音乐',NULL,11),
('subject_type','art','美术',NULL,12),
('subject_type','it','信息技术',NULL,13),
('subject_type','major_course','专业课',NULL,14),
('subject_type','training','实训课',NULL,15),
('subject_type','other','其他/校本拓展',NULL,16),

('course_type','required','必修课',NULL,1),
('course_type','elective','选修课',NULL,2),
('course_type','club','社团拓展课',NULL,3),
('course_type','exam_core','中考核心学科',NULL,4),
('course_type','gaokao','高考学科',NULL,5),
('course_type','major','专业课',NULL,6),
('course_type','training','实训课',NULL,7),
('course_type','public','公共课',NULL,8),
('course_type','practice','实践课',NULL,9),

('att_status','normal','正常',NULL,1),
('att_status','late','迟到',NULL,2),
('att_status','early_leave','早退',NULL,3),
('att_status','absent','缺勤/旷工',NULL,4),
('att_status','leave','请假',NULL,5),
('att_status','skip','超时未签退（异常）',NULL,6),

('record_type','reward','奖励',NULL,1),
('record_type','punish','违纪',NULL,2),
('record_type','rectify','整改',NULL,3),
('record_type','good','好人好事',NULL,4),
('record_type','civilized','文明表现',NULL,5),

('notice_type','notice','普通通知',NULL,1),
('notice_type','meal','餐食公示',NULL,2),
('notice_type','activity','活动',NULL,3),
('notice_type','security','安全教育',NULL,4),
('notice_type','weather','天气提醒',NULL,5),
('notice_type','tips','温馨提示',NULL,6),

('device_type','gate','闸机',NULL,1),
('device_type','door','门禁',NULL,2),
('device_type','face','人脸终端',NULL,3),
('device_type','card','刷卡器',NULL,4),

('boarder_type','day','走读',NULL,1),
('boarder_type','boarding','寄宿',NULL,2),

('alert_type','interface','接口异常',NULL,1),
('alert_type','db','数据读写异常',NULL,2),
('alert_type','device','设备离线',NULL,3),
('alert_type','login','异常登录',NULL,4),
('alert_type','patch','补丁异常',NULL,5),
('alert_type','security','安全事件',NULL,6);

-- ---------------------------------------------------------------------
-- 3. 内置六级角色（金字塔六级角色权限体系）
-- ---------------------------------------------------------------------
INSERT INTO `sys_role` (`role_code`,`role_name`,`role_level`,`is_builtin`,`scope`,`description`) VALUES
('SUPER_ADMIN','超级开发者管理员',1,1,'platform','全局管控/机构入驻/底层配置/运维迭代/热补丁/全局告警接收'),
('SCHOOL_ADMIN','学校校级管理员',2,1,'org','本校全业务管理/师生管理/权限分配/数据统计'),
('TEACHER_STAFF','教职工/班主任',3,1,'org','班级管理/学情管理/考勤德育/通知发布/日常教务'),
('STUDENT','学生',4,1,'org','个人信息/学业查询/选课报名/校园服务/个人台账查看'),
('PARENT','家长',5,1,'org','仅查看绑定子女数据/接收通知/查看校园动态'),
('VISITOR','访客/临时角色',6,1,'org','仅临时阅览/预约入校权限');

-- ---------------------------------------------------------------------
-- 4. 功能模块注册（可插拔模块总清单，按文档各学段模块固化）
-- ---------------------------------------------------------------------
INSERT INTO `sys_module` (`module_code`,`module_name`,`stage_scope`,`is_plugin`,`default_on`,`sort_no`,`description`) VALUES
('base','基础档案（学生/师资/班级）','ALL',0,1,10,'全学段数据底座'),
('enrollment','学籍建档与异动','ALL',0,1,20,'学籍状态单向联动下游权限'),
('guardian','监护人绑定','ALL',0,1,30,'多监护人/紧急联系人/接送授权'),
('health','学生健康档案','ALL',1,1,40,'过敏/病史/体质禁忌，加密隔离'),
('attendance','考勤管理','ALL',0,1,50,'学生/教职工考勤与请假'),
('gate','门禁安防','ALL',1,1,60,'通行权限/通行记录/陌生拦截预警'),
('notice','通知公告','ALL',1,1,70,'全园(校)/班级分层通知，已读回执'),
('message','一对一消息','ALL',1,1,80,'家校私信/温馨提示'),
('fee','收费台账','ALL',1,1,90,'收费项目/账单/缴费/减免/财务日志'),
('pickup','幼儿接送安全','kindergarten',1,1,100,'接送白名单/临时接送/核验预警（幼儿园专属）'),
('meal','每日餐食公示','kindergarten',1,1,110,'餐食/营养/过敏禁忌提醒（幼儿园专属）'),
('growth','成长纪实','kindergarten',1,1,120,'午休/活动/成长相册（幼儿园专属）'),
('curriculum','课程与教学大纲','primary,junior,senior,vocational',1,1,130,'课程体系/课时学分标准'),
('schedule','智能排课','primary,junior,senior,vocational,university',1,1,140,'排课/调课/代课/补课'),
('teaching','教学纪实与资源库','primary,junior,senior,vocational,university',1,1,150,'教案课件沉淀/课堂记录'),
('exam','考试与成绩','primary,junior,senior,vocational,university',1,1,160,'考试建档/成绩/排名/学情'),
('analysis','学情分析与预警','junior,senior',1,1,170,'薄弱点/分层预警/培优补差'),
('moral','德育与班级考核','primary,junior,senior,vocational',1,1,180,'奖惩积分/班级量化/谈心心理'),
('comprehensive','综合素质评价','primary,junior,senior,vocational',1,1,190,'五维/六维过程性评价归档'),
('selection','新高考选科','senior',1,1,200,'3+1+2/3+3选科规则与确认（普高专属）'),
('tier','分层走班','senior',1,1,210,'培优/平行/基础分层与走班（普高专属）'),
('gaokao','高考备考与升学','senior',1,1,220,'模考/志愿/报名核验/升学去向（普高专属）'),
('major','专业分班','vocational',1,1,230,'专业方向/学制（职高专属）'),
('training','实训管理','vocational',1,1,240,'场地设备/实训计划/过程记录（职高专属）'),
('certificate','考证考级','vocational',1,1,250,'职业资格/等级证书（职高专属）'),
('internship','校企合作与顶岗实习','vocational',1,1,260,'企业备案/实习打卡/周月报（职高专属）'),
('employment','毕业就业','vocational,university',1,1,270,'就业去向/就业率台账'),
('credit','学分制选课绩点','university',1,1,280,'培养方案/选课/绩点GPA（高校专属）'),
('innovation','科创竞赛','university',1,1,290,'大创/竞赛/专利论文（高校专属）'),
('scholarship','综测评奖','university',1,1,300,'六维综测/奖学金/荣誉（高校专属）'),
('thesis','论文答辩与学位','university',1,1,310,'选题/查重/答辩/学位预审（高校专属）'),
('dorm','宿舍后勤','university',1,1,320,'住宿/查寝/报修/卫生评比（高校专属）'),
('gov_report','政务数据上报','ALL',1,0,330,'教育局/教育厅模板上报'),
('device','门禁硬件接入','ALL',0,1,340,'硬件设备全局适配');

-- ---------------------------------------------------------------------
-- 5. 超级管理员占位账号（安全：须初始化密码后方可登录）
-- ---------------------------------------------------------------------
INSERT INTO `auth_user` (
  `username`,`password_hash`,`real_name`,`user_type`,`org_id`,`campus_id`,`stage`,
  `gender`,`id_card`,`phone`,`email`,`avatar`,`status`,`must_change_pwd`,
  `open_channel`,`remark`,`created_by`
) VALUES (
  'superadmin','__INIT_REQUIRED__','平台超级管理员','super_admin',NULL,NULL,NULL,
  0,'','','', '',0,1,
  'manual','内置占位账号：password_hash 为占位值，后端启动引导必须初始化BCrypt强密码并将status置1，严禁以占位值登录'
  ,NULL
);

-- 绑定内置超级管理员角色
INSERT INTO `auth_user_role` (`user_id`,`role_id`,`org_id`,`scope_id`,`granted_by`,`status`)
SELECT u.id, r.id, NULL, NULL, u.id, 1
FROM `auth_user` u JOIN `sys_role` r
WHERE u.username='superadmin' AND r.role_code='SUPER_ADMIN';

-- ---------------------------------------------------------------------
-- 6. 全局底层参数初始化（系统核心冻结规则，超管可配置）
-- ---------------------------------------------------------------------
INSERT INTO `sys_global_param` (`param_group`,`param_key`,`param_value`,`value_type`,`is_platform_only`,`description`) VALUES
('login_security','token_expire_minutes','120','int',1,'登录时效（分钟）'),
('login_security','pwd_min_length','8','int',1,'密码最小长度'),
('login_security','pwd_complexity','strong','string',1,'密码复杂度：strong必须含大小写数字符号'),
('login_security','login_fail_lock_times','5','int',1,'连续登录失败锁定次数'),
('login_security','login_fail_lock_minutes','30','int',1,'失败锁定时长（分钟）'),
('crypto','sensitive_field_algo','AES-256-GCM','string',1,'敏感字段加密算法（应用层）'),
('api_limit','default_rate_limit','120','int',1,'接口默认限流（次/分钟）'),
('log_retention','operation_log_days','0','int',1,'操作日志留存天数（0=永久留存）'),
('push','push_channel_switch','system,sms,wechat','string',1,'全局推送渠道开关（逗号分隔）');
