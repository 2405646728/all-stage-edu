<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">新</div>
          <div><h3>新高考选科走班</h3></div>
        </div>
    <el-tabs v-model="tab">
      <el-tab-pane label="选科管理" name="choice">
        <el-card shadow="never">
          <div class="toolbar">
            <el-select v-model="choiceFilter" placeholder="选科状态" clearable style="width: 140px">
              <el-option label="待审核" value="pending" /><el-option label="已确认" value="confirmed" /><el-option label="已锁定" value="locked" />
            </el-select>
            <el-button type="primary" :icon="Search" @click="loadChoices">查询</el-button>
          </div>
          <el-table :data="choices" border stripe>
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="comboCode" label="组合" width="90" />
            <el-table-column prop="comboDetail" label="组合明细" width="150" />
            <el-table-column prop="choiceRound" label="轮次" width="70" />
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.status === 'confirmed' ? 'success' : row.status === 'locked' ? 'primary' : 'warning'">
                  {{ { pending: '待审核', confirmed: '已确认', locked: '已锁定' }[row.status] || row.status }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120">
              <template #default="{ row }">
                <el-button v-if="row.status === 'pending'" link type="primary" @click="audit(row)">审核确认</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="选科规则" name="rule">
        <el-card shadow="never">
          <el-table :data="rules" border stripe>
            <el-table-column prop="ruleMode" label="模式" width="90" />
            <el-table-column prop="gradeId" label="年级ID" width="80" />
            <el-table-column prop="validCombos" label="合规组合" min-width="260" show-overflow-tooltip />
            <el-table-column prop="selectStart" label="开始时间" width="170" />
            <el-table-column prop="selectEnd" label="截止时间" width="170" />
            <el-table-column label="通道" width="80">
              <template #default="{ row }">
                <el-tag :type="row.openStatus === 1 ? 'success' : 'info'">{{ row.openStatus === 1 ? '开启' : '关闭' }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="高考备考" name="prep">
        <el-card shadow="never">
          <el-table :data="preps" border stripe>
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="targetSchool" label="目标院校" width="140" />
            <el-table-column prop="prepPlan" label="备考计划" min-width="200" show-overflow-tooltip />
            <el-table-column prop="registerQualify" label="报名预审" width="100" />
            <el-table-column prop="mockSummary" label="模考摘要" min-width="160" show-overflow-tooltip />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">{{ { preparing: '备考中', tracking: '跟踪中', finished: '已结束' }[row.prepStatus] || row.prepStatus }}</template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { highApi } from '@/api/stage'

const tab = ref('choice')
const choices = ref<any[]>([])
const rules = ref<any[]>([])
const preps = ref<any[]>([])
const choiceFilter = ref('')

async function loadChoices() {
  const res = await highApi.pageChoice({ current: 1, size: 50, status: choiceFilter.value })
  choices.value = res.records
}
async function loadRules() { rules.value = await highApi.listRules({}) }
async function loadPreps() { preps.value = await highApi.listPrep({}) }

async function audit(row: any) {
  await highApi.auditChoice({ id: row.id, status: 'confirmed', remark: '选科合规性校验通过' })
  ElMessage.success('选科已确认')
  loadChoices()
}

onMounted(() => { loadChoices(); loadRules(); loadPreps() })
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>
