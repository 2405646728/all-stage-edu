<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">门</div>
          <div><h3>门禁通行</h3></div>
        </div>
    <el-tabs v-model="tab">
      <!-- 通行记录（全量溯源） -->
      <el-tab-pane label="通行记录" name="pass">
        <el-card shadow="never">
          <div class="toolbar">
            <el-input v-model="passQuery.keyword" placeholder="人员/设备" clearable style="width: 170px" @keyup.enter="loadPass" />
            <el-select v-model="passQuery.result" placeholder="通行结果" clearable style="width: 130px"><el-option label="有效" value="valid" /><el-option label="无效拦截" value="invalid" /><el-option label="异常" value="abnormal" /></el-select>
            <el-button type="primary" :icon="Search" @click="loadPass">查询</el-button>
          </div>
          <el-table :data="passes" border stripe v-loading="passLoading">
            <el-table-column prop="personName" label="人员" width="110" />
            <el-table-column prop="personType" label="类型" width="90"><template #default="{ row }">{{ { student: '学生', teacher: '教职工', guardian: '接送人', visitor: '访客', stranger: '陌生', undefined: '-' }[row.personType] || row.personType }}</template></el-table-column>
            <el-table-column prop="deviceName" label="设备" width="120" />
            <el-table-column prop="passTime" label="通行时间" width="170" />
            <el-table-column label="方向" width="70"><template #default="{ row }">{{ row.direction === 'in' ? '入校' : '离校' }}</template></el-table-column>
            <el-table-column label="方式" width="90"><template #default="{ row }">{{ { card: '刷卡', face: '刷脸', manual: '人工' }[row.passWay] || row.passWay }}</template></el-table-column>
            <el-table-column label="结果" width="100"><template #default="{ row }"><el-tag :type="row.result === 'valid' ? 'success' : 'danger'">{{ { valid: '有效', invalid: '拦截', abnormal: '异常' }[row.result] || row.result }}</el-tag></template></el-table-column>
            <el-table-column prop="failReason" label="拦截原因" min-width="140" show-overflow-tooltip />
          </el-table>
          <el-pagination v-model:current-page="passQuery.current" v-model:page-size="passQuery.size" :total="passTotal" layout="total, prev, pager, next" @current-change="loadPass" style="margin-top:12px;justify-content:flex-end" />
        </el-card>
      </el-tab-pane>
      <!-- 通行权限 -->
      <el-tab-pane label="通行权限" name="perm">
        <el-card shadow="never">
          <div class="toolbar"><el-button type="success" size="small" :icon="Plus" @click="openPerm">新增授权</el-button></div>
          <el-table :data="perms" border stripe size="small">
            <el-table-column prop="personType" label="人员类型" width="100" />
            <el-table-column prop="personId" label="人员ID" width="90" />
            <el-table-column prop="permission" label="权限" width="110" />
            <el-table-column prop="grantMode" label="授权方式" width="110" />
            <el-table-column prop="validUntil" label="有效期至" width="170" />
            <el-table-column label="状态" width="90"><template #default="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'danger'">{{ { 0: '冻结', 1: '有效', 2: '过期' }[row.status] }}</el-tag></template></el-table-column>
            <el-table-column prop="freezeReason" label="冻结原因" min-width="140" show-overflow-tooltip />
          </el-table>
        </el-card>
      </el-tab-pane>
      <!-- 安防预警 -->
      <el-tab-pane label="安防预警" name="alert">
        <el-card shadow="never">
          <el-table :data="alerts" border stripe size="small">
            <el-table-column label="级别" width="80"><template #default="{ row }"><el-tag :type="row.alertLevel === 'error' ? 'danger' : 'warning'">{{ row.alertLevel }}</el-tag></template></el-table-column>
            <el-table-column prop="alertType" label="类型" width="110" />
            <el-table-column prop="content" label="预警内容" min-width="200" show-overflow-tooltip />
            <el-table-column prop="occurredAt" label="时间" width="170" />
            <el-table-column label="状态" width="90"><template #default="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'danger'">{{ row.status === 1 ? '已处理' : '未处理' }}</el-tag></template></el-table-column>
            <el-table-column label="操作" width="110"><template #default="{ row }"><el-button v-if="row.status !== 1" link type="primary" @click="handleAlert(row)">处理</el-button></template></el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
      <!-- 访客 -->
      <el-tab-pane label="访客预约" name="visitor">
        <el-card shadow="never">
          <el-table :data="visitors" border stripe size="small">
            <el-table-column prop="name" label="访客" width="100" />
            <el-table-column prop="phone" label="手机号" width="130" />
            <el-table-column prop="visitPurpose" label="事由" width="150" />
            <el-table-column prop="visitStart" label="预约时间" width="170" />
            <el-table-column label="审批" width="100"><template #default="{ row }"><el-tag :type="row.approveStatus === 'approved' ? 'success' : 'warning'">{{ { pending: '待审批', approved: '已通过', rejected: '已驳回' }[row.approveStatus] || row.approveStatus }}</el-tag></template></el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="permDlg.visible" title="门禁通行授权" width="460px">
      <el-form label-width="100px">
        <el-form-item label="人员类型"><el-select v-model="permDlg.form.personType" style="width:100%"><el-option label="学生" value="student" /><el-option label="教职工" value="teacher" /><el-option label="接送人" value="guardian" /></el-select></el-form-item>
        <el-form-item label="人员ID"><el-input-number v-model="permDlg.form.personId" :min="1" /></el-form-item>
        <el-form-item label="权限类型"><el-select v-model="permDlg.form.permission" style="width:100%"><el-option label="出入校" value="in_out" /><el-option label="入校" value="in" /><el-option label="离校" value="out" /><el-option label="区域通行" value="area" /></el-select></el-form-item>
        <el-form-item label="授权方式"><el-radio-group v-model="permDlg.form.grantMode"><el-radio value="manual">单独授权</el-radio><el-radio value="batch">批量授权</el-radio><el-radio value="auto">自动</el-radio></el-radio-group></el-form-item>
        <el-form-item label="有效期至"><el-date-picker v-model="permDlg.form.validUntil" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="permDlg.visible = false">取消</el-button><el-button type="primary" @click="savePerm">授权</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { gateApi } from '@/api/biz'

const tab = ref('pass')
const passLoading = ref(false)
const passes = ref<any[]>([])
const passTotal = ref(0)
const passQuery = reactive({ current: 1, size: 10, keyword: '', result: '' })
const perms = ref<any[]>([])
const alerts = ref<any[]>([])
const visitors = ref<any[]>([])
const permDlg = reactive({ visible: false, form: {} as any })

function openPerm() { permDlg.form = { personType: 'student', personId: 1, permission: 'in_out', grantMode: 'manual', validUntil: '' }; permDlg.visible = true }
async function savePerm() { await gateApi.savePermission(permDlg.form); ElMessage.success('授权已生效'); permDlg.visible = false; loadPerms() }

async function loadPass() { passLoading.value = true; try { const res = await gateApi.pagePass({ ...passQuery }); passes.value = res.records; passTotal.value = res.total } finally { passLoading.value = false } }
async function loadPerms() { perms.value = await gateApi.listPermission({}) }
async function loadAlerts() { const res = await gateApi.pageAlert({ current: 1, size: 20 }); alerts.value = res.records }
async function loadVisitors() { const res = await gateApi.pageVisitor({ current: 1, size: 20 }); visitors.value = res.records }
async function handleAlert(row: any) {
  const { value } = await ElMessageBox.prompt('处理备注', '处理预警', { inputPlaceholder: '安保核验/设备修复说明' })
  await gateApi.handleAlert({ id: row.id, note: value })
  ElMessage.success('已处理'); loadAlerts()
}
onMounted(() => { loadPass(); loadPerms(); loadAlerts(); loadVisitors() })
</script>

<style scoped>.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }</style>