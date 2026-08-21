import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/store/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/login/LoginView.vue'),
      meta: { title: '登录' }
    },
    {
      path: '/',
      component: () => import('@/layout/BasicLayout.vue'),
      redirect: '/dashboard',
      children: [
        {
          path: 'dashboard',
          name: 'Dashboard',
          component: () => import('@/views/dashboard/Dashboard.vue'),
          meta: { title: '数据看板' }
        },
        {
          path: 'base/student',
          name: 'StudentManage',
          component: () => import('@/views/base/StudentManage.vue'),
          meta: { title: '学生管理' }
        },
        {
          path: 'base/class',
          name: 'ClassManage',
          component: () => import('@/views/base/ClassManage.vue'),
          meta: { title: '班级架构' }
        },
        {
          path: 'base/teacher',
          name: 'TeacherManage',
          component: () => import('@/views/base/TeacherManage.vue'),
          meta: { title: '教师管理' }
        },
        {
          path: 'base/guardian',
          name: 'GuardianManage',
          component: () => import('@/views/base/GuardianManage.vue'),
          meta: { title: '监护人管理' }
        },
        {
          path: 'base/health',
          name: 'HealthManage',
          component: () => import('@/views/base/HealthManage.vue'),
          meta: { title: '健康档案' }
        },
        {
          path: 'base/enrollment',
          name: 'EnrollmentManage',
          component: () => import('@/views/base/EnrollmentManage.vue'),
          meta: { title: '学籍异动' }
        },
        {
          path: 'platform/org',
          name: 'OrgManage',
          component: () => import('@/views/platform/OrgManage.vue'),
          meta: { title: '机构管理' }
        },
        {
          path: 'platform/dict',
          name: 'DictManage',
          component: () => import('@/views/platform/DictManage.vue'),
          meta: { title: '字典管理' }
        },
        {
          path: 'platform/module',
          name: 'ModuleSwitch',
          component: () => import('@/views/platform/ModuleSwitch.vue'),
          meta: { title: '模块开关' }
        },
        {
          path: 'platform/log',
          name: 'OperationLog',
          component: () => import('@/views/platform/OperationLog.vue'),
          meta: { title: '操作日志' }
        },
        {
          path: 'platform/alert',
          name: 'AlertCenter',
          component: () => import('@/views/platform/AlertCenter.vue'),
          meta: { title: '告警中心' }
        },
        {
          path: 'platform/security',
          name: 'SysSecurity',
          component: () => import('@/views/platform/SysSecurity.vue'),
          meta: { title: '安全管控' }
        },
        {
          path: 'platform/ops',
          name: 'OpsManage',
          component: () => import('@/views/platform/OpsManage.vue'),
          meta: { title: '运维中心' }
        },
        {
          path: 'att',
          name: 'AttManage',
          component: () => import('@/views/biz/AttManage.vue'),
          meta: { title: '考勤管理' }
        },
        {
          path: 'gate',
          name: 'GateManage',
          component: () => import('@/views/biz/GateManage.vue'),
          meta: { title: '门禁通行' }
        },
        {
          path: 'fin',
          name: 'FinManage',
          component: () => import('@/views/biz/FinManage.vue'),
          meta: { title: '收费台账' }
        },
        {
          path: 'msg',
          name: 'NoticeManage',
          component: () => import('@/views/biz/NoticeManage.vue'),
          meta: { title: '通知发布' }
        },
        {
          path: 'kind',
          name: 'KindManage',
          component: () => import('@/views/kind/KindManage.vue'),
          meta: { title: '幼儿园专属' }
        },
        {
          path: 'k12/edu',
          name: 'EduManage',
          component: () => import('@/views/k12/EduManage.vue'),
          meta: { title: '教务教学' }
        },
        {
          path: 'k12/moral',
          name: 'MoralManage',
          component: () => import('@/views/k12/MoralManage.vue'),
          meta: { title: '德育综评' }
        },
        {
          path: 'senior',
          name: 'SeniorManage',
          component: () => import('@/views/stage/SeniorManage.vue'),
          meta: { title: '新高考选科' }
        },
        {
          path: 'voc',
          name: 'VocManage',
          component: () => import('@/views/stage/VocManage.vue'),
          meta: { title: '职高实训' }
        },
        {
          path: 'uni',
          name: 'UniManage',
          component: () => import('@/views/stage/UniManage.vue'),
          meta: { title: '高校管理' }
        },
        {
          path: 'platform/open',
          name: 'AccountOpen',
          component: () => import('@/views/platform/AccountOpen.vue'),
          meta: { title: '账号开通' }
        },
        {
          path: 'platform/role',
          name: 'RolePerm',
          component: () => import('@/views/platform/RolePerm.vue'),
          meta: { title: '角色权限' }
        },
        {
          path: 'platform/campus',
          name: 'CampusManage',
          component: () => import('@/views/platform/CampusManage.vue'),
          meta: { title: '校区管理' }
        },
        {
          path: 'platform/param',
          name: 'ParamManage',
          component: () => import('@/views/platform/ParamManage.vue'),
          meta: { title: '全局参数' }
        },
        {
          path: 'platform/device',
          name: 'DeviceManage',
          component: () => import('@/views/platform/DeviceManage.vue'),
          meta: { title: '门禁硬件' }
        },
        {
          path: 'platform/version',
          name: 'VersionManage',
          component: () => import('@/views/platform/VersionManage.vue'),
          meta: { title: '版本热补丁' }
        },
        {
          path: 'platform/api',
          name: 'ApiManage',
          component: () => import('@/views/platform/ApiManage.vue'),
          meta: { title: 'API网关' }
        }
      ]
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/dashboard'
    }
  ]
})

router.beforeEach((to) => {
  const auth = useAuthStore()
  document.title = (to.meta.title ? to.meta.title + ' - ' : '') + '全学段一站式学生综合管理系统'
  if (to.path !== '/login' && !auth.isLogin) {
    return { path: '/login' }
  }
  if (to.path === '/login' && auth.isLogin) {
    return { path: '/dashboard' }
  }
})

export default router