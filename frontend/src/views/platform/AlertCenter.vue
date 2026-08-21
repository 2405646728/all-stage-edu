<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">告</div>
          <div><h3>告警中心</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <el-select v-model="query.level" placeholder="告警级别" clearable style="width: 140px">
          <el-option label="轻微" value="info" /><el-option label="中级" value="warn" />
          <el-option label="严重" value="error" /><el-option label="高危" value="fatal" />
        </el-select>
        <el-select v-model="query.status" placeholder="处理状态" clearable style="width: 140px">
          <el-option label="未处理" :value="0" /><el-option label="处理中" :value="1" /><el-option label="已解决" :value="2" />
        </el-select>
        <el-button type="primary" :icon="Search" @click="load">查询</el-button>
      </div>
      <el-table :data="list" border stripe v-loading="loading">
        <el-table-column label="级别" width="90">
          <template #default="{ row }">
            <el-tag :type="{ info: 'info', warn: 'warning', error: 'danger', fatal: 'danger' }[row.alertLevel] || 'info'">
              {{ { info: '轻微', warn: '中级', error: '严重', fatal: '高危' }[row.alertLevel] || row.alertLevel }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="alertType" label="类型" width="100" />
        <el-table-column prop="title" label="告警标题" min-width="180" show-overflow-tooltip />
        <el-table-column prop="content" label="内容" min-width="200" show-overflow-tooltip />
        <el-table-column prop="occurredAt" label="发生时间" width="170" />
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 2 ? 'success' : row.status === 1 ? 'warning' : 'danger'">
              {{ { 0: '未处理', 1: '处理中', 2: '已解决' }[row.status] }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="130" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status !== 2" link type="primary" @click="handle(row)">处理闭环</el-button>
            <span v-else style="color: #909399; font-size: 12px">{{ row.handleRemark || '已处理' }}</span>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination v-model:current-page="query.current" v-model:page-size="query.size" :total="total"
        layout="total, prev, pager, next, sizes" :page-sizes="[10, 20, 50]"
        @current-change="load" @size-change="load" style="margin-top: 12px; justify-content: flex-end" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { platformApi } from '@/api/sys'

const loading = ref(false)
const list = ref<any[]>([])
const total = ref(0)
const query = reactive({ current: 1, size: 10, level: '', status: undefined as number | undefined })

async function load() {
  loading.value = true
  try {
    const res = await platformApi.pageAlert({ ...query })
    list.value = res.records
    total.value = res.total
  } finally { loading.value = false }
}

async function handle(row: any) {
  const { value } = await ElMessageBox.prompt('填写处理备注（自愈/熔断/修复闭环）', '处理告警', {
    inputPlaceholder: '例如：网络波动已恢复 / 模块已熔断待修复'
  })
  await platformApi.handleAlert(row.id, value)
  ElMessage.success('已处理')
  load()
}
onMounted(load)
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>
