<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">校</div>
          <div><h3>校区管理</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <span>机构：</span>
        <el-select v-model="orgId" style="width: 240px" @change="load">
          <el-option v-for="o in orgs" :key="o.id" :label="o.orgName" :value="o.id" />
        </el-select>
        <el-button type="success" :icon="Plus" @click="openDlg()">新增校区</el-button>
      </div>
      <el-table :data="list" border stripe>
        <el-table-column prop="campusCode" label="校区编码" width="130" />
        <el-table-column prop="campusName" label="校区名称" width="180" />
        <el-table-column prop="address" label="地址" min-width="200" />
        <el-table-column prop="contactName" label="负责人" width="100" />
        <el-table-column prop="contactPhone" label="联系电话" width="130" />
        <el-table-column label="主校区" width="90"><template #default="{ row }"><el-tag v-if="row.isMain === 1" type="success">主校区</el-tag></template></el-table-column>
        <el-table-column label="状态" width="80"><template #default="{ row }">{{ row.status === 1 ? '启用' : '停用' }}</template></el-table-column>
      </el-table>
    </el-card>
    <el-dialog v-model="dlg.visible" title="校区" width="480px">
      <el-form label-width="90px">
        <el-form-item label="校区编码"><el-input v-model="dlg.form.campusCode" /></el-form-item>
        <el-form-item label="校区名称"><el-input v-model="dlg.form.campusName" /></el-form-item>
        <el-form-item label="地址"><el-input v-model="dlg.form.address" /></el-form-item>
        <el-form-item label="负责人"><el-input v-model="dlg.form.contactName" /></el-form-item>
        <el-form-item label="联系电话"><el-input v-model="dlg.form.contactPhone" /></el-form-item>
        <el-form-item label="主校区"><el-switch v-model="dlg.form.isMain" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="dlg.visible = false">取消</el-button><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { platformApi } from '@/api/sys'
import { orgApi } from '@/api/org'

const orgs = ref<any[]>([])
const orgId = ref<number>()
const list = ref<any[]>([])
const dlg = reactive({ visible: false, form: {} as any })

async function loadOrgs() { const res = await orgApi.page({ current: 1, size: 50 }); orgs.value = res.records; orgId.value = orgs.value[0]?.id; if (orgId.value) load() }
async function load() { if (!orgId.value) return; list.value = await platformApi.listCampus(orgId.value) }
function openDlg() { dlg.form = { orgId: orgId.value, campusCode: '', campusName: '', address: '', contactName: '', contactPhone: '', isMain: 0, status: 1 }; dlg.visible = true }
async function save() { await platformApi.saveCampus(dlg.form); ElMessage.success('已保存'); dlg.visible = false; load() }
onMounted(loadOrgs)
</script>

<style scoped>.toolbar { display: flex; gap: 10px; margin-bottom: 14px; align-items: center; }</style>