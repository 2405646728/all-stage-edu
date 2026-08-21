<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">操</div>
          <div><h3>操作日志</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <el-input v-model="query.username" placeholder="操作人账号" clearable style="width: 180px" @keyup.enter="load" />
        <el-select v-model="query.bizType" placeholder="业务类型" clearable style="width: 160px">
          <el-option v-for="t in bizTypes" :key="t.value" :label="t.label" :value="t.value" />
        </el-select>
        <el-button type="primary" :icon="Search" @click="load">查询</el-button>
      </div>
      <el-table :data="list" border stripe v-loading="loading">
        <el-table-column prop="operatedAt" label="操作时间" width="170" />
        <el-table-column prop="username" label="操作人" width="110" />
        <el-table-column label="业务类型" width="100">
          <template #default="{ row }">{{ bizName(row.bizType) }}</template>
        </el-table-column>
        <el-table-column prop="action" label="动作" width="90" />
        <el-table-column prop="targetTable" label="目标表" width="180" />
        <el-table-column prop="targetId" label="目标ID" width="80" />
        <el-table-column prop="ip" label="IP" width="130" />
      </el-table>
      <el-pagination v-model:current-page="query.current" v-model:page-size="query.size" :total="total"
        layout="total, prev, pager, next, sizes" :page-sizes="[10, 20, 50]"
        @current-change="load" @size-change="load" style="margin-top: 12px; justify-content: flex-end" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { platformApi } from '@/api/sys'

const bizTypes = [
  { label: '机构', value: 'org' }, { label: '账号', value: 'user' }, { label: '配置', value: 'config' },
  { label: '模块', value: 'module' }, { label: '硬件', value: 'device' }, { label: '接口', value: 'api' },
  { label: '补丁', value: 'patch' }, { label: '备份', value: 'backup' }, { label: '业务', value: 'business' },
  { label: '财务', value: 'finance' }
]
function bizName(v: string) { return bizTypes.find((t) => t.value === v)?.label || v }

const loading = ref(false)
const list = ref<any[]>([])
const total = ref(0)
const query = reactive({ current: 1, size: 10, username: '', bizType: '' })

async function load() {
  loading.value = true
  try {
    const res = await platformApi.pageLog({ ...query })
    list.value = res.records
    total.value = res.total
  } finally { loading.value = false }
}
onMounted(load)
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>
