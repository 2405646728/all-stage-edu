<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">考</div>
          <div><h3>考勤管理</h3></div>
        </div>
    <el-tabs v-model="tab">
      <el-tab-pane label="学生考勤" name="att">
        <el-card shadow="never">
          <div class="toolbar">
            <el-input v-model="attQuery.keyword" placeholder="姓名/学号" clearable style="width: 180px" @keyup.enter="loadAtt" />
            <el-date-picker v-model="attQuery.attDate" type="date" value-format="YYYY-MM-DD" placeholder="考勤日期" style="width: 150px" />
            <el-select v-model="attQuery.status" placeholder="状态" clearable style="width: 130px">
              <el-option v-for="s in attStatus" :key="s.value" :label="s.label" :value="s.value" />
            </el-select>
            <el-button type="primary" :icon="Search" @click="loadAtt">查询</el-button>
            <el-button type="success" :icon="Plus" @click="openCheckIn">签到登记</el-button>
          </div>
          <el-table :data="attList" border stripe v-loading="attLoading">
            <el-table-column prop="attDate" label="日期" width="110" />
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="signInTime" label="签到" width="160" />
            <el-table-column prop="signOutTime" label="签退" width="160" />
            <el-table-column prop="stayMinutes" label="在校(分钟)" width="90" />
            <el-table-column prop="deviceName" label="设备" width="110" />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="tagType(row.status)">{{ attName(row.status) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="remark" label="备注" min-width="120" />
          </el-table>
          <el-pagination v-model:current-page="attQuery.current" v-model:page-size="attQuery.size" :total="attTotal"
            layout="total, prev, pager, next" @current-change="loadAtt" style="margin-top: 12px; justify-content: flex-end" />
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="请假审批" name="leave">
        <el-card shadow="never">
          <div class="toolbar">
            <el-select v-model="leaveQuery.approveStatus" placeholder="审批状态" clearable style="width: 140px">
              <el-option label="待审批" value="pending" />
              <el-option label="已通过" value="approved" />
              <el-option label="已驳回" value="rejected" />
            </el-select>
            <el-button type="primary" :icon="Search" @click="loadLeave">查询</el-button>
          </div>
          <el-table :data="leaveList" border stripe v-loading="leaveLoading">
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="leaveType" label="类型" width="90">
              <template #default="{ row }">{{ { personal: '事假', sick: '病假', annual: '年假' }[row.leaveType] || row.leaveType }}</template>
            </el-table-column>
            <el-table-column prop="startTime" label="开始" width="160" />
            <el-table-column prop="endTime" label="结束" width="160" />
            <el-table-column prop="durationHours" label="时长(h)" width="80" />
            <el-table-column prop="reason" label="事由" min-width="140" show-overflow-tooltip />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="row.approveStatus === 'approved' ? 'success' : row.approveStatus === 'rejected' ? 'danger' : 'warning'">
                  {{ { pending: '待审批', approved: '已通过', rejected: '已驳回' }[row.approveStatus] }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <template v-if="row.approveStatus === 'pending'">
                  <el-button link type="success" @click="approve(row, 'approved')">通过</el-button>
                  <el-button link type="danger" @click="approve(row, 'rejected')">驳回</el-button>
                </template>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="checkInDlg.visible" title="考勤签到登记（刷卡/刷脸/人工补录）" width="480px">
      <el-form label-width="90px">
        <el-form-item label="学生ID"><el-input-number v-model="checkInDlg.form.studentId" :min="1" /></el-form-item>
        <el-form-item label="考勤日期"><el-date-picker v-model="checkInDlg.form.attDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" /></el-form-item>
        <el-form-item label="签到时间"><el-date-picker v-model="checkInDlg.form.signInTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width: 100%" /></el-form-item>
        <el-form-item label="签退时间"><el-date-picker v-model="checkInDlg.form.signOutTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width: 100%" /></el-form-item>
        <el-form-item label="方式">
          <el-radio-group v-model="checkInDlg.form.signInWay">
            <el-radio value="card">刷卡</el-radio><el-radio value="face">刷脸</el-radio><el-radio value="manual">人工补录</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="checkInDlg.form.status" style="width: 100%">
            <el-option v-for="s in attStatus" :key="s.value" :label="s.label" :value="s.value" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer><el-button @click="checkInDlg.visible = false">取消</el-button><el-button type="primary" @click="submitCheckIn">登记</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'
import { attApi } from '@/api/biz'

const tab = ref('att')
const attStatus = [
  { label: '正常', value: 'normal' }, { label: '迟到', value: 'late' }, { label: '早退', value: 'early_leave' },
  { label: '缺勤', value: 'absent' }, { label: '请假', value: 'leave' }
]
const attLoading = ref(false)
const attList = ref<any[]>([])
const attTotal = ref(0)
const attQuery = reactive({ current: 1, size: 10, keyword: '', attDate: '', status: '' })

const leaveLoading = ref(false)
const leaveList = ref<any[]>([])
const leaveQuery = reactive({ current: 1, size: 10, approveStatus: '' })
const checkInDlg = reactive({ visible: false, form: {} as any })

function attName(s: string) { return attStatus.find((x) => x.value === s)?.label || s }
function tagType(s: string) {
  return { normal: 'success', leave: 'info', late: 'warning', early_leave: 'warning', absent: 'danger', skip: 'danger' }[s] || 'info'
}

function openCheckIn() { checkInDlg.form = { studentId: 1, attDate: '', signInTime: '', signOutTime: '', signInWay: 'card', status: 'normal' }; checkInDlg.visible = true }
async function submitCheckIn() {
  await attApi.checkIn(checkInDlg.form)
  ElMessage.success('考勤已登记（在校时长自动核算）')
  checkInDlg.visible = false
  loadAtt()
}
async function loadAtt() {
  attLoading.value = true
  try {
    const res = await attApi.pageStudent({ ...attQuery })
    attList.value = res.records
    attTotal.value = res.total
  } finally { attLoading.value = false }
}

async function loadLeave() {
  leaveLoading.value = true
  try {
    const res = await attApi.pageLeave({ ...leaveQuery })
    leaveList.value = res.records
  } finally { leaveLoading.value = false }
}

async function approve(row: any, status: string) {
  await attApi.leaveApprove({ id: row.id, approveStatus: status, remark: status === 'approved' ? '审批通过，自动同步缺勤记录' : '未通过，请补录考勤' })
  ElMessage.success('已' + (status === 'approved' ? '通过' : '驳回'))
  loadLeave()
}

onMounted(() => { loadAtt(); loadLeave() })
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>