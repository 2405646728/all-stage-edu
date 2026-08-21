<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">门</div>
          <div><h3>门禁硬件</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <el-input v-model="query.keyword" placeholder="设备名称/编码" clearable style="width: 190px" @keyup.enter="load" />
        <el-select v-model="query.status" placeholder="设备状态" clearable style="width: 130px">
          <el-option label="在线" :value="1" /><el-option label="离线" :value="0" /><el-option label="故障" :value="2" /><el-option label="停用" :value="3" />
        </el-select>
        <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        <el-button type="success" :icon="Plus" @click="openDlg()">接入设备</el-button>
      </div>
      <el-alert type="info" :closable="false" title="门禁硬件全局注册（文档 1.3.5）：统一管控全平台门禁设备，六学段复用，硬件对接复用全局网关" style="margin-bottom: 14px" />
      <el-table :data="list" border stripe v-loading="loading">
        <el-table-column prop="deviceCode" label="设备编码" width="130" />
        <el-table-column prop="deviceName" label="设备名称" width="140" />
        <el-table-column label="类型" width="100"><template #default="{ row }">{{ { gate: '闸机', door: '门禁', face: '人脸终端', card: '刷卡器' }[row.deviceType] || row.deviceType }}</template></el-table-column>
        <el-table-column prop="model" label="型号" width="130" />
        <el-table-column prop="vendor" label="厂商" width="110" />
        <el-table-column prop="location" label="安装位置" min-width="140" />
        <el-table-column prop="ip" label="IP" width="120" />
        <el-table-column label="状态" width="90"><template #default="{ row }"><el-tag :type="row.status === 1 ? 'success' : row.status === 0 ? 'info' : 'danger'">{{ { 0: '离线', 1: '在线', 2: '故障', 3: '停用' }[row.status] || row.status }}</el-tag></template></el-table-column>
        <el-table-column prop="lastOnlineAt" label="最近在线" width="160" />
      </el-table>
      <el-pagination v-model:current-page="query.current" v-model:page-size="query.size" :total="total" layout="total, prev, pager, next" @current-change="load" style="margin-top:12px;justify-content:flex-end" />
    </el-card>
    <el-dialog v-model="dlg.visible" title="门禁设备" width="520px">
      <el-form label-width="90px">
        <el-form-item label="设备编码"><el-input v-model="dlg.form.deviceCode" placeholder="硬件SN" /></el-form-item>
        <el-form-item label="设备名称"><el-input v-model="dlg.form.deviceName" /></el-form-item>
        <el-form-item label="设备类型"><el-select v-model="dlg.form.deviceType" style="width:100%"><el-option label="闸机" value="gate" /><el-option label="门禁" value="door" /><el-option label="人脸终端" value="face" /><el-option label="刷卡器" value="card" /></el-select></el-form-item>
        <el-form-item label="型号"><el-input v-model="dlg.form.model" /></el-form-item>
        <el-form-item label="厂商"><el-input v-model="dlg.form.vendor" /></el-form-item>
        <el-form-item label="安装位置"><el-input v-model="dlg.form.location" /></el-form-item>
        <el-form-item label="设备IP"><el-input v-model="dlg.form.ip" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="dlg.visible = false">取消</el-button><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'
import { platformApi } from '@/api/sys'

const loading = ref(false)
const list = ref<any[]>([])
const total = ref(0)
const query = reactive({ current: 1, size: 10, keyword: '', status: undefined as number | undefined })
const dlg = reactive({ visible: false, form: {} as any })

async function load() { loading.value = true; try { const res = await platformApi.pageDevice({ ...query }); list.value = res.records; total.value = res.total } finally { loading.value = false } }
function openDlg() { dlg.form = { deviceCode: '', deviceName: '', deviceType: 'gate', model: '', vendor: '', location: '', ip: '', status: 0 }; dlg.visible = true }
async function save() { await platformApi.saveDevice(dlg.form); ElMessage.success('设备已注册'); dlg.visible = false; load() }
onMounted(load)
</script>

<style scoped>.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }</style>