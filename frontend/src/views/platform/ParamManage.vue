<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">全</div>
          <div><h3>全局参数</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <el-select v-model="group" placeholder="参数分组" clearable style="width: 200px" @change="load">
          <el-option v-for="g in groups" :key="g.value" :label="g.label" :value="g.value" />
        </el-select>
        <el-button type="primary" :icon="Search" @click="load">查询</el-button>
      </div>
      <el-alert type="info" :closable="false" title="全局底层参数为系统核心冻结规则（文档 1.3.2）：登录时效/密码复杂度/加密规则/接口限流/推送开关/日志留存" style="margin-bottom: 14px" />
      <el-table :data="list" border stripe>
        <el-table-column prop="paramGroup" label="分组" width="140" />
        <el-table-column prop="paramKey" label="参数键" width="200" />
        <el-table-column label="参数值" width="260"><template #default="{ row }"><el-input v-model="row.paramValue" size="small" /></template></el-table-column>
        <el-table-column prop="valueType" label="类型" width="80" />
        <el-table-column prop="description" label="说明" min-width="200" show-overflow-tooltip />
        <el-table-column label="操作" width="90"><template #default="{ row }"><el-button link type="primary" @click="save(row)">保存</el-button></template></el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { platformApi } from '@/api/sys'

const groups = [
  { label: '登录安全', value: 'login_security' }, { label: '加密规则', value: 'crypto' },
  { label: '接口限流', value: 'api_limit' }, { label: '日志留存', value: 'log_retention' }, { label: '推送配置', value: 'push' }
]
const group = ref('')
const list = ref<any[]>([])
async function load() { list.value = await platformApi.listParams(group.value) }
async function save(row: any) { await platformApi.saveParam(row); ElMessage.success('参数已更新（平台级配置）') }
onMounted(load)
</script>

<style scoped>.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }</style>