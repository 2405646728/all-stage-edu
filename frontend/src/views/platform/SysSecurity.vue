<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">安</div>
          <div><h3>安全管控</h3></div>
        </div>
    <el-tabs v-model="tab">
      <el-tab-pane label="IP 黑白名单" name="ip">
        <el-card shadow="never">
          <div class="toolbar">
            <el-select v-model="ruleType" placeholder="规则类型" clearable style="width: 140px" @change="loadIp">
              <el-option label="白名单" value="white" /><el-option label="黑名单" value="black" />
            </el-select>
            <el-button type="success" :icon="Plus" @click="openIp">新增规则</el-button>
          </div>
          <el-alert type="warning" :closable="false" title="恶意访问拦截（文档 1.3.2-3）：IP 黑白名单全局生效，配合登录失败锁定与接口限流" style="margin-bottom: 14px" />
          <el-table :data="ipList" border stripe size="small">
            <el-table-column label="类型" width="100"><template #default="{ row }"><el-tag :type="row.ruleType === 'black' ? 'danger' : 'success'">{{ row.ruleType === 'black' ? '黑名单' : '白名单' }}</el-tag></template></el-table-column>
            <el-table-column prop="ipCidr" label="IP/CIDR" width="180" />
            <el-table-column prop="remark" label="说明" min-width="200" />
            <el-table-column label="状态" width="80"><template #default="{ row }">{{ row.status === 1 ? '启用' : '停用' }}</template></el-table-column>
            <el-table-column label="操作" width="80"><template #default="{ row }"><el-button link type="danger" @click="delIp(row)">删除</el-button></template></el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="登录日志" name="login">
        <el-card shadow="never">
          <div class="toolbar">
            <el-input v-model="lgQuery.username" placeholder="账号" clearable style="width: 170px" @keyup.enter="loadLogin" />
            <el-select v-model="lgQuery.result" placeholder="结果" clearable style="width: 110px"><el-option label="成功" :value="1" /><el-option label="失败" :value="0" /></el-select>
            <el-button type="primary" :icon="Search" @click="loadLogin">查询</el-button>
          </div>
          <el-table :data="loginLogs" border stripe size="small" v-loading="lgLoading">
            <el-table-column prop="username" label="账号" width="130" />
            <el-table-column prop="loginType" label="方式" width="100" />
            <el-table-column label="结果" width="80"><template #default="{ row }"><el-tag :type="row.loginResult === 1 ? 'success' : 'danger'">{{ row.loginResult === 1 ? '成功' : '失败' }}</el-tag></template></el-table-column>
            <el-table-column prop="failReason" label="失败原因" width="160" />
            <el-table-column prop="ip" label="IP" width="130" />
            <el-table-column prop="deviceInfo" label="设备" width="150" show-overflow-tooltip />
            <el-table-column prop="loginAt" label="登录时间" width="170" />
          </el-table>
          <el-pagination v-model:current-page="lgQuery.current" v-model:page-size="lgQuery.size" :total="lgTotal" layout="total, prev, pager, next" @current-change="loadLogin" style="margin-top:12px;justify-content:flex-end" />
        </el-card>
      </el-tab-pane>
    </el-tabs>
    <el-dialog v-model="ipDlg.visible" title="IP 规则" width="420px">
      <el-form label-width="80px">
        <el-form-item label="类型"><el-radio-group v-model="ipDlg.form.ruleType"><el-radio value="white">白名单</el-radio><el-radio value="black">黑名单</el-radio></el-radio-group></el-form-item>
        <el-form-item label="IP/CIDR"><el-input v-model="ipDlg.form.ipCidr" placeholder="如 192.168.1.0/24" /></el-form-item>
        <el-form-item label="说明"><el-input v-model="ipDlg.form.remark" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="ipDlg.visible = false">取消</el-button><el-button type="primary" @click="saveIp">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'
import { securityApi } from '@/api/security'

const tab = ref('ip')
const ruleType = ref('')
const ipList = ref<any[]>([])
const ipDlg = reactive({ visible: false, form: {} as any })
const loginLogs = ref<any[]>([])
const lgTotal = ref(0)
const lgLoading = ref(false)
const lgQuery = reactive({ current: 1, size: 10, username: '', result: undefined as number | undefined })

async function loadIp() { ipList.value = await securityApi.listIpRules(ruleType.value) }
function openIp() { ipDlg.form = { ruleType: 'black', ipCidr: '', remark: '', status: 1 }; ipDlg.visible = true }
async function saveIp() { await securityApi.saveIpRule(ipDlg.form); ElMessage.success('规则已生效'); ipDlg.visible = false; loadIp() }
async function delIp(row: any) { await ElMessageBox.confirm('确认删除该规则？', '提示', { type: 'warning' }); await securityApi.deleteIpRule(row.id); ElMessage.success('已删除'); loadIp() }
async function loadLogin() { lgLoading.value = true; try { const res = await securityApi.pageLoginLog({ ...lgQuery }); loginLogs.value = res.records; lgTotal.value = res.total } finally { lgLoading.value = false } }
onMounted(() => { loadIp(); loadLogin() })
</script>

<style scoped>.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }</style>