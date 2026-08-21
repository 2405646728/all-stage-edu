<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">机</div>
          <div><h3>机构管理</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <el-input v-model="query.keyword" placeholder="机构名称/编码" clearable style="width: 220px" @keyup.enter="load" />
        <el-select v-model="query.stage" placeholder="学段" clearable style="width: 140px">
          <el-option v-for="s in stages" :key="s.value" :label="s.label" :value="s.value" />
        </el-select>
        <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        <el-button type="warning" :icon="Download" @click="exportCsv">导出机构台账</el-button>
      </div>
      <el-table :data="list" border stripe v-loading="loading">
        <el-table-column prop="orgCode" label="机构编码" width="100" />
        <el-table-column prop="orgName" label="机构名称" min-width="160" />
        <el-table-column label="学段" width="80">
          <template #default="{ row }">{{ stageName(row.stage) }}</template>
        </el-table-column>
        <el-table-column label="办学主体" width="100">
          <template #default="{ row }">{{ { public: '公办', private: '民办', group: '集团' }[row.schoolType] || row.schoolType }}</template>
        </el-table-column>
        <el-table-column prop="city" label="地区" width="140" />
        <el-table-column prop="contactName" label="联系人" width="90" />
        <el-table-column prop="contactPhone" label="联系电话" width="130" />
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : row.status === 0 ? 'warning' : 'danger'">
              {{ { 0: '待审核', 1: '正常', 2: '禁用', 3: '注销' }[row.status] || row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="serviceEnd" label="服务截止" width="110" />
      </el-table>
      <el-pagination
        v-model:current-page="query.current" v-model:page-size="query.size"
        :total="total" layout="total, prev, pager, next, sizes"
        :page-sizes="[10, 20, 50]" @current-change="load" @size-change="load"
        style="margin-top: 12px; justify-content: flex-end" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search, Download } from '@element-plus/icons-vue'
import { orgApi } from '@/api/org'

const stages = [
  { label: '幼儿园', value: 'kindergarten' },
  { label: '小学', value: 'primary' },
  { label: '初中', value: 'junior' },
  { label: '普高', value: 'senior' },
  { label: '职高', value: 'vocational' },
  { label: '大学', value: 'university' }
]

const loading = ref(false)
const list = ref<any[]>([])
const total = ref(0)
const query = reactive({ current: 1, size: 10, keyword: '', stage: '' })

function stageName(v: string) {
  return stages.find((s) => s.value === v)?.label || v
}

async function load() {
  loading.value = true
  try {
    const res = await orgApi.page({ ...query })
    list.value = res.records
    total.value = res.total
  } finally {
    loading.value = false
  }
}

function exportCsv() {
  const token = localStorage.getItem('asedu_token')
  fetch('/api/export/org', { headers: { Authorization: 'Bearer ' + token } })
    .then((res) => res.blob())
    .then((blob) => {
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.setAttribute('download', '机构台账.csv')
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    })
}
onMounted(load)
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>