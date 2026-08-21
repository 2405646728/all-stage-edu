<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">学</div>
          <div><h3>学生管理</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <el-input v-model="query.keyword" placeholder="姓名/学号/身份证" clearable style="width: 220px" @keyup.enter="load" />
        <el-select v-model="query.studyStatus" placeholder="就读状态" clearable style="width: 140px">
          <el-option label="在读" value="normal" />
          <el-option label="休学" value="suspended" />
          <el-option label="离园/离校" value="left" />
          <el-option label="毕业" value="graduated" />
        </el-select>
        <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        <el-button type="success" :icon="Plus" @click="openDialog()">新增学生</el-button>
        <el-button type="warning" :icon="Download" @click="exportCsv">导出学生台账</el-button>
      </div>
      <el-table :data="list" border stripe v-loading="loading" size="default">
        <el-table-column prop="studentNo" label="学号/园号" width="120" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column label="性别" width="70">
          <template #default="{ row }">{{ row.gender === 1 ? '男' : row.gender === 2 ? '女' : '-' }}</template>
        </el-table-column>
        <el-table-column prop="birthDate" label="出生日期" width="110" />
        <el-table-column prop="idCard" label="身份证号" min-width="160" show-overflow-tooltip />
        <el-table-column label="就读状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.studyStatus === 'normal' ? 'success' : 'warning'">{{ statusName(row.studyStatus) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="寄宿" width="70">
          <template #default="{ row }">{{ row.boarder === 1 ? '寄宿' : '走读' }}</template>
        </el-table-column>
        <el-table-column prop="createdAt" label="建档时间" width="170" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDialog(row)">编辑</el-button>
            <el-button link type="warning" @click="openChange(row)">学籍异动</el-button>
            <el-button link type="danger" @click="remove(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="query.current" v-model:page-size="query.size"
        :total="total" layout="total, prev, pager, next, sizes"
        :page-sizes="[10, 20, 50]" @current-change="load" @size-change="load"
        style="margin-top: 12px; justify-content: flex-end" />
    </el-card>

    <!-- 新增/编辑学生 -->
    <el-dialog v-model="dialog.visible" :title="dialog.form.id ? '编辑学生' : '新增学生'" width="640px">
      <el-form :model="dialog.form" label-width="90px">
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="学号/园号" required>
              <el-input v-model="dialog.form.studentNo" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="姓名" required>
              <el-input v-model="dialog.form.name" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别">
              <el-radio-group v-model="dialog.form.gender">
                <el-radio :value="1">男</el-radio>
                <el-radio :value="2">女</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="出生日期">
              <el-date-picker v-model="dialog.form.birthDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="身份证号">
              <el-input v-model="dialog.form.idCard" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="入园/入学日期">
              <el-date-picker v-model="dialog.form.admitDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="寄宿">
              <el-radio-group v-model="dialog.form.boarder">
                <el-radio :value="0">走读</el-radio>
                <el-radio :value="1">寄宿</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="当前班级">
              <el-select v-model="dialog.form.currentClassId" clearable style="width: 100%">
                <el-option v-for="c in classes" :key="c.id" :label="c.className" :value="c.id" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="生源信息">
              <el-input v-model="dialog.form.sourceDesc" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="dialog.saving" @click="save">保存</el-button>
      </template>
    </el-dialog>

    <!-- 学籍异动 -->
    <el-dialog v-model="change.visible" title="学籍异动登记" width="460px">
      <el-form label-width="90px">
        <el-form-item label="异动类型">
          <el-select v-model="change.form.changeType" style="width: 100%">
            <el-option label="休学" value="suspend" />
            <el-option label="复学" value="resume" />
            <el-option label="转出" value="transfer_out" />
            <el-option label="毕业" value="graduate" />
            <el-option label="退学" value="withdraw" />
            <el-option label="注销" value="deregister" />
          </el-select>
        </el-form-item>
        <el-form-item label="异动事由">
          <el-input v-model="change.form.changeReason" type="textarea" :rows="3" />
        </el-form-item>
        <el-form-item label="目标学校">
          <el-input v-model="change.form.targetOrgName" placeholder="转出时填写" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="change.visible = false">取消</el-button>
        <el-button type="primary" @click="submitChange">提交（审核备案留痕）</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Plus, Download } from '@element-plus/icons-vue'
import { studentApi, classApi } from '@/api/base'

const loading = ref(false)
const list = ref<any[]>([])
const total = ref(0)
const classes = ref<any[]>([])
const query = reactive({ current: 1, size: 10, keyword: '', studyStatus: '' })

const dialog = reactive({ visible: false, saving: false, form: {} as any })
const change = reactive({ visible: false, form: {} as any, student: null as any })

function statusName(s: string) {
  return { normal: '在读', suspended: '休学', left: '离园/离校', graduated: '毕业', withdrawn: '退学' }[s] || s
}

async function load() {
  loading.value = true
  try {
    const res = await studentApi.page({ ...query })
    list.value = res.records
    total.value = res.total
  } finally {
    loading.value = false
  }
}

async function loadClasses() {
  classes.value = await classApi.list()
}

function openDialog(row?: any) {
  dialog.form = row ? { ...row } : {
    studentNo: '', name: '', gender: 1, birthDate: '', idCard: '',
    admitDate: '', boarder: 0, currentClassId: undefined, sourceDesc: ''
  }
  dialog.visible = true
}

async function save() {
  if (!dialog.form.studentNo || !dialog.form.name) {
    ElMessage.warning('学号与姓名为必填项')
    return
  }
  dialog.saving = true
  try {
    if (dialog.form.id) {
      await studentApi.update(dialog.form.id, dialog.form)
    } else {
      await studentApi.create(dialog.form)
    }
    ElMessage.success('保存成功')
    dialog.visible = false
    load()
  } finally {
    dialog.saving = false
  }
}

async function remove(row: any) {
  await ElMessageBox.confirm('删除后将同步注销学籍，确认删除？', '提示', { type: 'warning' })
  await studentApi.remove(row.id)
  ElMessage.success('已删除')
  load()
}

function openChange(row: any) {
  change.student = row
  change.form = { studentId: row.id, changeType: 'suspend', changeReason: '', targetOrgName: '' }
  change.visible = true
}

async function submitChange() {
  await studentApi.enrollChange(change.form)
  ElMessage.success('异动已登记，学籍已同步')
  change.visible = false
  load()
}

function exportCsv() {
  const token = localStorage.getItem('asedu_token')
  fetch('/api/export/student', { headers: { Authorization: 'Bearer ' + token } })
    .then((res) => res.blob())
    .then((blob) => {
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.setAttribute('download', '学生台账.csv')
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    })
}

onMounted(() => {
  load()
  loadClasses()
})
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>