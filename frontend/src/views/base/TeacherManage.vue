<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">教</div>
          <div><h3>教师管理</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <el-input v-model="query.keyword" placeholder="姓名/工号/手机号" clearable style="width: 200px" @keyup.enter="load" />
        <el-select v-model="query.workStatus" placeholder="在职状态" clearable style="width: 130px">
          <el-option label="在职" value="active" /><el-option label="休假" value="leave" /><el-option label="离职" value="resigned" />
        </el-select>
        <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        <el-button type="success" :icon="Plus" @click="openDlg()">新增教师</el-button>
      </div>
      <el-table :data="list" border stripe v-loading="loading">
        <el-table-column prop="staffNo" label="工号" width="110" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column label="性别" width="70"><template #default="{ row }">{{ row.gender === 1 ? '男' : row.gender === 2 ? '女' : '-' }}</template></el-table-column>
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="education" label="学历" width="90" />
        <el-table-column prop="title" label="职称" width="110" />
        <el-table-column prop="hireDate" label="入职日期" width="110" />
        <el-table-column label="在职状态" width="90"><template #default="{ row }"><el-tag :type="row.workStatus === 'active' ? 'success' : 'info'">{{ { active: '在职', leave: '休假', resigned: '离职' }[row.workStatus] || row.workStatus }}</el-tag></template></el-table-column>
        <el-table-column label="操作" width="90" fixed="right"><template #default="{ row }"><el-button link type="danger" @click="remove(row)">删除</el-button></template></el-table-column>
      </el-table>
      <el-pagination v-model:current-page="query.current" v-model:page-size="query.size" :total="total" layout="total, prev, pager, next" @current-change="load" style="margin-top:12px;justify-content:flex-end" />
    </el-card>
    <el-dialog v-model="dlg.visible" title="教师信息" width="520px">
      <el-form :model="dlg.form" label-width="90px">
        <el-row :gutter="12">
          <el-col :span="12"><el-form-item label="工号" required><el-input v-model="dlg.form.staffNo" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="姓名" required><el-input v-model="dlg.form.name" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="性别"><el-radio-group v-model="dlg.form.gender"><el-radio :value="1">男</el-radio><el-radio :value="2">女</el-radio></el-radio-group></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="手机号"><el-input v-model="dlg.form.phone" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="学历"><el-input v-model="dlg.form.education" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="职称"><el-input v-model="dlg.form.title" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="入职日期"><el-date-picker v-model="dlg.form.hireDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item></el-col>
        </el-row>
      </el-form>
      <template #footer><el-button @click="dlg.visible = false">取消</el-button><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'
import { teacherApi } from '@/api/base'

const loading = ref(false)
const list = ref<any[]>([])
const total = ref(0)
const query = reactive({ current: 1, size: 10, keyword: '', workStatus: '' })
const dlg = reactive({ visible: false, form: {} as any })

async function load() {
  loading.value = true
  try { const res = await teacherApi.page({ ...query }); list.value = res.records; total.value = res.total } finally { loading.value = false }
}
function openDlg(row?: any) { dlg.form = row ? { ...row } : { staffNo: '', name: '', gender: 1, phone: '', education: '', title: '', hireDate: '', workStatus: 'active' }; dlg.visible = true }
async function save() { await teacherApi.save(dlg.form); ElMessage.success('已保存'); dlg.visible = false; load() }
async function remove(row: any) { await ElMessageBox.confirm('确认删除该教师？', '提示', { type: 'warning' }); await teacherApi.remove(row.id); ElMessage.success('已删除'); load() }
onMounted(load)
</script>

<style scoped>.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }</style>