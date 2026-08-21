<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">账</div>
          <div><h3>账号开通</h3></div>
        </div>
    <el-card shadow="never" class="org-bar" v-if="auth.isSuperAdmin">
      <div class="toolbar">
        <span style="font-weight: 600">开通机构：</span>
        <el-select v-model="activeOrgId" placeholder="选择机构（开通范围）" style="width: 300px" @change="reloadAll">
          <el-option v-for="o in orgs" :key="o.id" :label="o.orgName + '（' + o.orgCode + '）'" :value="o.id" />
        </el-select>
      </div>
    </el-card>
    <el-tabs v-model="tab">
      <el-tab-pane label="批量开通" name="batch">
        <el-card shadow="never">
          <div class="toolbar">
            <el-select v-model="openMode" style="width: 180px">
              <el-option label="Excel 标准模板导入" value="excel" />
              <el-option label="班级架构一键生成" value="class_batch" />
              <el-option label="台账同步自动建号" value="sync" />
              <el-option label="精准单条开通" value="manual" />
            </el-select>
            <el-button type="success" :icon="Plus" @click="addRow">添加一行</el-button>
            <el-button type="primary" :icon="Upload" @click="createBatch">执行批量开通</el-button>
            <el-button @click="csvDlg.visible = true">CSV 批量导入</el-button>
          </div>
          <el-table :data="rows" border size="small">
            <el-table-column label="账号(学号/工号)" width="180">
              <template #default="{ row }"><el-input v-model="row.username" size="small" /></template>
            </el-table-column>
            <el-table-column label="姓名" width="140">
              <template #default="{ row }"><el-input v-model="row.realName" size="small" /></template>
            </el-table-column>
            <el-table-column label="身份" width="120">
              <template #default="{ row }">
                <el-select v-model="row.userType" size="small">
                  <el-option label="学生" value="student" /><el-option label="教师" value="teacher" /><el-option label="家长" value="parent" />
                </el-select>
              </template>
            </el-table-column>
            <el-table-column label="归属(班级/部门)" min-width="160">
              <template #default="{ row }"><el-input v-model="row.scopeDesc" size="small" /></template>
            </el-table-column>
            <el-table-column label="操作" width="70">
              <template #default="{ $index }"><el-button link type="danger" @click="rows.splice($index, 1)">删</el-button></template>
            </el-table-column>
          </el-table>
          <el-divider>历史批次</el-divider>
          <el-table :data="batches" border stripe size="small">
            <el-table-column prop="batchNo" label="批次号" width="200" />
            <el-table-column prop="openMode" label="模式" width="120" />
            <el-table-column prop="totalCount" label="总数" width="70" />
            <el-table-column prop="successCount" label="成功" width="70" />
            <el-table-column prop="failCount" label="失败" width="70" />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="row.status === 'success' ? 'success' : row.status === 'partial' ? 'warning' : 'info'">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createdAt" label="时间" width="170" />
            <el-table-column label="明细" width="70">
              <template #default="{ row }"><el-button link type="primary" @click="showItems(row)">查看</el-button></template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="邮箱推送开通" name="email">
        <el-card shadow="never">
          <div class="toolbar">
            <el-input v-model="inviteForm.email" placeholder="收件邮箱" style="width: 220px" />
            <el-input v-model="inviteForm.realName" placeholder="姓名" style="width: 140px" />
            <el-select v-model="inviteForm.userType" style="width: 110px">
              <el-option label="学生" value="student" /><el-option label="教师" value="teacher" /><el-option label="家长" value="parent" />
            </el-select>
            <el-button type="primary" @click="sendInvite">推送官方开通邮件</el-button>
          </div>
          <el-table :data="invites" border stripe size="small">
            <el-table-column prop="email" label="邮箱" width="220" />
            <el-table-column prop="realName" label="姓名" width="120" />
            <el-table-column prop="userType" label="身份" width="100" />
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.status === 'confirmed' ? 'success' : 'info'">{{ { sent: '已推送', confirmed: '已确认开通', expired: '过期', bounced: '拒收' }[row.status] || row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="pushAt" label="推送时间" width="170" />
            <el-table-column prop="confirmAt" label="确认时间" width="170" />
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="itemsDlg.visible" :title="'批次明细：' + itemsDlg.batchNo" width="640px">
      <el-table :data="itemsDlg.items" border size="small" max-height="400">
        <el-table-column prop="rowNo" label="#" width="50" />
        <el-table-column prop="username" label="账号" width="150" />
        <el-table-column prop="realName" label="姓名" width="110" />
        <el-table-column prop="scopeDesc" label="归属" width="120" />
        <el-table-column label="结果" width="80">
          <template #default="{ row }">
            <el-tag :type="row.result === 'success' ? 'success' : row.result === 'fail' ? 'danger' : 'info'">{{ row.result }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="failReason" label="失败原因" min-width="140" show-overflow-tooltip />
      </el-table>
    </el-dialog>

    <el-dialog v-model="csvDlg.visible" title="CSV 批量导入（账号,姓名,身份,归属）" width="560px">
      <el-alert type="info" :closable="false" title="每行一条：账号(学号/工号),姓名,身份(student/teacher/parent),归属(班级/部门)；系统自动查重、部分成功容错" style="margin-bottom: 12px" />
      <el-input v-model="csvDlg.text" type="textarea" :rows="8" placeholder="new_s001,新学生,student,小一班&#10;new_t002,新教师,teacher,班主任" />
      <template #footer>
        <el-button @click="csvDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="parseCsv">解析并载入</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, Upload } from '@element-plus/icons-vue'
import { authOpenApi } from '@/api/dashboard'
import { orgApi } from '@/api/org'
import { useAuthStore } from '@/store/auth'

const auth = useAuthStore()
const orgs = ref<any[]>([])
const activeOrgId = ref<number | undefined>(undefined)

async function loadOrgs() {
  if (auth.isSuperAdmin) {
    const res = await orgApi.page({ current: 1, size: 50 })
    orgs.value = res.records
    activeOrgId.value = orgs.value[0]?.id
  } else {
    activeOrgId.value = auth.user?.orgId ?? undefined
  }
  reloadAll()
}
function curOrgId() {
  return auth.isSuperAdmin ? activeOrgId.value : auth.user?.orgId ?? undefined
}
const tab = ref('batch')
const openMode = ref('excel')
const rows = ref<any[]>([{ username: '', realName: '', userType: 'student', scopeDesc: '' }])
const batches = ref<any[]>([])
const invites = ref<any[]>([])
const itemsDlg = reactive({ visible: false, batchNo: '', items: [] as any[] })
const csvDlg = reactive({ visible: false, text: '' })
const inviteForm = reactive({ email: '', realName: '', userType: 'parent', scopeDesc: '' })

function addRow() { rows.value.push({ username: '', realName: '', userType: 'student', scopeDesc: '' }) }

function parseCsv() {
  const lines = csvDlg.text.split(/\r?\n/).filter((l) => l.trim())
  const parsed = lines.map((line) => {
    const parts = line.split(',').map((s) => s.trim())
    return { username: parts[0] || '', realName: parts[1] || '', userType: parts[2] || 'student', scopeDesc: parts[3] || '' }
  }).filter((r) => r.username)
  if (!parsed.length) { ElMessage.warning('未解析到有效行'); return }
  rows.value = parsed
  csvDlg.visible = false
  ElMessage.success('已载入 ' + parsed.length + ' 条，点击"执行批量开通"')
}

async function createBatch() {
  const payload = rows.value.filter((r) => r.username)
  if (!payload.length) { ElMessage.warning('请至少填写一行有效数据'); return }
  const res = await authOpenApi.createBatch({ orgId: curOrgId(), openMode: openMode.value, rows: payload })
  ElMessage.success('批量开通完成：成功 ' + res.successCount + '，失败 ' + res.failCount + '（部分成功容错）')
  rows.value = [{ username: '', realName: '', userType: 'student', scopeDesc: '' }]
  loadBatches()
}

async function loadBatches() {
  const res = await authOpenApi.pageBatch({ current: 1, size: 20, orgId: curOrgId() })
  batches.value = res.records
}

async function showItems(row: any) {
  itemsDlg.batchNo = row.batchNo
  itemsDlg.items = await authOpenApi.listItems(row.id)
  itemsDlg.visible = true
}

async function sendInvite() {
  if (!inviteForm.email) { ElMessage.warning('邮箱必填'); return }
  await authOpenApi.createInvite({ orgId: curOrgId(), ...inviteForm })
  ElMessage.success('开通邮件已推送，用户一键确认后自动开通')
  inviteForm.email = ''
  loadInvites()
}

async function loadInvites() {
  const res = await authOpenApi.pageInvites({ current: 1, size: 20, orgId: curOrgId() })
  invites.value = res.records
}

function reloadAll() { loadBatches(); loadInvites() }
onMounted(() => { loadOrgs() })
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; align-items: center; }
</style>