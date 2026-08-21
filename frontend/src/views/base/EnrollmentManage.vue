<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">学</div>
          <div><h3>学籍异动</h3></div>
        </div>
    <el-tabs v-model="tab">
      <!-- 学籍异动台账 -->
      <el-tab-pane label="学籍异动台账" name="change">
        <el-card shadow="never">
          <div class="toolbar">
            <el-input v-model="changeQuery.studentId" placeholder="学生ID(可空)" style="width: 140px" />
            <el-button type="primary" :icon="Search" @click="loadChanges">查询</el-button>
            <el-button type="success" :icon="Plus" @click="openChange">登记异动</el-button>
          </div>
          <el-table :data="changes" border stripe v-loading="changeLoading">
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column label="异动类型" width="110"><template #default="{ row }">{{ changeTypeName(row.changeType) }}</template></el-table-column>
            <el-table-column prop="beforeStatus" label="原状态" width="100" />
            <el-table-column prop="afterStatus" label="新状态" width="100" />
            <el-table-column prop="changeReason" label="事由" min-width="160" show-overflow-tooltip />
            <el-table-column prop="targetOrgName" label="目标学校" width="140" />
            <el-table-column label="审核" width="90"><template #default="{ row }"><el-tag :type="row.auditStatus === 'approved' ? 'success' : 'warning'">{{ { pending: '待审核', approved: '已通过', rejected: '已驳回' }[row.auditStatus] || row.auditStatus }}</el-tag></template></el-table-column>
            <el-table-column prop="createdAt" label="登记时间" width="170" />
          </el-table>
          <el-pagination v-model:current-page="changeQuery.current" v-model:page-size="changeQuery.size" :total="changeTotal" layout="total, prev, pager, next" @current-change="loadChanges" style="margin-top:12px;justify-content:flex-end" />
        </el-card>
      </el-tab-pane>
      <!-- 分班记录（升班/调班历史可追溯） -->
      <el-tab-pane label="分班记录" name="class">
        <el-card shadow="never">
          <div class="toolbar">
            <el-input v-model="classQuery.studentId" placeholder="学生ID(可空)" style="width: 140px" />
            <el-input v-model="classQuery.classId" placeholder="班级ID(可空)" style="width: 140px" />
            <el-button type="primary" :icon="Search" @click="loadClassRecords">查询</el-button>
          </div>
          <el-table :data="classRecords" border stripe v-loading="classLoading">
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="classId" label="班级ID" width="80" />
            <el-table-column prop="schoolYearId" label="学年ID" width="80" />
            <el-table-column label="入班方式" width="110"><template #default="{ row }">{{ { assigned: '智能分班', manual: '手动调班', transfer: '插班', promotion: '升班' }[row.enterType] || row.enterType }}</template></el-table-column>
            <el-table-column prop="enterDate" label="入班日期" width="110" />
            <el-table-column prop="leaveDate" label="离班日期" width="110" />
            <el-table-column label="状态" width="80"><template #default="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '在班' : '历史' }}</el-tag></template></el-table-column>
            <el-table-column prop="createdAt" label="记录时间" width="170" />
          </el-table>
          <el-pagination v-model:current-page="classQuery.current" v-model:page-size="classQuery.size" :total="classTotal" layout="total, prev, pager, next" @current-change="loadClassRecords" style="margin-top:12px;justify-content:flex-end" />
        </el-card>
      </el-tab-pane>
    </el-tabs>
    <el-dialog v-model="changeDlg.visible" title="学籍异动登记（审核备案留痕）" width="480px">
      <el-form label-width="90px">
        <el-form-item label="学生ID"><el-input-number v-model="changeDlg.form.studentId" :min="1" /></el-form-item>
        <el-form-item label="异动类型"><el-select v-model="changeDlg.form.changeType" style="width:100%"><el-option v-for="t in changeTypes" :key="t.value" :label="t.label" :value="t.value" /></el-select></el-form-item>
        <el-form-item label="异动事由"><el-input v-model="changeDlg.form.changeReason" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="目标学校"><el-input v-model="changeDlg.form.targetOrgName" placeholder="转入/转出时填写" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="changeDlg.visible = false">取消</el-button><el-button type="primary" @click="submitChange">登记</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'
import { studentApi } from '@/api/base'

const tab = ref('change')
const changeTypes = [
  { label: '转入', value: 'transfer_in' }, { label: '转出', value: 'transfer_out' }, { label: '休学', value: 'suspend' },
  { label: '复学', value: 'resume' }, { label: '留级', value: 'retain' }, { label: '跳级', value: 'skip' },
  { label: '毕业', value: 'graduate' }, { label: '退学', value: 'withdraw' }, { label: '注销', value: 'deregister' }
]
function changeTypeName(v: string) { return changeTypes.find((t) => t.value === v)?.label || v }

const changeLoading = ref(false)
const changes = ref<any[]>([])
const changeTotal = ref(0)
const changeQuery = reactive({ current: 1, size: 10, studentId: undefined as number | undefined })
const changeDlg = reactive({ visible: false, form: {} as any })

const classLoading = ref(false)
const classRecords = ref<any[]>([])
const classTotal = ref(0)
const classQuery = reactive({ current: 1, size: 10, studentId: undefined as number | undefined, classId: undefined as number | undefined })

async function loadChanges() { changeLoading.value = true; try { const res = await studentApi.pageStatusChange({ ...changeQuery }); changes.value = res.records; changeTotal.value = res.total } finally { changeLoading.value = false } }
async function loadClassRecords() { classLoading.value = true; try { const res = await studentApi.pageClassStudent({ ...classQuery }); classRecords.value = res.records; classTotal.value = res.total } finally { classLoading.value = false } }
function openChange() { changeDlg.form = { studentId: 1, changeType: 'suspend', changeReason: '', targetOrgName: '' }; changeDlg.visible = true }
async function submitChange() { await studentApi.enrollChange(changeDlg.form); ElMessage.success('异动已登记，学籍状态已同步'); changeDlg.visible = false; loadChanges() }
onMounted(() => { loadChanges(); loadClassRecords() })
</script>

<style scoped>.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }</style>