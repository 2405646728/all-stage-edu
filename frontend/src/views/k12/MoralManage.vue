<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">德</div>
          <div><h3>德育综评</h3></div>
        </div>
    <el-tabs v-model="tab">
      <el-tab-pane label="德育奖惩" name="record">
        <el-card shadow="never">
          <div class="toolbar">
            <el-button type="success" :icon="Plus" @click="openRecord">登记奖惩</el-button>
          </div>
          <el-table :data="records" border stripe>
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column label="类型" width="90">
              <template #default="{ row }">{{ { reward: '奖励', punish: '违纪', rectify: '整改', good: '好事', civilized: '文明' }[row.recordType] || row.recordType }}</template>
            </el-table-column>
            <el-table-column prop="dimension" label="维度" width="100" />
            <el-table-column prop="score" label="积分" width="80" />
            <el-table-column prop="reason" label="事由" min-width="200" show-overflow-tooltip />
            <el-table-column prop="handleResult" label="处理结果" width="150" />
            <el-table-column prop="occurredAt" label="时间" width="170" />
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="班级考核" name="classEval">
        <el-card shadow="never">
          <el-table :data="classEvals" border stripe>
            <el-table-column prop="classId" label="班级ID" width="80" />
            <el-table-column prop="evalPeriod" label="周期" width="80" />
            <el-table-column prop="disciplineScore" label="纪律" width="70" />
            <el-table-column prop="hygieneScore" label="卫生" width="70" />
            <el-table-column prop="attendanceScore" label="出勤" width="70" />
            <el-table-column prop="activityScore" label="活动" width="70" />
            <el-table-column prop="studyStyleScore" label="学风" width="70" />
            <el-table-column prop="totalScore" label="总分" width="80" />
            <el-table-column prop="rankNo" label="排名" width="70" />
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="综合素质评价" name="eval">
        <el-card shadow="never">
          <div class="toolbar">
            <el-button type="success" :icon="Plus" @click="openEval">新增综评</el-button>
          </div>
          <el-table :data="evals" border stripe size="small">
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="moralityScore" label="思想品德" width="80" />
            <el-table-column prop="studyScore" label="学业水平" width="80" />
            <el-table-column prop="healthScore" label="身心健康" width="80" />
            <el-table-column prop="artScore" label="艺术素养" width="80" />
            <el-table-column prop="practiceScore" label="社会实践" width="80" />
            <el-table-column prop="totalScore" label="总分" width="80" />
            <el-table-column prop="evalStatus" label="状态" width="90">
              <template #default="{ row }">{{ { draft: '草稿', settled: '定稿', archived: '已归档' }[row.evalStatus] || row.evalStatus }}</template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="recordDlg.visible" title="登记德育奖惩" width="480px">
      <el-form label-width="90px">
        <el-form-item label="学生ID"><el-input-number v-model="recordDlg.form.studentId" :min="1" /></el-form-item>
        <el-form-item label="类型">
          <el-select v-model="recordDlg.form.recordType" style="width: 100%">
            <el-option label="奖励" value="reward" /><el-option label="违纪" value="punish" /><el-option label="整改" value="rectify" />
          </el-select>
        </el-form-item>
        <el-form-item label="维度">
          <el-select v-model="recordDlg.form.dimension" style="width: 100%">
            <el-option v-for="d in dimensions" :key="d.value" :label="d.label" :value="d.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="积分"><el-input-number v-model="recordDlg.form.score" :precision="1" /></el-form-item>
        <el-form-item label="事由"><el-input v-model="recordDlg.form.reason" type="textarea" :rows="2" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="recordDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveRecord">登记</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="evalDlg.visible" title="新增综评" width="520px">
      <el-form label-width="90px">
        <el-form-item label="学生ID"><el-input-number v-model="evalDlg.form.studentId" :min="1" /></el-form-item>
        <el-form-item label="思想品德"><el-input-number v-model="evalDlg.form.moralityScore" :min="0" :max="100" /></el-form-item>
        <el-form-item label="学业水平"><el-input-number v-model="evalDlg.form.studyScore" :min="0" :max="100" /></el-form-item>
        <el-form-item label="身心健康"><el-input-number v-model="evalDlg.form.healthScore" :min="0" :max="100" /></el-form-item>
        <el-form-item label="艺术素养"><el-input-number v-model="evalDlg.form.artScore" :min="0" :max="100" /></el-form-item>
        <el-form-item label="社会实践"><el-input-number v-model="evalDlg.form.practiceScore" :min="0" :max="100" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="evalDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveEval">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { moralApi } from '@/api/k12'

const tab = ref('record')
const dimensions = [
  { label: '纪律', value: 'discipline' }, { label: '卫生', value: 'hygiene' }, { label: '礼仪', value: 'etiquette' },
  { label: '学习', value: 'study' }, { label: '劳动', value: 'labor' }, { label: '安全', value: 'safety' },
  { label: '出勤', value: 'attendance' }, { label: '学风', value: 'style' }
]
const records = ref<any[]>([])
const classEvals = ref<any[]>([])
const evals = ref<any[]>([])
const recordDlg = reactive({ visible: false, form: {} as any })
const evalDlg = reactive({ visible: false, form: {} as any })

async function loadRecords() {
  const res = await moralApi.pageRecord({ current: 1, size: 20 })
  records.value = res.records
}
async function loadClassEvals() { classEvals.value = await moralApi.listClassEval({}) }
async function loadEvals() { evals.value = await moralApi.listEval({}) }

function openRecord() { recordDlg.form = { studentId: 1, recordType: 'reward', dimension: 'discipline', score: 2, reason: '' }; recordDlg.visible = true }
async function saveRecord() { await moralApi.saveRecord(recordDlg.form); ElMessage.success('已登记'); recordDlg.visible = false; loadRecords() }
function openEval() { evalDlg.form = { studentId: 1, moralityScore: 80, studyScore: 80, healthScore: 80, artScore: 80, practiceScore: 80 }; evalDlg.visible = true }
async function saveEval() {
  const f = evalDlg.form
  await moralApi.saveEval({ ...f, totalScore: f.moralityScore + f.studyScore + f.healthScore + f.artScore + f.practiceScore, evalStatus: 'settled' })
  ElMessage.success('综评已归档'); evalDlg.visible = false; loadEvals()
}

onMounted(() => { loadRecords(); loadClassEvals(); loadEvals() })
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>
