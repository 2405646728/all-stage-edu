<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">班</div>
          <div><h3>班级架构</h3></div>
        </div>
    <el-row :gutter="12">
      <el-col :span="10">
        <el-card shadow="never" header="学年">
          <div class="toolbar">
            <el-button type="success" size="small" :icon="Plus" @click="openYear()">新增学年</el-button>
          </div>
          <el-table :data="years" border size="small">
            <el-table-column prop="yearName" label="学年名称" />
            <el-table-column prop="startDate" label="开始" width="100" />
            <el-table-column prop="endDate" label="结束" width="100" />
            <el-table-column label="状态" width="70">
              <template #default="{ row }">
                <el-tag size="small" :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '当前' : '其他' }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="14">
        <el-card shadow="never" header="年级">
          <div class="toolbar">
            <el-select v-model="yearFilter" placeholder="按学年筛选" clearable size="small" style="width: 160px" @change="loadGrades">
              <el-option v-for="y in years" :key="y.id" :label="y.yearName" :value="y.id" />
            </el-select>
            <el-button type="success" size="small" :icon="Plus" @click="openGrade()">新增年级</el-button>
          </div>
          <el-table :data="grades" border size="small">
            <el-table-column prop="gradeName" label="年级名称" width="120" />
            <el-table-column prop="gradeNo" label="序号" width="70" />
            <el-table-column prop="classCapacity" label="班级容量" width="90" />
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button link type="primary" @click="loadClasses(row.id)">查看班级</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" header="班级（当前选择年级）" style="margin-top: 12px">
      <div class="toolbar">
        <el-button type="success" size="small" :icon="Plus" @click="openClass()">新增班级</el-button>
      </div>
      <el-table :data="classes" border size="small">
        <el-table-column prop="className" label="班级名称" />
        <el-table-column prop="classType" label="班级类型" width="120">
          <template #default="{ row }">{{ { normal: '行政班', walk: '走班教学班', tier: '分层班', training: '实训班' }[row.classType] || row.classType }}</template>
        </el-table-column>
        <el-table-column prop="classCapacity" label="容量" width="80" />
        <el-table-column label="操作" width="140">
          <template #default="{ row }">
            <el-button link type="danger" @click="removeClass(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="yearDlg.visible" title="新增学年" width="420px">
      <el-form label-width="80px">
        <el-form-item label="学年名称"><el-input v-model="yearDlg.form.yearName" /></el-form-item>
        <el-form-item label="开始日期"><el-date-picker v-model="yearDlg.form.startDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" /></el-form-item>
        <el-form-item label="结束日期"><el-date-picker v-model="yearDlg.form.endDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="yearDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveYear">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="gradeDlg.visible" title="新增年级" width="420px">
      <el-form label-width="80px">
        <el-form-item label="年级名称"><el-input v-model="gradeDlg.form.gradeName" /></el-form-item>
        <el-form-item label="年级序号"><el-input-number v-model="gradeDlg.form.gradeNo" :min="1" /></el-form-item>
        <el-form-item label="班级容量"><el-input-number v-model="gradeDlg.form.classCapacity" :min="0" /></el-form-item>
        <el-form-item label="所属学年">
          <el-select v-model="gradeDlg.form.schoolYearId" style="width: 100%">
            <el-option v-for="y in years" :key="y.id" :label="y.yearName" :value="y.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="gradeDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveGrade">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="classDlg.visible" title="新增班级" width="420px">
      <el-form label-width="80px">
        <el-form-item label="班级名称"><el-input v-model="classDlg.form.className" /></el-form-item>
        <el-form-item label="班级类型">
          <el-select v-model="classDlg.form.classType" style="width: 100%">
            <el-option label="行政班" value="normal" />
            <el-option label="走班教学班" value="walk" />
            <el-option label="分层班" value="tier" />
            <el-option label="实训班" value="training" />
          </el-select>
        </el-form-item>
        <el-form-item label="班级容量"><el-input-number v-model="classDlg.form.classCapacity" :min="0" /></el-form-item>
        <el-form-item label="所属年级">
          <el-select v-model="classDlg.form.gradeId" style="width: 100%">
            <el-option v-for="g in grades" :key="g.id" :label="g.gradeName" :value="g.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="classDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveClass">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { schoolYearApi, gradeApi, classApi } from '@/api/base'

const years = ref<any[]>([])
const grades = ref<any[]>([])
const classes = ref<any[]>([])
const yearFilter = ref<number>()

const yearDlg = reactive({ visible: false, form: {} as any })
const gradeDlg = reactive({ visible: false, form: {} as any })
const classDlg = reactive({ visible: false, form: {} as any })

async function loadYears() { years.value = await schoolYearApi.list() }
async function loadGrades() { grades.value = await gradeApi.list(undefined, yearFilter.value) }
async function loadClasses(gradeId?: number) {
  if (!gradeId) { classes.value = []; return }
  classes.value = await classApi.list(undefined, gradeId)
}

function openYear() { yearDlg.form = { yearName: '', startDate: '', endDate: '', status: 1 }; yearDlg.visible = true }
async function saveYear() {
  await schoolYearApi.save(yearDlg.form)
  ElMessage.success('已保存'); yearDlg.visible = false; loadYears()
}
function openGrade() { gradeDlg.form = { gradeName: '', gradeNo: 1, classCapacity: 40, schoolYearId: years.value[0]?.id }; gradeDlg.visible = true }
async function saveGrade() {
  await gradeApi.save(gradeDlg.form)
  ElMessage.success('已保存'); gradeDlg.visible = false; loadGrades()
}
function openClass() { classDlg.form = { className: '', classType: 'normal', classCapacity: 40, gradeId: grades.value[0]?.id }; classDlg.visible = true }
async function saveClass() {
  await classApi.save(classDlg.form)
  ElMessage.success('已保存'); classDlg.visible = false; loadClasses(classDlg.form.gradeId)
}
async function removeClass(row: any) {
  await ElMessageBox.confirm('确认删除班级？', '提示', { type: 'warning' })
  await classApi.remove(row.id)
  ElMessage.success('已删除'); loadClasses(row.gradeId)
}

onMounted(() => { loadYears(); loadGrades() })
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 12px; }
</style>
