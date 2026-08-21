<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">高</div>
          <div><h3>高校管理</h3></div>
        </div>
    <el-tabs v-model="tab">
      <el-tab-pane label="选课与成绩" name="score">
        <el-card shadow="never">
          <div class="toolbar">
            <el-select v-model="offerFilter" placeholder="选择开课" clearable style="width: 240px">
              <el-option v-for="o in offers" :key="o.id" :label="o.courseNo" :value="o.id" />
            </el-select>
            <el-button type="primary" :icon="Search" @click="loadSelects">查询选课</el-button>
            <el-button type="success" :icon="Plus" @click="openSelect">学生选课</el-button>
          </div>
          <el-table :data="selects" border stripe size="small" style="margin-bottom: 12px">
            <el-table-column prop="studentId" label="学生ID" width="90" />
            <el-table-column prop="offerId" label="开课ID" width="90" />
            <el-table-column prop="termId" label="学期ID" width="80" />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="row.selectStatus === 'selected' ? 'success' : 'info'">
                  {{ { selected: '已选', dropped: '已退课', confirmed: '锁定' }[row.selectStatus] || row.selectStatus }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="selectTime" label="选课时间" width="170" />
          </el-table>
          <el-divider>成绩与绩点</el-divider>
          <div class="toolbar"><el-button type="success" size="small" :icon="Plus" @click="openScore">成绩录入</el-button></div>
          <el-table :data="scores" border stripe size="small">
            <el-table-column prop="studentId" label="学生ID" width="90" />
            <el-table-column prop="offerId" label="开课ID" width="90" />
            <el-table-column prop="totalScore" label="总成绩" width="90" />
            <el-table-column prop="gradePoint" label="绩点" width="80" />
            <el-table-column prop="credit" label="学分" width="70" />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="row.status === 'normal' ? 'success' : 'warning'">
                  {{ { normal: '正常', makeup: '补考', retake: '重修', passed: '通过', failed: '挂科' }[row.status] || row.status }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="综测与奖助" name="eval">
        <el-card shadow="never">
          <el-table :data="evals" border stripe size="small">
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="studyScore" label="学业" width="70" />
            <el-table-column prop="moralScore" label="德育" width="70" />
            <el-table-column prop="innovationScore" label="科创" width="70" />
            <el-table-column prop="sportScore" label="文体" width="70" />
            <el-table-column prop="volunteerScore" label="志愿" width="70" />
            <el-table-column prop="practiceScore" label="实践" width="70" />
            <el-table-column prop="totalScore" label="总分" width="80" />
            <el-table-column prop="rankNo" label="排名" width="70" />
          </el-table>
          <el-divider>奖学金</el-divider>
          <el-table :data="scholars" border stripe size="small">
            <el-table-column prop="projectName" label="项目" width="180" />
            <el-table-column prop="projectLevel" label="级别" width="90" />
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="amount" label="金额" width="100" />
            <el-table-column prop="status" label="状态" width="90" />
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="论文与学位" name="thesis">
        <el-card shadow="never">
          <el-table :data="theses" border stripe>
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="topic" label="论文选题" min-width="220" show-overflow-tooltip />
            <el-table-column prop="stage" label="进度" width="90" />
            <el-table-column prop="duplicateRate" label="查重率%" width="90" />
            <el-table-column label="查重" width="80">
              <template #default="{ row }">
                <el-tag :type="row.duplicatePass === 1 ? 'success' : 'danger'">{{ row.duplicatePass === 1 ? '合格' : '不合格' }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
          <el-divider>毕业学位预审</el-divider>
          <el-table :data="prechecks" border stripe size="small">
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="checkYear" label="年份" width="80" />
            <el-table-column prop="creditCheck" label="学分" width="80" />
            <el-table-column prop="gpaCheck" label="绩点" width="80" />
            <el-table-column prop="thesisCheck" label="论文" width="80" />
            <el-table-column prop="feeCheck" label="费用" width="80" />
            <el-table-column label="判定" width="120">
              <template #default="{ row }">
                <el-tag :type="row.overallResult === 'degree_qualified' ? 'success' : 'warning'">
                  {{ { pending: '预审中', graduate: '毕业合格', degree_qualified: '学位授予', extension: '延期毕业' }[row.overallResult] || row.overallResult }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="宿舍后勤" name="dorm">
        <el-card shadow="never">
          <el-table :data="buildings" border stripe size="small" style="margin-bottom: 10px">
            <el-table-column prop="buildingName" label="楼栋" width="140" />
            <el-table-column prop="dormType" label="类型" width="110" />
            <el-table-column prop="floors" label="楼层数" width="80" />
            <el-table-column prop="status" label="状态" width="70" />
          </el-table>
          <div class="toolbar"><el-button type="success" size="small" :icon="Plus" @click="openDorm">分配床位</el-button></div>
          <el-table :data="dormers" border stripe size="small">
            <el-table-column prop="studentId" label="学生ID" width="90" />
            <el-table-column prop="roomId" label="宿舍ID" width="90" />
            <el-table-column prop="bedId" label="床位ID" width="80" />
            <el-table-column prop="assignType" label="分配方式" width="100" />
            <el-table-column prop="checkInDate" label="入住日期" width="110" />
          </el-table>
          <el-divider>报修服务</el-divider>
          <el-table :data="repairs" border stripe size="small">
            <el-table-column prop="roomId" label="宿舍ID" width="90" />
            <el-table-column prop="repairType" label="类型" width="90" />
            <el-table-column prop="content" label="内容" min-width="160" />
            <el-table-column label="状态" width="110">
              <template #default="{ row }">
                <el-tag>{{ { pending: '待受理', dispatched: '已派单', repairing: '维修中', finished: '已完工', verified: '已验收' }[row.status] || row.status }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="selDlg.visible" title="学生选课/退课" width="440px">
      <el-form label-width="90px">
        <el-form-item label="学生ID"><el-input-number v-model="selDlg.form.studentId" :min="1" /></el-form-item>
        <el-form-item label="开课ID"><el-input-number v-model="selDlg.form.offerId" :min="1" /></el-form-item>
        <el-form-item label="学期ID"><el-input-number v-model="selDlg.form.termId" :min="1" /></el-form-item>
        <el-form-item label="状态"><el-select v-model="selDlg.form.selectStatus" style="width:100%"><el-option label="选课" value="selected" /><el-option label="退课" value="dropped" /></el-select></el-form-item>
      </el-form>
      <template #footer><el-button @click="selDlg.visible = false">取消</el-button><el-button type="primary" @click="saveSel">提交（容量自动校验）</el-button></template>
    </el-dialog>

    <el-dialog v-model="scoreDlg.visible" title="成绩与绩点录入" width="480px">
      <el-form label-width="90px">
        <el-form-item label="学生ID"><el-input-number v-model="scoreDlg.form.studentId" :min="1" /></el-form-item>
        <el-form-item label="开课ID"><el-input-number v-model="scoreDlg.form.offerId" :min="1" /></el-form-item>
        <el-form-item label="平时/期中/期末"><el-input-number v-model="scoreDlg.form.usualScore" :precision="1" style="width:130px" /> <el-input-number v-model="scoreDlg.form.examScore" :precision="1" style="width:130px" /> <el-input-number v-model="scoreDlg.form.practiceScore" :precision="1" style="width:130px" /></el-form-item>
        <el-form-item label="总成绩/绩点"><el-input-number v-model="scoreDlg.form.totalScore" :precision="1" style="width:130px" /> <el-input-number v-model="scoreDlg.form.gradePoint" :precision="2" style="width:130px" /></el-form-item>
        <el-form-item label="学分/状态"><el-input-number v-model="scoreDlg.form.credit" :precision="1" style="width:130px" /> <el-select v-model="scoreDlg.form.status" style="width:130px"><el-option label="正常" value="normal" /><el-option label="补考" value="makeup" /><el-option label="重修" value="retake" /></el-select></el-form-item>
      </el-form>
      <template #footer><el-button @click="scoreDlg.visible = false">取消</el-button><el-button type="primary" @click="saveScore">保存</el-button></template>
    </el-dialog>

    <el-dialog v-model="dormDlg.visible" title="住宿分配" width="440px">
      <el-form label-width="90px">
        <el-form-item label="学生ID"><el-input-number v-model="dormDlg.form.studentId" :min="1" /></el-form-item>
        <el-form-item label="宿舍ID"><el-input-number v-model="dormDlg.form.roomId" :min="1" /></el-form-item>
        <el-form-item label="床位ID"><el-input-number v-model="dormDlg.form.bedId" :min="1" /></el-form-item>
        <el-form-item label="学年ID"><el-input-number v-model="dormDlg.form.schoolYearId" :min="1" /></el-form-item>
        <el-form-item label="入住日期"><el-date-picker v-model="dormDlg.form.checkInDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="dormDlg.visible = false">取消</el-button><el-button type="primary" @click="saveDorm">分配（人数自动同步）</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search, Plus } from '@element-plus/icons-vue'
import { uniApi } from '@/api/uni'

const tab = ref('score')
const offers = ref<any[]>([])
const selects = ref<any[]>([])
const scores = ref<any[]>([])
const offerFilter = ref<number>()
const selDlg = reactive({ visible: false, form: {} as any })
const scoreDlg = reactive({ visible: false, form: {} as any })
const dormDlg = reactive({ visible: false, form: {} as any })

function openSelect() { selDlg.form = { studentId: 1, offerId: 1, termId: 1, selectStatus: 'selected' }; selDlg.visible = true }
async function saveSel() { await uniApi.saveSelect(selDlg.form); ElMessage.success('选课已提交'); selDlg.visible = false; loadSelects() }
function openScore() { scoreDlg.form = { studentId: 1, offerId: 1, usualScore: 80, examScore: 80, practiceScore: 80, totalScore: 80, gradePoint: 3.0, credit: 4, status: 'normal' }; scoreDlg.visible = true }
async function saveScore() { await uniApi.saveScore(scoreDlg.form); ElMessage.success('成绩已录入'); scoreDlg.visible = false; loadScores() }
function openDorm() { dormDlg.form = { studentId: 1, roomId: 1, bedId: 1, schoolYearId: 1, checkInDate: '', assignType: 'manual', status: 1 }; dormDlg.visible = true }
async function saveDorm() { await uniApi.assignDorm(dormDlg.form); ElMessage.success('床位已分配'); dormDlg.visible = false; loadDorm() }
const evals = ref<any[]>([])
const scholars = ref<any[]>([])
const theses = ref<any[]>([])
const prechecks = ref<any[]>([])
const buildings = ref<any[]>([])
const dormers = ref<any[]>([])
const repairs = ref<any[]>([])

async function loadOffers() { offers.value = await uniApi.listOffers({}) }
async function loadSelects() {
  if (!offerFilter.value) { selects.value = []; return }
  selects.value = await uniApi.listSelects({ offerId: offerFilter.value })
}
async function loadScores() {
  const r = await uniApi.pageScore({ current: 1, size: 50 })
  scores.value = r.records
}
async function loadEvals() { evals.value = await uniApi.listEvals({}) }
async function loadScholars() { scholars.value = await uniApi.listScholarships({}) }
async function loadTheses() { theses.value = await uniApi.listTheses({}) }
async function loadPrechecks() { prechecks.value = await uniApi.listPrechecks({}) }
async function loadDorm() {
  buildings.value = await uniApi.listBuildings()
  dormers.value = await uniApi.listDormStudents({})
  repairs.value = await uniApi.listRepairs({})
}

onMounted(() => { loadOffers(); loadScores(); loadEvals(); loadScholars(); loadTheses(); loadPrechecks(); loadDorm() })
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>