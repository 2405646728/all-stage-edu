<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">收</div>
          <div><h3>收费台账</h3></div>
        </div>
    <el-tabs v-model="tab">
      <el-tab-pane label="收费项目" name="item">
        <el-card shadow="never">
          <div class="toolbar">
            <el-button type="success" :icon="Plus" @click="openItem()">新增项目</el-button>
          </div>
          <el-table :data="items" border stripe>
            <el-table-column prop="itemCode" label="编码" width="110" />
            <el-table-column prop="itemName" label="项目名称" width="160" />
            <el-table-column label="收费类型" width="130">
              <template #default="{ row }">{{ feeTypeName(row.feeType) }}</template>
            </el-table-column>
            <el-table-column prop="chargeCycle" label="计费周期" width="100" />
            <el-table-column prop="defaultAmount" label="标准金额(元)" width="120" />
            <el-table-column prop="description" label="说明" min-width="160" show-overflow-tooltip />
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="缴费台账" name="bill">
        <el-card shadow="never">
          <div class="toolbar">
            <el-input v-model="billQuery.keyword" placeholder="账单号/学生姓名" clearable style="width: 200px" @keyup.enter="loadBills" />
            <el-select v-model="billQuery.billStatus" placeholder="账单状态" clearable style="width: 130px">
              <el-option v-for="s in billStatus" :key="s.value" :label="s.label" :value="s.value" />
            </el-select>
            <el-button type="primary" :icon="Search" @click="loadBills">查询</el-button>
            <el-button type="success" :icon="Plus" @click="openGenerate">生成账单</el-button>
          </div>
          <el-table :data="bills" border stripe v-loading="billLoading">
            <el-table-column prop="billNo" label="账单号" width="160" />
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="billAmount" label="应缴" width="100" />
            <el-table-column prop="reducedAmount" label="减免" width="90" />
            <el-table-column prop="paidAmount" label="已缴" width="90" />
            <el-table-column prop="dueDate" label="截止" width="110" />
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="{ paid: 'success', partial: 'warning', unpaid: 'danger', waived: 'info' }[row.billStatus] || 'info'">
                  {{ { paid: '已缴', partial: '部分缴', unpaid: '未缴', waived: '已减免' }[row.billStatus] || row.billStatus }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="170">
              <template #default="{ row }">
                <el-button v-if="row.billStatus !== 'paid'" link type="primary" @click="openPay(row)">登记缴费</el-button>
                <el-button link type="info" @click="showPayments(row)">流水</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-pagination v-model:current-page="billQuery.current" v-model:page-size="billQuery.size" :total="billTotal"
            layout="total, prev, pager, next" @current-change="loadBills" style="margin-top: 12px; justify-content: flex-end" />
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="财务日志" name="ledger">
        <el-card shadow="never">
          <el-alert type="info" :closable="false" title="财务操作日志独立留存（与业务/运维日志隔离），全部操作永久可溯源，满足审计合规" style="margin-bottom: 14px" />
          <el-table :data="ledgerList" border stripe size="small">
            <el-table-column prop="createdAt" label="操作时间" width="170" />
            <el-table-column prop="operatorName" label="操作人" width="110" />
            <el-table-column prop="action" label="动作" width="100" />
            <el-table-column prop="billNo" label="账单号" width="160" />
            <el-table-column prop="amountBefore" label="调整前" width="100" />
            <el-table-column prop="amountAfter" label="调整后" width="100" />
            <el-table-column prop="detail" label="明细" min-width="200" show-overflow-tooltip />
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="itemDlg.visible" title="收费项目" width="480px">
      <el-form label-width="90px">
        <el-form-item label="编码"><el-input v-model="itemDlg.form.itemCode" /></el-form-item>
        <el-form-item label="名称"><el-input v-model="itemDlg.form.itemName" /></el-form-item>
        <el-form-item label="收费类型">
          <el-select v-model="itemDlg.form.feeType" style="width: 100%">
            <el-option v-for="t in feeTypes" :key="t.value" :label="t.label" :value="t.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="计费周期">
          <el-select v-model="itemDlg.form.chargeCycle" style="width: 100%">
            <el-option label="按月" value="month" /><el-option label="按学期" value="term" />
            <el-option label="按学年" value="year" /><el-option label="一次性" value="one_time" />
          </el-select>
        </el-form-item>
        <el-form-item label="标准金额"><el-input-number v-model="itemDlg.form.defaultAmount" :min="0" :precision="2" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="itemDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveItem">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="genDlg.visible" title="生成账单" width="480px">
      <el-form label-width="90px">
        <el-form-item label="收费项目">
          <el-select v-model="genDlg.feeItemId" style="width: 100%">
            <el-option v-for="i in items" :key="i.id" :label="i.itemName + '（' + i.defaultAmount + '元）'" :value="i.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="学生ID"><el-input-number v-model="genDlg.studentId" :min="1" /></el-form-item>
        <el-form-item label="金额"><el-input-number v-model="genDlg.amount" :min="0" :precision="2" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="genDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="generate">生成</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="payListDlg.visible" title="缴费流水" width="560px">
      <el-table :data="payListDlg.items" border stripe size="small">
        <el-table-column prop="payNo" label="流水号" width="150" />
        <el-table-column prop="payType" label="类型" width="90" />
        <el-table-column prop="payAmount" label="金额" width="90" />
        <el-table-column prop="payWay" label="方式" width="90" />
        <el-table-column prop="payTime" label="缴费时间" width="170" />
      </el-table>
    </el-dialog>

    <el-dialog v-model="payDlg.visible" title="登记缴费" width="420px">
      <el-form label-width="90px">
        <el-form-item label="缴费方式">
          <el-select v-model="payDlg.form.payWay" style="width: 100%">
            <el-option label="微信" value="wechat" /><el-option label="支付宝" value="alipay" />
            <el-option label="银行转账" value="bank" /><el-option label="线下现金" value="offline" />
          </el-select>
        </el-form-item>
        <el-form-item label="缴费金额"><el-input-number v-model="payDlg.form.payAmount" :min="0.01" :precision="2" /></el-form-item>
        <el-form-item label="缴费时间"><el-date-picker v-model="payDlg.form.payTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width: 100%" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="payDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="submitPay">入账</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'
import { finApi } from '@/api/biz'

const tab = ref('item')
const feeTypes = [
  { label: '学费', value: 'tuition' }, { label: '固定收费', value: 'fixed' }, { label: '伙食费', value: 'meal' },
  { label: '一次性杂费', value: 'one_time' }, { label: '服务费', value: 'service' }, { label: '住宿费', value: 'boarding' },
  { label: '教辅资料费', value: 'material' }, { label: '实训耗材费', value: 'training' }
]
const feeTypeName = (v: string) => feeTypes.find((t) => t.value === v)?.label || v
const billStatus = [
  { label: '未缴', value: 'unpaid' }, { label: '部分缴', value: 'partial' }, { label: '已缴', value: 'paid' }
]

const items = ref<any[]>([])
const itemDlg = reactive({ visible: false, form: {} as any })

const billLoading = ref(false)
const bills = ref<any[]>([])
const billTotal = ref(0)
const billQuery = reactive({ current: 1, size: 10, keyword: '', billStatus: '' })

const genDlg = reactive({ visible: false, feeItemId: undefined as number | undefined, studentId: 1, amount: undefined as number | undefined })
const payDlg = reactive({ visible: false, form: {} as any, bill: null as any })
const payListDlg = reactive({ visible: false, items: [] as any[] })

async function showPayments(row: any) {
  payListDlg.items = await finApi.paymentsByBill(row.id)
  payListDlg.visible = true
}

async function loadItems() { items.value = await finApi.listItems() }
const ledgerList = ref<any[]>([])
async function loadLedger() {
  const res = await finApi.pageLedger({ current: 1, size: 50 })
  ledgerList.value = res.records
}
async function loadBills() {
  billLoading.value = true
  try {
    const res = await finApi.pageBill({ ...billQuery })
    bills.value = res.records
    billTotal.value = res.total
  } finally { billLoading.value = false }
}

function openItem() {
  itemDlg.form = { itemCode: '', itemName: '', feeType: 'fixed', chargeCycle: 'term', defaultAmount: 0, status: 1 }
  itemDlg.visible = true
}
async function saveItem() { await finApi.saveItem(itemDlg.form); ElMessage.success('已保存'); itemDlg.visible = false; loadItems() }

function openGenerate() { genDlg.feeItemId = items.value[0]?.id; genDlg.visible = true }
async function generate() {
  await finApi.generateBill({ orgId: undefined, feeItemId: genDlg.feeItemId, studentId: genDlg.studentId, amount: genDlg.amount })
  ElMessage.success('账单已生成'); genDlg.visible = false; loadBills()
}
function openPay(row: any) {
  payDlg.bill = row
  payDlg.form = { payWay: 'wechat', payAmount: row.billAmount - row.paidAmount, payTime: '' }
  payDlg.visible = true
}
async function submitPay() {
  await finApi.createPayment({
    orgId: undefined, billId: payDlg.bill.id, studentId: payDlg.bill.studentId,
    payNo: 'P' + Date.now(), payType: 'normal', payAmount: payDlg.form.payAmount,
    payWay: payDlg.form.payWay, payTime: payDlg.form.payTime || new Date().toISOString().slice(0, 19).replace('T', ' ')
  })
  ElMessage.success('缴费入账成功'); payDlg.visible = false; loadBills()
}

onMounted(() => { loadItems(); loadBills(); loadLedger() })
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>