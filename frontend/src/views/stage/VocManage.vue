<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">职</div>
          <div><h3>职高实训就业</h3></div>
        </div>
    <el-tabs v-model="tab">
      <el-tab-pane label="专业实训" name="training">
        <el-card shadow="never">
          <el-table :data="plans" border stripe>
            <el-table-column prop="projectName" label="实训项目" width="160" />
            <el-table-column prop="classId" label="班级ID" width="80" />
            <el-table-column prop="majorId" label="专业ID" width="80" />
            <el-table-column prop="teacherId" label="指导教师" width="90" />
            <el-table-column prop="startDate" label="开始" width="100" />
            <el-table-column prop="endDate" label="结束" width="100" />
          </el-table>
          <el-divider>实训过程记录</el-divider>
          <el-table :data="records" border stripe size="small">
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="trainingDate" label="日期" width="100" />
            <el-table-column prop="operationNote" label="实操记录" min-width="200" show-overflow-tooltip />
            <el-table-column prop="operationScore" label="评分" width="70" />
            <el-table-column prop="attendance" label="在岗" width="70" />
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="设备管理" name="device">
        <el-card shadow="never">
          <div class="toolbar"><el-button type="success" size="small" :icon="Plus" @click="openDevice">新增设备</el-button></div>
          <el-table :data="devices" border stripe>
            <el-table-column prop="deviceCode" label="设备编码" width="130" />
            <el-table-column prop="deviceName" label="设备名称" width="120" />
            <el-table-column prop="deviceModel" label="型号" width="100" />
            <el-table-column prop="siteId" label="场地ID" width="80" />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="row.status === 'idle' ? 'success' : row.status === 'in_use' ? 'warning' : 'info'">
                  {{ { idle: '闲置', in_use: '使用中', maintenance: '维保', borrowed: '已借出', scrapped: '已报废' }[row.status] || row.status }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="考证与校企" name="cert">
        <el-card shadow="never">
          <el-table :data="certs" border stripe size="small">
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="certName" label="证书" width="170" />
            <el-table-column prop="certLevel" label="等级" width="90" />
            <el-table-column prop="examDate" label="考试日期" width="100" />
            <el-table-column label="结果" width="80">
              <template #default="{ row }">
                <el-tag :type="row.result === 'passed' ? 'success' : row.result === 'failed' ? 'danger' : 'info'">
                  {{ { passed: '通过', failed: '未通过', pending: '待考' }[row.result] || row.result }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
          <el-divider>校企合作单位</el-divider>
          <el-table :data="companies" border stripe size="small">
            <el-table-column prop="companyName" label="企业名称" width="220" />
            <el-table-column prop="coopProject" label="合作项目" width="180" />
            <el-table-column prop="postDesc" label="实训岗位" width="130" />
            <el-table-column prop="mentorName" label="企业导师" width="100" />
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="实习就业" name="intern">
        <el-card shadow="never">
          <div class="toolbar"><el-button type="success" size="small" :icon="Plus" @click="openCheckin">实习打卡</el-button></div>
          <el-table :data="interns" border stripe>
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="postName" label="实习岗位" width="130" />
            <el-table-column prop="companyId" label="单位ID" width="80" />
            <el-table-column prop="startDate" label="开始" width="100" />
            <el-table-column prop="companyScore" label="企业评分" width="90" />
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.internStatus === 'ongoing' ? 'success' : row.internStatus === 'abnormal' ? 'danger' : 'info'">
                  {{ { reported: '已报备', assigned: '已分配', ongoing: '实习中', finished: '已结业', abnormal: '异常离岗' }[row.internStatus] || row.internStatus }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="deviceDlg.visible" title="实训设备" width="480px">
      <el-form label-width="90px">
        <el-form-item label="设备编码"><el-input v-model="deviceDlg.form.deviceCode" /></el-form-item>
        <el-form-item label="设备名称"><el-input v-model="deviceDlg.form.deviceName" /></el-form-item>
        <el-form-item label="型号"><el-input v-model="deviceDlg.form.deviceModel" /></el-form-item>
        <el-form-item label="所属场地ID"><el-input-number v-model="deviceDlg.form.siteId" :min="1" /></el-form-item>
        <el-form-item label="状态"><el-select v-model="deviceDlg.form.status" style="width:100%"><el-option label="闲置" value="idle" /><el-option label="使用中" value="in_use" /><el-option label="维保" value="maintenance" /></el-select></el-form-item>
      </el-form>
      <template #footer><el-button @click="deviceDlg.visible = false">取消</el-button><el-button type="primary" @click="saveDevice">保存</el-button></template>
    </el-dialog>

    <el-dialog v-model="checkinDlg.visible" title="顶岗实习打卡" width="460px">
      <el-form label-width="100px">
        <el-form-item label="实习记录ID"><el-input-number v-model="checkinDlg.form.internshipId" :min="1" /></el-form-item>
        <el-form-item label="打卡日期"><el-date-picker v-model="checkinDlg.form.checkinDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="打卡时间"><el-date-picker v-model="checkinDlg.form.checkinTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" /></el-form-item>
        <el-form-item label="打卡地点"><el-input v-model="checkinDlg.form.location" placeholder="企业定位/人工补录" /></el-form-item>
        <el-form-item label="状态"><el-select v-model="checkinDlg.form.status" style="width:100%"><el-option label="在岗" value="on_duty" /><el-option label="离岗报备" value="leave" /><el-option label="缺勤" value="absent" /></el-select></el-form-item>
      </el-form>
      <template #footer><el-button @click="checkinDlg.visible = false">取消</el-button><el-button type="primary" @click="saveCheckin">打卡</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { vocApi } from '@/api/stage'

const tab = ref('training')
const plans = ref<any[]>([])
const records = ref<any[]>([])
const devices = ref<any[]>([])
const certs = ref<any[]>([])
const companies = ref<any[]>([])
const interns = ref<any[]>([])
const deviceDlg = reactive({ visible: false, form: {} as any })
const checkinDlg = reactive({ visible: false, form: {} as any })

function openDevice() { deviceDlg.form = { deviceCode: '', deviceName: '', deviceModel: '', siteId: 1, status: 'idle' }; deviceDlg.visible = true }
async function saveDevice() { await vocApi.saveDevice(deviceDlg.form); ElMessage.success('设备已登记'); deviceDlg.visible = false; loadAll() }
function openCheckin() { checkinDlg.form = { internshipId: 1, checkinDate: '', checkinTime: '', location: '', checkinWay: 'app', status: 'on_duty' }; checkinDlg.visible = true }
async function saveCheckin() { await vocApi.saveCheckin(checkinDlg.form); ElMessage.success('打卡成功'); checkinDlg.visible = false }

async function loadAll() {
  plans.value = await vocApi.listPlans({})
  const r = await vocApi.pageRecords({ current: 1, size: 50 })
  records.value = r.records
  devices.value = await vocApi.listDevices({})
  certs.value = await vocApi.listCertificates({})
  companies.value = await vocApi.listCompanies()
  const i = await vocApi.pageInternships({ current: 1, size: 50 })
  interns.value = i.records
}

onMounted(loadAll)
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>