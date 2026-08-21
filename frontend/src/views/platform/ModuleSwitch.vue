<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">模</div>
          <div><h3>模块开关</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <span>选择机构：</span>
        <el-select v-model="orgId" placeholder="选择机构" style="width: 240px" @change="loadSwitches">
          <el-option v-for="o in orgs" :key="o.id" :label="o.orgName + '（' + o.orgCode + '）'" :value="o.id" />
        </el-select>
      </div>
      <el-table :data="rows" border stripe v-loading="loading">
        <el-table-column prop="moduleName" label="模块名称" width="180" />
        <el-table-column prop="moduleCode" label="模块编码" width="160" />
        <el-table-column prop="stageScope" label="适用学段" width="140" />
        <el-table-column label="插件化" width="80">
          <template #default="{ row }">{{ row.isPlugin === 1 ? '可插拔' : '核心' }}</template>
        </el-table-column>
        <el-table-column label="当前开关" width="110">
          <template #default="{ row }">
            <el-switch v-model="row.enabled" :active-value="1" :inactive-value="0" @change="toggle(row)" />
          </template>
        </el-table-column>
        <el-table-column prop="description" label="说明" min-width="200" show-overflow-tooltip />
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { platformApi } from '@/api/sys'
import { orgApi } from '@/api/org'

const orgs = ref<any[]>([])
const orgId = ref<number>()
const loading = ref(false)
// moduleCode -> 开关记录对象（含 id，供 upsert）
const switches = ref<Map<string, any>>(new Map())

const rows = computed(() => {
  // 模块注册表 + 机构开关合并展示
  return modules.value.map((m) => {
    const sw = switches.value.get(m.moduleCode)
    return { ...m, enabled: sw ? sw.enabled : m.defaultOn, switchId: sw ? sw.id : undefined }
  })
})
const modules = ref<any[]>([])

async function loadOrgs() {
  const res = await orgApi.page({ current: 1, size: 50 })
  orgs.value = res.records
  orgId.value = orgs.value[0]?.id
  if (orgId.value) loadSwitches()
}

async function loadSwitches() {
  if (!orgId.value) return
  loading.value = true
  try {
    modules.value = await platformApi.listModules()
    const list = await platformApi.listOrgSwitches(orgId.value)
    switches.value = new Map(list.map((s: any) => [s.moduleCode, s]))
  } finally {
    loading.value = false
  }
}

async function toggle(row: any) {
  const saved = await platformApi.saveOrgSwitch({
    id: row.switchId,
    orgId: orgId.value,
    moduleCode: row.moduleCode,
    enabled: row.enabled
  })
  switches.value.set(row.moduleCode, saved)
  ElMessage.success('模块开关已更新（熔断/启用即时生效）')
}

onMounted(loadOrgs)
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; align-items: center; }
</style>