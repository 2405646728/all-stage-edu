<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">监</div>
          <div><h3>监护人管理</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <el-input v-model="query.keyword" placeholder="姓名/手机号" clearable style="width: 200px" @keyup.enter="load" />
        <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        <el-button type="success" :icon="Plus" @click="openDlg()">新增监护人</el-button>
      </div>
      <el-table :data="list" border stripe v-loading="loading">
        <el-table-column prop="name" label="姓名" width="120" />
        <el-table-column prop="phone" label="手机号" width="140" />
        <el-table-column label="关系" width="110"><template #default="{ row }">{{ relationName(row.relation) }}</template></el-table-column>
        <el-table-column label="紧急联系人" width="110"><template #default="{ row }"><el-tag v-if="row.isEmergency === 1" type="danger">紧急</el-tag></template></el-table-column>
        <el-table-column prop="workInfo" label="工作信息" min-width="160" />
        <el-table-column label="绑定学生" width="140"><template #default="{ row }"><el-button link type="primary" @click="bindStudent(row)">绑定学生</el-button></template></el-table-column>
      </el-table>
      <el-pagination v-model:current-page="query.current" v-model:page-size="query.size" :total="total" layout="total, prev, pager, next" @current-change="load" style="margin-top:12px;justify-content:flex-end" />
    </el-card>
    <el-dialog v-model="dlg.visible" title="监护人信息" width="480px">
      <el-form :model="dlg.form" label-width="90px">
        <el-form-item label="姓名" required><el-input v-model="dlg.form.name" /></el-form-item>
        <el-form-item label="手机号" required><el-input v-model="dlg.form.phone" /></el-form-item>
        <el-form-item label="关系"><el-select v-model="dlg.form.relation" style="width:100%"><el-option label="父亲" value="father" /><el-option label="母亲" value="mother" /><el-option label="祖父" value="grandfather" /><el-option label="祖母" value="grandmother" /><el-option label="其他" value="other" /></el-select></el-form-item>
        <el-form-item label="紧急联系人"><el-switch v-model="dlg.form.isEmergency" :active-value="1" :inactive-value="0" /></el-form-item>
        <el-form-item label="工作信息"><el-input v-model="dlg.form.workInfo" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="dlg.visible = false">取消</el-button><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>
    <el-dialog v-model="bindDlg.visible" title="绑定学生" width="420px">
      <el-form label-width="90px">
        <el-form-item label="学生ID"><el-input-number v-model="bindDlg.studentId" :min="1" /></el-form-item>
        <el-form-item label="第一监护人"><el-switch v-model="bindDlg.isPrimary" :active-value="1" :inactive-value="0" /></el-form-item>
        <el-form-item label="授权接送"><el-switch v-model="bindDlg.canPickup" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="bindDlg.visible = false">取消</el-button><el-button type="primary" @click="doBind">绑定</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'
import { guardianApi } from '@/api/base'

const loading = ref(false)
const list = ref<any[]>([])
const total = ref(0)
const query = reactive({ current: 1, size: 10, keyword: '' })
const dlg = reactive({ visible: false, form: {} as any })
const bindDlg = reactive({ visible: false, guardian: null as any, studentId: 1, isPrimary: 0, canPickup: 1 })

function relationName(v: string) { return { father: '父亲', mother: '母亲', grandfather: '祖父', grandmother: '祖母', other: '其他' }[v] || v }
async function load() { loading.value = true; try { const res = await guardianApi.page({ ...query }); list.value = res.records; total.value = res.total } finally { loading.value = false } }
function openDlg(row?: any) { dlg.form = row ? { ...row } : { name: '', phone: '', relation: 'father', isEmergency: 0, workInfo: '' }; dlg.visible = true }
async function save() { await guardianApi.save(dlg.form); ElMessage.success('已保存'); dlg.visible = false; load() }
function bindStudent(row: any) { bindDlg.guardian = row; bindDlg.visible = true }
async function doBind() {
  await guardianApi.bind({ studentId: bindDlg.studentId, guardianId: bindDlg.guardian.id, isPrimary: bindDlg.isPrimary, canPickup: bindDlg.canPickup })
  ElMessage.success('绑定成功'); bindDlg.visible = false
}
onMounted(load)
</script>

<style scoped>.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }</style>