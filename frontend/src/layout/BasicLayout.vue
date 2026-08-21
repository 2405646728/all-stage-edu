<template>
  <el-container class="layout">
    <!-- 顶部主导航（文档 1.2.3：一级核心功能置顶横向展示） -->
    <el-header class="topbar">
      <div class="brand">
        <div class="brand-logo">E</div>
        <div class="brand-text">
          <div class="brand-title">全学段教育云</div>
          <div class="brand-sub">{{ stageName }}</div>
        </div>
      </div>
      <el-menu mode="horizontal" :default-active="activeTop" class="top-menu" router :ellipsis="false" @select="onTopSelect">
        <el-menu-item index="/dashboard">数据看板</el-menu-item>
        <el-menu-item v-if="auth.isSuperAdmin" index="platform">平台管控</el-menu-item>
        <el-menu-item v-if="!auth.isSuperAdmin" index="base">基础档案</el-menu-item>
        <el-menu-item v-if="!auth.isSuperAdmin" index="common">通用业务</el-menu-item>
        <el-menu-item v-if="stageKey" :index="stageKey">{{ stageMenuName }}</el-menu-item>
      </el-menu>
      <div class="topbar-right">
        <el-input v-model="menuKeyword" placeholder="搜索菜单…" clearable size="small" class="menu-search" :prefix-icon="Search" @input="onSearch">
        </el-input>
        <el-dropdown @command="onCommand">
          <span class="user-chip">
            <el-avatar :size="28" class="user-avatar">{{ (auth.user?.realName || '?').slice(0, 1) }}</el-avatar>
            <span class="user-name">{{ auth.user?.realName }}</span>
            <el-icon><ArrowDown /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="pwd">修改密码</el-dropdown-item>
              <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </el-header>
    <el-container class="body">
      <!-- 侧边二级折叠菜单（可收纳/折叠） -->
      <el-aside :width="collapsed ? '64px' : '210px'" class="aside">
        <div class="aside-head">
          <span v-if="!collapsed">{{ currentTopName }}</span>
          <el-icon class="fold-btn" @click="collapsed = !collapsed"><Expand v-if="collapsed" /><Fold v-else /></el-icon>
        </div>
        <el-scrollbar class="aside-scroll">
          <el-menu :default-active="route.path" router :collapse="collapsed" :collapse-transition="false" class="side-menu">
            <template v-for="item in filteredSideMenus" :key="item.path">
              <el-menu-item v-if="!item.children" :index="item.path">
                <el-icon><component :is="item.icon" /></el-icon>
                <template #title>{{ item.title }}</template>
              </el-menu-item>
              <el-sub-menu v-else :index="item.path">
                <template #title>
                  <el-icon><component :is="item.icon" /></el-icon>
                  <span>{{ item.title }}</span>
                </template>
                <el-menu-item v-for="c in item.children" :key="c.path" :index="c.path">{{ c.title }}</el-menu-item>
              </el-sub-menu>
            </template>
          </el-menu>
        </el-scrollbar>
      </el-aside>
      <el-main class="main">
        <router-view />
      </el-main>
    </el-container>

    <!-- 修改密码弹窗（首登强制 + 手动） -->
    <el-dialog v-model="pwdDlg.visible" title="修改密码" width="420px" :close-on-click-modal="false" :show-close="!auth.user?.mustChangePwd" append-to-body>
      <el-alert v-if="auth.user?.mustChangePwd" type="warning" :closable="false" show-icon title="首次登录须修改初始密码后才能继续使用" style="margin-bottom: 14px" />
      <el-form label-width="80px">
        <el-form-item label="原密码"><el-input v-model="pwdDlg.form.oldPassword" type="password" show-password /></el-form-item>
        <el-form-item label="新密码"><el-input v-model="pwdDlg.form.newPassword" type="password" show-password placeholder="至少 8 位" /></el-form-item>
        <el-form-item label="确认密码"><el-input v-model="pwdDlg.form.confirm" type="password" show-password /></el-form-item>
      </el-form>
      <template #footer>
        <el-button v-if="!auth.user?.mustChangePwd" @click="pwdDlg.visible = false">取消</el-button>
        <el-button type="primary" :loading="pwdDlg.saving" @click="submitPwd">确认修改</el-button>
      </template>
    </el-dialog>
  </el-container>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Search, ArrowDown, Expand, Fold, DataBoard, Setting, User, DataLine, Cherry, Reading, Compass, Tools, School, Grid } from '@element-plus/icons-vue'
import { useAuthStore } from '@/store/auth'
import { changePwdApi } from '@/api/auth'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const collapsed = ref(false)
const menuKeyword = ref('')
const activeTop = ref('')
// 当前顶部选中的一级模块（侧边栏跟随；/dashboard 等首页按角色兜底展示一级菜单）
const topKey = ref('')

const STAGE_NAMES: Record<string, string> = {
  kindergarten: '幼儿园', primary: '小学', junior: '初中', senior: '普高', vocational: '职高', university: '大学'
}
const stageName = computed(() => auth.isSuperAdmin ? '平台超级管理员' : (STAGE_NAMES[auth.user?.stage || ''] || '未知学段'))
const stageKey = computed(() => auth.isSuperAdmin ? '' : auth.user?.stage || '')
const stageMenuName = computed(() => {
  const s = auth.user?.stage
  return s === 'kindergarten' ? '幼儿园专属' : s === 'senior' ? '新高考选科' : s === 'vocational' ? '职高实训' : s === 'university' ? '高校管理' : '教务德育'
})

// 二级菜单定义（按角色/学段差异化渲染，文档 12.2/12.3）
const sideMenus: Record<string, any[]> = {
  platform: [
    { path: '/platform/org', title: '机构管理', icon: 'OfficeBuilding' },
    { path: '/platform/open', title: '账号开通', icon: 'UserFilled' },
    { path: '/platform/dict', title: '字典管理', icon: 'Collection' },
    { path: '/platform/module', title: '模块开关', icon: 'Switch' },
    { path: '/platform/role', title: '角色权限', icon: 'Lock' },
    { path: '/platform/campus', title: '校区管理', icon: 'Location' },
    { path: '/platform/param', title: '全局参数', icon: 'Setting' },
    { path: '/platform/device', title: '门禁硬件', icon: 'Cpu' },
    { path: '/platform/version', title: '版本热补丁', icon: 'Refresh' },
    { path: '/platform/api', title: 'API 网关', icon: 'Connection' },
    { path: '/platform/security', title: '安全管控', icon: 'Warning' },
    { path: '/platform/ops', title: '运维中心', icon: 'FolderOpened' },
    { path: '/platform/log', title: '操作日志', icon: 'Document' },
    { path: '/platform/alert', title: '告警中心', icon: 'Bell' }
  ],
  base: [
    { path: '/base/student', title: '学生管理', icon: 'User' },
    { path: '/base/class', title: '班级架构', icon: 'Grid' },
    { path: '/base/teacher', title: '教师管理', icon: 'Avatar' },
    { path: '/base/guardian', title: '监护人管理', icon: 'Phone' },
    { path: '/base/health', title: '健康档案', icon: 'FirstAidKit' },
    { path: '/base/enrollment', title: '学籍异动', icon: 'Refresh' }
  ],
  common: [
    { path: '/att', title: '考勤管理', icon: 'AlarmClock' },
    { path: '/gate', title: '门禁通行', icon: 'Lock' },
    { path: '/msg', title: '通知发布', icon: 'ChatDotRound' },
    { path: '/fin', title: '收费台账', icon: 'Money' }
  ],
  kindergarten: [{ path: '/kind', title: '幼儿园专属管理', icon: 'Cherry' }],
  senior: [{ path: '/senior', title: '新高考选科走班', icon: 'Compass' }],
  vocational: [{ path: '/voc', title: '职高实训就业', icon: 'Tools' }],
  university: [{ path: '/uni', title: '高校管理', icon: 'School' }],
  k12: [
    { path: '/k12/edu', title: '教务教学', icon: 'Reading' },
    { path: '/k12/moral', title: '德育综评', icon: 'Medal' }
  ]
}

const currentTopName = computed(() => {
  const k = topKey.value
  const names: Record<string, string> = { platform: '平台管控', base: '基础档案', common: '通用业务', kindergarten: '幼儿园专属', senior: '新高考选科', vocational: '职高实训', university: '高校管理', k12: '教务德育' }
  return names[k] || '菜单'
})

const sideList = computed(() => {
  const k = topKey.value
  if (k === 'k12') return sideMenus.k12
  return sideMenus[k] || []
})

// 首页/未知路径时的兜底一级模块：超管->平台管控，校管->按学段
function defaultTopKey() {
  if (auth.isSuperAdmin) return 'platform'
  const s = auth.user?.stage
  if (s === 'kindergarten' || s === 'senior' || s === 'vocational' || s === 'university') return s
  return 'k12'
}

function inferTopKey(path: string) {
  if (path.startsWith('/platform')) return 'platform'
  if (path.startsWith('/base')) return 'base'
  if (['/att', '/gate', '/msg', '/fin'].includes(path)) return 'common'
  if (path.startsWith('/k12')) return 'k12'
  if (path.startsWith('/kind')) return 'kindergarten'
  if (path.startsWith('/senior')) return 'senior'
  if (path.startsWith('/voc')) return 'vocational'
  if (path.startsWith('/uni')) return 'university'
  return defaultTopKey()
}

const filteredSideMenus = computed(() => {
  const kw = menuKeyword.value.trim()
  if (!kw) return sideList.value
  return sideList.value.filter((m) => m.title.includes(kw) || (m.children || []).some((c: any) => c.title.includes(kw)))
})

function onTopSelect(index: string) {
  if (index.startsWith('/')) {
    if (index === '/dashboard') topKey.value = defaultTopKey()
    router.push(index)
  } else {
    topKey.value = index
    // 点击一级模块后定位到其第一个菜单页面
    const first = (sideMenus[index] || [])[0]
    if (first) router.push(first.path)
  }
}
function onSearch() { /* 过滤已由 computed 驱动 */ }

const pwdDlg = reactive({ visible: false, saving: false, form: { oldPassword: '', newPassword: '', confirm: '' } })

async function submitPwd() {
  if (pwdDlg.form.newPassword.length < 8) { ElMessage.warning('新密码至少 8 位'); return }
  if (pwdDlg.form.newPassword !== pwdDlg.form.confirm) { ElMessage.warning('两次输入的新密码不一致'); return }
  pwdDlg.saving = true
  try {
    await changePwdApi({ oldPassword: pwdDlg.form.oldPassword, newPassword: pwdDlg.form.newPassword })
    ElMessage.success('密码修改成功，请重新登录')
    pwdDlg.visible = false
    await auth.logout()
    router.push('/login')
  } finally {
    pwdDlg.saving = false
  }
}

async function onCommand(cmd: string) {
  if (cmd === 'logout') { await auth.logout(); router.push('/login') }
  if (cmd === 'pwd') { pwdDlg.form = { oldPassword: '', newPassword: '', confirm: '' }; pwdDlg.visible = true }
}

// 首登强制改密
watch(() => auth.user?.mustChangePwd, (v) => { if (v) { pwdDlg.visible = true } }, { immediate: true })
watch(() => route.path, (p) => {
  topKey.value = inferTopKey(p)
  activeTop.value = p.startsWith('/dashboard') ? '/dashboard' : topKey.value
}, { immediate: true })
</script>

<style scoped>
.layout { height: 100vh; }
.topbar { height: 60px; display: flex; align-items: center; gap: 18px; background: #fff; border-bottom: 1px solid #e8ecf1; padding: 0 16px; }
.brand { display: flex; align-items: center; gap: 10px; min-width: 190px; }
.brand-logo { width: 34px; height: 34px; border-radius: 8px; background: linear-gradient(135deg, #1f6feb, #3a9bff); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 18px; }
.brand-title { font-size: 15px; font-weight: 600; color: #1f2d3d; line-height: 1.2; }
.brand-sub { font-size: 11px; color: #8492a6; line-height: 1.2; }
.top-menu { border-bottom: none; flex: 1; }
.topbar-right { display: flex; align-items: center; gap: 12px; }
.menu-search { width: 180px; }
.user-chip { display: flex; align-items: center; gap: 8px; cursor: pointer; }
.user-avatar { background: linear-gradient(135deg, #1f6feb, #3a9bff); color: #fff; }
.user-name { font-size: 13px; color: #333; }
.body { flex: 1; overflow: hidden; }
.aside { background: #fff; border-right: 1px solid #e8ecf1; transition: width .2s; }
.aside-head { height: 44px; display: flex; align-items: center; justify-content: space-between; padding: 0 14px; font-size: 13px; font-weight: 600; color: #5a6a7a; border-bottom: 1px solid #f0f2f5; }
.fold-btn { cursor: pointer; font-size: 16px; color: #8492a6; }
.aside-scroll { height: calc(100% - 44px); }
.side-menu { border-right: none; }
.main { padding: 16px; overflow: auto; background: #f5f7fa; }
</style>