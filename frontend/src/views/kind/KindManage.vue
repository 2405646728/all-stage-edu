<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">幼</div>
          <div><h3>幼儿园专属管理</h3></div>
        </div>
    <el-tabs v-model="tab">
      <!-- 接送安全 -->
      <el-tab-pane label="接送管理" name="pickup">
        <el-card shadow="never">
          <div class="toolbar">
            <el-button type="success" :icon="Plus" @click="openAuth">新增接送授权</el-button>
          </div>
          <el-table :data="auths" border stripe>
            <el-table-column prop="studentId" label="幼儿ID" width="80" />
            <el-table-column label="类型" width="90">
              <template #default="{ row }">{{ row.pickupType === 'fixed' ? '固定接送' : '临时接送' }}</template>
            </el-table-column>
            <el-table-column prop="tempName" label="临时接送人" width="110">
              <template #default="{ row }">{{ row.tempName || (row.guardianId ? '监护人#' + row.guardianId : '') }}</template>
            </el-table-column>
            <el-table-column prop="tempPhone" label="联系电话" width="130" />
            <el-table-column prop="validUntil" label="有效期截止" width="170" />
            <el-table-column label="审批" width="110">
              <template #default="{ row }">
                <el-tag :type="row.approveStatus === 'approved' ? 'success' : 'warning'">
                  {{ { pending: '待核验', approved: '已核验', rejected: '已驳回' }[row.approveStatus] }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="130">
              <template #default="{ row }">
                <el-button v-if="row.approveStatus === 'pending'" link type="primary" @click="approveAuth(row)">核验通过</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-divider />
          <div class="toolbar">
            <el-input v-model="pickupQuery.keyword" placeholder="接送人/幼儿姓名" clearable style="width: 180px" @keyup.enter="loadRecords" />
            <el-button type="primary" :icon="Search" @click="loadRecords">查询</el-button>
          </div>
          <el-table :data="records" border stripe size="small">
            <el-table-column prop="pickupName" label="接送人" width="110" />
            <el-table-column prop="studentId" label="幼儿ID" width="80" />
            <el-table-column prop="pickupTime" label="接送时间" width="170" />
            <el-table-column prop="direction" label="方向" width="70">
              <template #default="{ row }">{{ row.direction === 'out' ? '离园接走' : '送园' }}</template>
            </el-table-column>
            <el-table-column prop="verifyWay" label="核验方式" width="100" />
            <el-table-column label="结果" width="120">
              <template #default="{ row }">
                <el-tag :type="row.verifyResult === 'passed' ? 'success' : 'warning'">
                  {{ { passed: '匹配放行', failed: '拦截', manual_verify: '人工核验放行' }[row.verifyResult] || row.verifyResult }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="预警" width="70">
              <template #default="{ row }">
                <el-tag v-if="row.isAlert === 1" type="danger">红色预警</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <!-- 餐食公示 -->
      <el-tab-pane label="餐食公示" name="meal">
        <el-card shadow="never">
          <div class="toolbar">
            <el-date-picker v-model="mealDate" type="date" value-format="YYYY-MM-DD" style="width: 150px" @change="loadMeals" />
            <el-button type="success" :icon="Plus" @click="openMeal">录入餐食</el-button>
          </div>
          <el-table :data="meals" border stripe>
            <el-table-column label="餐次" width="90">
              <template #default="{ row }">{{ { breakfast: '早餐', lunch: '午餐', dinner: '晚餐', snack: '加餐' }[row.mealType] || row.mealType }}</template>
            </el-table-column>
            <el-table-column prop="menuContent" label="餐食清单" min-width="200" />
            <el-table-column prop="nutritionNote" label="营养配比" width="180" />
            <el-table-column prop="tabooNote" label="禁忌提示" min-width="180" />
          </el-table>
        </el-card>
      </el-tab-pane>

      <!-- 晨午检 -->
      <el-tab-pane label="晨午检" name="health">
        <el-card shadow="never">
          <div class="toolbar">
            <el-date-picker v-model="checkDate" type="date" value-format="YYYY-MM-DD" style="width: 150px" @change="loadChecks" />
            <el-button type="success" :icon="Plus" @click="openCheck">登记晨午检</el-button>
            <el-button type="danger" :icon="Plus" @click="openAbnormal">异常健康上报</el-button>
            <el-button type="warning" :icon="Plus" @click="openInspect">安全巡查上报</el-button>
          </div>
          <el-table :data="checks" border stripe size="small">
            <el-table-column prop="studentId" label="幼儿ID" width="80" />
            <el-table-column prop="checkType" label="类型" width="80">
              <template #default="{ row }">{{ row.checkType === 'morning' ? '晨检' : '午检' }}</template>
            </el-table-column>
            <el-table-column prop="temperature" label="体温" width="80" />
            <el-table-column prop="mentalState" label="精神状态" width="100" />
            <el-table-column prop="symptom" label="症状" min-width="140" />
            <el-table-column label="异常" width="80">
              <template #default="{ row }">
                <el-tag v-if="row.isAbnormal === 1" type="danger">异常</el-tag>
                <span v-else style="color: #67c23a">正常</span>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <!-- 成长纪实 -->
      <el-tab-pane label="成长纪实" name="growth">
        <el-card shadow="never">
          <div class="toolbar">
            <el-button type="success" :icon="Plus" @click="openGrowth">发布成长动态</el-button>
            <el-button @click="openNap">午休记录</el-button>
          </div>
          <el-table :data="growths" border stripe>
            <el-table-column prop="studentId" label="幼儿ID" width="80" />
            <el-table-column prop="recordType" label="类型" width="120" />
            <el-table-column prop="title" label="标题" width="180" />
            <el-table-column prop="content" label="内容" min-width="240" show-overflow-tooltip />
            <el-table-column prop="createdAt" label="发布时间" width="170" />
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="authDlg.visible" title="新增接送授权" width="460px">
      <el-form label-width="100px">
        <el-form-item label="幼儿ID"><el-input-number v-model="authDlg.form.studentId" :min="1" /></el-form-item>
        <el-form-item label="类型">
          <el-radio-group v-model="authDlg.form.pickupType">
            <el-radio value="temp">临时接送</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="接送人姓名"><el-input v-model="authDlg.form.tempName" /></el-form-item>
        <el-form-item label="手机号"><el-input v-model="authDlg.form.tempPhone" /></el-form-item>
        <el-form-item label="有效期">
          <el-date-picker v-model="authDlg.form.validUntil" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width: 100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="authDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveAuth">保存（待班主任核验）</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="mealDlg.visible" title="录入餐食" width="500px">
      <el-form label-width="90px">
        <el-form-item label="日期"><el-date-picker v-model="mealDlg.form.mealDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" /></el-form-item>
        <el-form-item label="餐次">
          <el-select v-model="mealDlg.form.mealType" style="width: 100%">
            <el-option label="早餐" value="breakfast" /><el-option label="午餐" value="lunch" />
            <el-option label="晚餐" value="dinner" /><el-option label="加餐" value="snack" />
          </el-select>
        </el-form-item>
        <el-form-item label="餐食清单"><el-input v-model="mealDlg.form.menuContent" /></el-form-item>
        <el-form-item label="营养配比"><el-input v-model="mealDlg.form.nutritionNote" /></el-form-item>
        <el-form-item label="禁忌提示"><el-input v-model="mealDlg.form.tabooNote" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="mealDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveMeal">发布</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="checkDlg.visible" title="登记晨午检" width="460px">
      <el-form label-width="90px">
        <el-form-item label="幼儿ID"><el-input-number v-model="checkDlg.form.studentId" :min="1" /></el-form-item>
        <el-form-item label="日期"><el-date-picker v-model="checkDlg.form.checkDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" /></el-form-item>
        <el-form-item label="类型">
          <el-radio-group v-model="checkDlg.form.checkType">
            <el-radio value="morning">晨检</el-radio><el-radio value="noon">午检</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="体温"><el-input-number v-model="checkDlg.form.temperature" :precision="1" :step="0.1" :min="35" :max="42" /></el-form-item>
        <el-form-item label="症状"><el-input v-model="checkDlg.form.symptom" placeholder="无则留空" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="checkDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveCheck">登记</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="napDlg.visible" title="午休记录" width="420px">
      <el-form label-width="90px">
        <el-form-item label="幼儿ID"><el-input-number v-model="napDlg.form.studentId" :min="1" /></el-form-item>
        <el-form-item label="日期"><el-date-picker v-model="napDlg.form.napDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" /></el-form-item>
        <el-form-item label="入睡时长"><el-input-number v-model="napDlg.form.sleepMinutes" :min="0" /> 分钟</el-form-item>
        <el-form-item label="状态"><el-select v-model="napDlg.form.napStatus" style="width: 100%"><el-option label="正常" value="normal" /><el-option label="入睡困难" value="difficult" /><el-option label="未睡" value="awake" /></el-select></el-form-item>
        <el-form-item label="表现"><el-input v-model="napDlg.form.performance" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="napDlg.visible = false">取消</el-button><el-button type="primary" @click="saveNap">保存</el-button></template>
    </el-dialog>

    <el-dialog v-model="abnormalDlg.visible" title="异常健康上报" width="460px">
      <el-form label-width="90px">
        <el-form-item label="幼儿ID"><el-input-number v-model="abnormalDlg.form.studentId" :min="1" /></el-form-item>
        <el-form-item label="症状"><el-input v-model="abnormalDlg.form.symptom" placeholder="发热/咳嗽/呕吐/外伤等" /></el-form-item>
        <el-form-item label="处理措施"><el-input v-model="abnormalDlg.form.handleMeasure" /></el-form-item>
        <el-form-item label="跟进记录"><el-input v-model="abnormalDlg.form.followNote" type="textarea" :rows="2" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="abnormalDlg.visible = false">取消</el-button><el-button type="primary" @click="saveAbnormal">上报</el-button></template>
    </el-dialog>

    <el-dialog v-model="inspectDlg.visible" title="安全巡查隐患上报" width="480px">
      <el-form label-width="90px">
        <el-form-item label="隐患描述"><el-input v-model="inspectDlg.form.hazardDesc" /></el-form-item>
        <el-form-item label="隐患位置"><el-input v-model="inspectDlg.form.location" /></el-form-item>
        <el-form-item label="风险等级"><el-select v-model="inspectDlg.form.riskLevel" style="width: 100%"><el-option label="一般" value="low" /><el-option label="较大" value="medium" /><el-option label="重大" value="high" /></el-select></el-form-item>
        <el-form-item label="整改时限"><el-date-picker v-model="inspectDlg.form.rectifyDeadline" type="date" value-format="YYYY-MM-DD" style="width: 100%" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="inspectDlg.visible = false">取消</el-button><el-button type="primary" @click="saveInspect">上报（整改闭环）</el-button></template>
    </el-dialog>

    <el-dialog v-model="growthDlg.visible" title="发布成长动态" width="500px">
      <el-form label-width="90px">
        <el-form-item label="幼儿ID"><el-input-number v-model="growthDlg.form.studentId" :min="1" /></el-form-item>
        <el-form-item label="类型">
          <el-select v-model="growthDlg.form.recordType" style="width: 100%">
            <el-option label="课堂纪实" value="class_photo" /><el-option label="课堂表现" value="performance" />
            <el-option label="阶段性点评" value="comment" /><el-option label="成长相册" value="album" />
          </el-select>
        </el-form-item>
        <el-form-item label="标题"><el-input v-model="growthDlg.form.title" /></el-form-item>
        <el-form-item label="内容"><el-input v-model="growthDlg.form.content" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="growthDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveGrowth">发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'
import { kindApi } from '@/api/kind'

const tab = ref('pickup')
const auths = ref<any[]>([])
const records = ref<any[]>([])
const pickupQuery = reactive({ current: 1, size: 10, keyword: '' })
const meals = ref<any[]>([])
const mealDate = ref('2025-09-08')
const checks = ref<any[]>([])
const checkDate = ref('2025-09-08')
const growths = ref<any[]>([])

const authDlg = reactive({ visible: false, form: {} as any })
const mealDlg = reactive({ visible: false, form: {} as any })
const checkDlg = reactive({ visible: false, form: {} as any })
const growthDlg = reactive({ visible: false, form: {} as any })
const napDlg = reactive({ visible: false, form: {} as any })
const abnormalDlg = reactive({ visible: false, form: {} as any })
const inspectDlg = reactive({ visible: false, form: {} as any })

async function loadAuths() { auths.value = await kindApi.listPickupAuth({}) }
async function loadRecords() {
  const res = await kindApi.pagePickupRecord({ ...pickupQuery })
  records.value = res.records
}
async function loadMeals() { meals.value = await kindApi.listMeal({ mealDate: mealDate.value }) }
async function loadChecks() { checks.value = await kindApi.listHealthCheck({ checkDate: checkDate.value }) }
async function loadGrowths() {
  const res = await kindApi.pageGrowth({ current: 1, size: 20 })
  growths.value = res.records
}

function openAuth() { authDlg.form = { studentId: 1, pickupType: 'temp', tempName: '', tempPhone: '', validUntil: '' }; authDlg.visible = true }
async function saveAuth() { await kindApi.savePickupAuth(authDlg.form); ElMessage.success('已提交，待班主任核验'); authDlg.visible = false; loadAuths() }
async function approveAuth(row: any) { await kindApi.approvePickupAuth({ id: row.id, approveStatus: 'approved' }); ElMessage.success('核验通过'); loadAuths() }

function openMeal() { mealDlg.form = { mealDate: mealDate.value, mealType: 'breakfast', menuContent: '', nutritionNote: '', tabooNote: '' }; mealDlg.visible = true }
async function saveMeal() { await kindApi.saveMeal(mealDlg.form); ElMessage.success('已发布'); mealDlg.visible = false; loadMeals() }

function openCheck() { checkDlg.form = { studentId: 1, checkDate: checkDate.value, checkType: 'morning', temperature: 36.5, symptom: '' }; checkDlg.visible = true }
async function saveCheck() { await kindApi.saveHealthCheck(checkDlg.form); ElMessage.success('已登记'); checkDlg.visible = false; loadChecks() }

function openNap() { napDlg.form = { studentId: 1, napDate: '', sleepMinutes: 90, napStatus: 'normal', performance: '' }; napDlg.visible = true }
async function saveNap() { await kindApi.saveNap(napDlg.form); ElMessage.success('午休记录已保存'); napDlg.visible = false }
function openAbnormal() { abnormalDlg.form = { studentId: 1, symptom: '', handleMeasure: '', followNote: '' }; abnormalDlg.visible = true }
async function saveAbnormal() { await kindApi.saveHealthAbnormal(abnormalDlg.form); ElMessage.success('异常已上报，跟进闭环'); abnormalDlg.visible = false }
function openInspect() { inspectDlg.form = { hazardDesc: '', location: '', riskLevel: 'low', rectifyDeadline: '' }; inspectDlg.visible = true }
async function saveInspect() { await kindApi.saveInspect(inspectDlg.form); ElMessage.success('隐患已上报，进入整改闭环'); inspectDlg.visible = false }
function openGrowth() { growthDlg.form = { studentId: 1, recordType: 'comment', title: '', content: '' }; growthDlg.visible = true }
async function saveGrowth() { await kindApi.saveGrowth(growthDlg.form); ElMessage.success('已发布'); growthDlg.visible = false; loadGrowths() }

onMounted(() => { loadAuths(); loadRecords(); loadMeals(); loadChecks(); loadGrowths() })
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>