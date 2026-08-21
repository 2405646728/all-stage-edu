<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">健</div>
          <div><h3>健康档案</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <el-input v-model="studentId" placeholder="学生ID" style="width: 140px" />
        <el-button type="primary" :icon="Search" @click="load">查询健康档案</el-button>
      </div>
      <el-alert type="info" :closable="false" show-icon title="健康档案为隐私数据：仅管理员、班主任、校医可查看（文档 5.2.1-5），敏感字段应用层加密存储" style="margin-bottom: 14px" />
      <el-form v-if="form.studentId" :model="form" label-width="110px" class="health-form">
        <el-row :gutter="12">
          <el-col :span="12"><el-form-item label="过敏史"><el-input v-model="form.allergyHistory" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="既往病史"><el-input v-model="form.diseaseHistory" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="手术记录"><el-input v-model="form.surgeryHistory" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="体质备注"><el-input v-model="form.constitutionNote" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="饮食禁忌"><el-input v-model="form.dietTaboo" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="运动禁忌"><el-input v-model="form.sportTaboo" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="心理备注"><el-input v-model="form.psychologyNote" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="实训禁忌"><el-input v-model="form.trainingTaboo" placeholder="职高专业实训安全禁忌" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="血型"><el-input v-model="form.bloodType" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="身高(cm)"><el-input-number v-model="form.heightCm" :precision="1" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="体重(kg)"><el-input-number v-model="form.weightKg" :precision="1" /></el-form-item></el-col>
        </el-row>
        <el-button type="primary" @click="save">保存健康档案</el-button>
      </el-form>
      <el-empty v-else description="请输入学生ID查询健康档案" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { healthApi } from '@/api/base'

const studentId = ref<number>()
const form = reactive({ studentId: undefined as number | undefined, allergyHistory: '', diseaseHistory: '', surgeryHistory: '', constitutionNote: '', dietTaboo: '', sportTaboo: '', psychologyNote: '', trainingTaboo: '', bloodType: '', heightCm: undefined as number | undefined, weightKg: undefined as number | undefined })

async function load() {
  if (!studentId.value) { ElMessage.warning('请输入学生ID'); return }
  const data = await healthApi.get(studentId.value)
  if (data) Object.assign(form, data)
  else { Object.assign(form, { studentId: studentId.value, allergyHistory: '', diseaseHistory: '', surgeryHistory: '', constitutionNote: '', dietTaboo: '', sportTaboo: '', psychologyNote: '', trainingTaboo: '', bloodType: '', heightCm: undefined, weightKg: undefined }) }
  form.studentId = studentId.value
}
async function save() { await healthApi.save(form); ElMessage.success('健康档案已保存') }
</script>

<style scoped>.toolbar { display: flex; gap: 10px; margin-bottom: 14px; align-items: center; } .health-form { max-width: 860px; }</style>