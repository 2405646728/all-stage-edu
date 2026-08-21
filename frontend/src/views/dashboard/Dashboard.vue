<template>
  <div class="dashboard">
    <!-- 顶部：核心数据卡片（自适应） -->
    <el-row :gutter="14">
      <el-col :xs="12" :sm="12" :md="6" v-for="card in cards" :key="card.title">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-body">
            <div class="stat-icon" :style="{ background: card.bg }"><el-icon :size="22"><component :is="card.icon" /></el-icon></div>
            <div class="stat-info">
              <div class="stat-value">{{ card.value }}</div>
              <div class="stat-title">{{ card.title }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    <!-- 中部：图表区块 -->
    <el-row :gutter="14" style="margin-top: 14px">
      <el-col :span="auth.isSuperAdmin ? 10 : 24">
        <el-card shadow="never" header="平台概览" class="chart-card">
          <div ref="pieRef" class="chart"></div>
        </el-card>
      </el-col>
      <el-col :span="auth.isSuperAdmin ? 14 : 24">
        <el-card shadow="never" header="用户分布" class="chart-card">
          <div ref="barRef" class="chart"></div>
        </el-card>
      </el-col>
    </el-row>
    <!-- 底部：详情拓展区（hover 悬浮展示详情） -->
    <el-row :gutter="14" style="margin-top: 14px">
      <el-col :span="auth.isSuperAdmin ? 8 : 12">
        <el-card shadow="never" header="运维监控" class="detail-card">
          <el-descriptions :column="1" size="small">
            <el-descriptions-item v-for="d in ops" :key="d.label" :label="d.label">{{ d.value }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
      <el-col :span="auth.isSuperAdmin ? 8 : 12">
        <el-card shadow="never" header="业务统计" class="detail-card">
          <el-descriptions :column="1" size="small">
            <el-descriptions-item v-for="d in biz" :key="d.label" :label="d.label">{{ d.value }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
      <el-col :span="8" v-if="auth.isSuperAdmin">
        <el-card shadow="never" header="待办告警" class="detail-card">
          <div class="alert-line" v-if="Number(data.pendingAlerts || 0) > 0">
            <el-tag type="danger">未处理告警 {{ data.pendingAlerts }} 条</el-tag>
            <el-button link type="primary" @click="$router.push('/platform/alert')">前往处理</el-button>
          </div>
          <div v-else style="color:#67c23a;font-size:13px">✅ 无未处理告警</div>
          <div class="alert-line" style="margin-top:10px"><el-tag type="warning">待审批请假 {{ data.pendingLeaves || 0 }} 条</el-tag></div>
        </el-card>
      </el-col>
    </el-row>
    <el-card shadow="never" class="welcome">
      <h2>欢迎使用全学段一站式学生综合管理系统</h2>
      <p>当前登录：{{ auth.user?.realName }}（{{ auth.user?.username }}） · 机构：{{ auth.user?.orgName || '平台超级管理员（全平台）' }} · 角色：{{ (auth.user?.roles || []).join(' / ') }}</p>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import { OfficeBuilding, User, Reading, Bell, AlarmClock, Money, FirstAidKit, Grid } from '@element-plus/icons-vue'
import { useAuthStore } from '@/store/auth'
import { dashboardApi } from '@/api/dashboard'

const auth = useAuthStore()
const data = ref<any>({})
const pieRef = ref<HTMLElement>()
const barRef = ref<HTMLElement>()

const STAGE_NAMES: Record<string, string> = { kindergarten: '幼儿园', primary: '小学', junior: '初中', senior: '普高', vocational: '职高', university: '大学' }

const cards = computed(() => {
  if (auth.isSuperAdmin) {
    return [
      { title: '入驻机构', value: data.value.orgTotal ?? 0, icon: 'OfficeBuilding', bg: '#e8f1ff' },
      { title: '全平台用户', value: data.value.userTotal ?? 0, icon: 'User', bg: '#e6f7ee' },
      { title: '在校学生', value: data.value.studentTotal ?? 0, icon: 'Reading', bg: '#fff3e0' },
      { title: '待办告警', value: data.value.pendingAlerts ?? 0, icon: 'Bell', bg: '#fde8e8' }
    ]
  }
  return [
    { title: '在校学生', value: data.value.studentTotal ?? 0, icon: 'Reading', bg: '#e8f1ff' },
    { title: '教职工', value: data.value.teacherTotal ?? 0, icon: 'User', bg: '#e6f7ee' },
    { title: '班级数', value: data.value.classTotal ?? 0, icon: 'Grid', bg: '#fff3e0' },
    { title: '未缴账单', value: data.value.unpaidBills ?? 0, icon: 'Money', bg: '#fde8e8' }
  ]
})

const ops = computed(() => auth.isSuperAdmin ? [
  { label: '教职工总数', value: data.value.teacherTotal ?? 0 },
  { label: '操作日志', value: data.value.opLogTotal ?? 0 },
  { label: '今日考勤', value: data.value.todayAtt ?? 0 }
] : [
  { label: '今日考勤', value: data.value.todayAtt ?? 0 },
  { label: '待审批请假', value: data.value.pendingLeaves ?? 0 }
])

const biz = computed(() => auth.isSuperAdmin ? [
  { label: '学生总数', value: data.value.studentTotal ?? 0 },
  { label: '待审批请假', value: data.value.pendingLeaves ?? 0 },
  { label: '用户分布', value: userDistText.value }
] : [
  { label: '教职工总数', value: data.value.teacherTotal ?? 0 },
  { label: '未缴账单', value: data.value.unpaidBills ?? 0 }
])

const userDistText = computed(() => {
  const ud = data.value.userDist || {}
  return '校管' + (ud.school_admin ?? 0) + ' 教师' + (ud.teacher ?? 0) + ' 学生' + (ud.student ?? 0) + ' 家长' + (ud.parent ?? 0)
})

function renderCharts() {
  if (!auth.isSuperAdmin) return
  nextTick(() => {
    if (pieRef.value) {
      const dist = data.value.stageDist || {}
      const pie = echarts.init(pieRef.value)
      pie.setOption({
        tooltip: { trigger: 'item' },
        legend: { bottom: 0, textStyle: { fontSize: 12 } },
        series: [{
          type: 'pie', radius: ['42%', '68%'], center: ['50%', '46%'],
          itemStyle: { borderRadius: 8, borderColor: '#fff', borderWidth: 2 },
          label: { formatter: '{b}\n{c} 人' },
          data: Object.entries(dist).map(([k, v]) => ({ name: STAGE_NAMES[k] || k, value: v as number }))
        }]
      })
    }
    if (barRef.value) {
      const ud = data.value.userDist || {}
      const bar = echarts.init(barRef.value)
      bar.setOption({
        tooltip: { trigger: 'axis' },
        grid: { left: 40, right: 16, top: 20, bottom: 28 },
        xAxis: { type: 'category', data: ['校管', '教师', '学生', '家长'], axisLabel: { fontSize: 12 } },
        yAxis: { type: 'value', minInterval: 1 },
        series: [{ type: 'bar', barWidth: 34, itemStyle: { borderRadius: [6, 6, 0, 0], color: '#1f6feb' },
          data: [ud.school_admin ?? 0, ud.teacher ?? 0, ud.student ?? 0, ud.parent ?? 0] }]
      })
    }
  })
}

async function load() {
  data.value = auth.isSuperAdmin ? await dashboardApi.platform() : await dashboardApi.school()
  renderCharts()
}
onMounted(load)
</script>

<style scoped>
.stat-card :deep(.el-card__body) { padding: 18px; }
.stat-body { display: flex; align-items: center; gap: 14px; }
.stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #1f6feb; }
.stat-value { font-size: 26px; font-weight: 700; color: #1f2d3d; line-height: 1.2; }
.stat-title { font-size: 13px; color: #8492a6; }
.chart { height: 280px; }
.detail-card :deep(.el-card__body) { padding: 14px 18px; }
.alert-line { display: flex; align-items: center; gap: 10px; }
.welcome { margin-top: 14px; }
.welcome h2 { color: #1f2d3d; margin-bottom: 8px; }
.welcome p { color: #606266; font-size: 13px; }
</style>