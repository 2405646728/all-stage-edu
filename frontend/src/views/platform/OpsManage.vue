<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">运</div>
          <div><h3>运维中心</h3></div>
        </div>
    <el-tabs v-model="tab">
      <el-tab-pane label="数据备份" name="backup">
        <el-card shadow="never">
          <div class="toolbar"><el-button type="success" :icon="Plus" @click="openBk">登记备份任务</el-button></div>
          <el-alert type="info" :closable="false" title="手动/定时全量数据备份、定点数据恢复（文档 1.3.4-2），备份记录永久留存" style="margin-bottom: 14px" />
          <el-table :data="backups" border stripe size="small">
            <el-table-column prop="backupType" label="触发方式" width="100" />
            <el-table-column prop="backupMode" label="模式" width="90" />
            <el-table-column prop="targetDesc" label="备份范围" width="160" />
            <el-table-column prop="filePath" label="文件路径" min-width="220" show-overflow-tooltip />
            <el-table-column prop="status" label="状态" width="100" />
            <el-table-column prop="startedAt" label="开始时间" width="170" />
            <el-table-column prop="finishedAt" label="完成时间" width="170" />
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="政务上报" name="gov">
        <el-card shadow="never">
          <div class="toolbar"><el-button type="success" :icon="Plus" @click="openGov">配置模板</el-button></div>
          <el-alert type="info" :closable="false" title="政务数据上报（文档 1.3.5-3）：预设教育局/教育厅上报模板、字段映射、上报频率，可视化配置适配政策新规" style="margin-bottom: 14px" />
          <el-table :data="govs" border stripe size="small">
            <el-table-column prop="templateCode" label="模板编码" width="140" />
            <el-table-column prop="templateName" label="模板名称" width="160" />
            <el-table-column prop="target" label="上报对象" width="140" />
            <el-table-column prop="stageScope" label="适用学段" width="110" />
            <el-table-column prop="reportFrequency" label="频率" width="90" />
            <el-table-column label="状态" width="80"><template #default="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '启用' : '停用' }}</el-tag></template></el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>
    <el-dialog v-model="bkDlg.visible" title="备份记录" width="480px">
      <el-form label-width="90px">
        <el-form-item label="触发方式"><el-select v-model="bkDlg.form.backupType" style="width:100%"><el-option label="手动" value="manual" /><el-option label="定时" value="auto" /></el-select></el-form-item>
        <el-form-item label="模式"><el-radio-group v-model="bkDlg.form.backupMode"><el-radio value="full">全量</el-radio><el-radio value="incremental">增量</el-radio></el-radio-group></el-form-item>
        <el-form-item label="范围"><el-input v-model="bkDlg.form.targetDesc" placeholder="全库/定点" /></el-form-item>
        <el-form-item label="路径"><el-input v-model="bkDlg.form.filePath" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="bkDlg.visible = false">取消</el-button><el-button type="primary" @click="saveBk">登记</el-button></template>
    </el-dialog>
    <el-dialog v-model="govDlg.visible" title="政务上报模板" width="500px">
      <el-form label-width="100px">
        <el-form-item label="模板编码"><el-input v-model="govDlg.form.templateCode" /></el-form-item>
        <el-form-item label="模板名称"><el-input v-model="govDlg.form.templateName" /></el-form-item>
        <el-form-item label="上报对象"><el-select v-model="govDlg.form.target" style="width:100%"><el-option label="教育局" value="edu_bureau" /><el-option label="教育厅" value="edu_dept" /><el-option label="政务平台" value="gov_platform" /></el-select></el-form-item>
        <el-form-item label="适用学段"><el-input v-model="govDlg.form.stageScope" placeholder="ALL 或 kindergarten,primary..." /></el-form-item>
        <el-form-item label="上报频率"><el-select v-model="govDlg.form.reportFrequency" style="width:100%"><el-option label="日" value="daily" /><el-option label="周" value="weekly" /><el-option label="月" value="monthly" /><el-option label="季" value="quarterly" /><el-option label="年" value="yearly" /></el-select></el-form-item>
      </el-form>
      <template #footer><el-button @click="govDlg.visible = false">取消</el-button><el-button type="primary" @click="saveGov">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { securityApi } from '@/api/security'

const tab = ref('backup')
const backups = ref<any[]>([])
const govs = ref<any[]>([])
const bkDlg = reactive({ visible: false, form: {} as any })
const govDlg = reactive({ visible: false, form: {} as any })

async function loadBk() { backups.value = await securityApi.listBackups() }
async function loadGov() { govs.value = await securityApi.listGov() }
function openBk() { bkDlg.form = { backupType: 'manual', backupMode: 'full', targetDesc: '', filePath: '', status: 'running' }; bkDlg.visible = true }
async function saveBk() { await securityApi.saveBackup(bkDlg.form); ElMessage.success('已登记'); bkDlg.visible = false; loadBk() }
function openGov() { govDlg.form = { templateCode: '', templateName: '', target: 'edu_bureau', stageScope: 'ALL', reportFrequency: 'monthly', status: 1 }; govDlg.visible = true }
async function saveGov() { await securityApi.saveGov(govDlg.form); ElMessage.success('模板已配置'); govDlg.visible = false; loadGov() }
onMounted(() => { loadBk(); loadGov() })
</script>

<style scoped>.toolbar { margin-bottom: 14px; }</style>