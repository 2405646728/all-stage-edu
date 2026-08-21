<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">A</div>
          <div><h3>API 网关</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <el-input v-model="keyword" placeholder="接口名称/路径" clearable style="width: 200px" @keyup.enter="load" />
        <el-button type="primary" :icon="Search" @click="load">查询</el-button>
      </div>
      <el-alert type="info" :closable="false" title="统一 API 网关（文档 1.3.5）：接口启停、密钥配置、权限校验、流量管控，适配政务平台/第三方系统/门禁硬件标准化对接" style="margin-bottom: 14px" />
      <el-table :data="list" border stripe>
        <el-table-column prop="apiCode" label="接口编码" width="150" />
        <el-table-column prop="apiName" label="接口名称" width="180" />
        <el-table-column prop="apiPath" label="路径" min-width="200" show-overflow-tooltip />
        <el-table-column prop="apiMethod" label="方法" width="80" />
        <el-table-column prop="rateLimit" label="限流(次/分)" width="110" />
        <el-table-column label="签名校验" width="100"><template #default="{ row }"><el-tag :type="row.needSign === 1 ? 'warning' : 'info'">{{ row.needSign === 1 ? '需要' : '否' }}</el-tag></template></el-table-column>
        <el-table-column label="状态" width="80"><template #default="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'danger'">{{ row.status === 1 ? '启用' : '停用' }}</el-tag></template></el-table-column>
        <el-table-column prop="description" label="说明" min-width="160" show-overflow-tooltip />
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { platformApi } from '@/api/sys'

const keyword = ref('')
const list = ref<any[]>([])
async function load() { list.value = await platformApi.listApis(keyword.value) }
onMounted(load)
</script>

<style scoped>.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }</style>