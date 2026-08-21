<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">通</div>
          <div><h3>通知消息</h3></div>
        </div>
    <el-card shadow="never">
      <div class="toolbar">
        <el-input v-model="query.title" placeholder="通知标题" clearable style="width: 200px" @keyup.enter="load" />
        <el-button type="primary" :icon="Search" @click="load">查询</el-button>
        <el-button type="success" :icon="Plus" @click="openPublish">发布通知</el-button>
      </div>
      <el-table :data="list" border stripe v-loading="loading">
        <el-table-column prop="title" label="标题" min-width="200" show-overflow-tooltip />
        <el-table-column label="类型" width="110">
          <template #default="{ row }">{{ noticeTypeName(row.noticeType) }}</template>
        </el-table-column>
        <el-table-column label="范围" width="90">
          <template #default="{ row }">{{ { org: '全园(校)', class: '班级', person: '定向' }[row.scopeType] || row.scopeType }}</template>
        </el-table-column>
        <el-table-column prop="content" label="内容" min-width="220" show-overflow-tooltip />
        <el-table-column prop="publishedAt" label="发布时间" width="170" />
        <el-table-column label="回执" width="80">
          <template #default="{ row }">{{ row.needReadBack === 1 ? '需要' : '否' }}</template>
        </el-table-column>
      </el-table>
      <el-pagination v-model:current-page="query.current" v-model:page-size="query.size" :total="total"
        layout="total, prev, pager, next" @current-change="load" style="margin-top: 12px; justify-content: flex-end" />
    </el-card>

    <el-dialog v-model="pubDlg.visible" title="发布通知（全园/班级分层）" width="560px">
      <el-form label-width="80px">
        <el-form-item label="标题" required><el-input v-model="pubDlg.form.title" /></el-form-item>
        <el-form-item label="类型">
          <el-select v-model="pubDlg.form.noticeType" style="width: 100%">
            <el-option v-for="t in noticeTypes" :key="t.value" :label="t.label" :value="t.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="范围">
          <el-radio-group v-model="pubDlg.form.scopeType">
            <el-radio value="org">全园(校)</el-radio>
            <el-radio value="class">班级</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item v-if="pubDlg.form.scopeType === 'class'" label="班级">
          <el-select v-model="pubDlg.classIds" multiple style="width: 100%">
            <el-option v-for="c in classes" :key="c.id" :label="c.className" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="内容">
          <el-input v-model="pubDlg.form.content" type="textarea" :rows="4" />
        </el-form-item>
        <el-form-item label="已读回执">
          <el-switch v-model="pubDlg.form.needReadBack" :active-value="1" :inactive-value="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="pubDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="publish">发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Plus, Promotion } from '@element-plus/icons-vue'
import { msgApi } from '@/api/biz'
import { templateApi } from '@/api/sys'
import { classApi } from '@/api/base'

const noticeTypes = [
  { label: '普通通知', value: 'notice' }, { label: '餐食公示', value: 'meal' },
  { label: '活动', value: 'activity' }, { label: '安全教育', value: 'security' },
  { label: '天气提醒', value: 'weather' }, { label: '温馨提示', value: 'tips' }
]
const noticeTypeName = (v: string) => noticeTypes.find((t) => t.value === v)?.label || v

const loading = ref(false)
const list = ref<any[]>([])
const total = ref(0)
const query = reactive({ current: 1, size: 10, title: '' })
const classes = ref<any[]>([])
const myMessages = ref<any[]>([])
const msgForm = reactive({ receiverId: 1, studentId: undefined as number | undefined, content: '' })

async function loadMessages() {
  const me = JSON.parse(localStorage.getItem('asedu_user') || '{}')
  if (me.id) {
    const res = await msgApi.pageMessage({ current: 1, size: 20, receiverId: me.id })
    myMessages.value = res.records
  }
}
async function sendMsg() {
  if (!msgForm.content) { ElMessage.warning('消息内容不能为空'); return }
  await msgApi.send({ orgId: undefined, receiverId: Number(msgForm.receiverId), studentId: msgForm.studentId ? Number(msgForm.studentId) : undefined, content: msgForm.content, msgType: 'text' })
  ElMessage.success('消息已发送')
  msgForm.content = ''
}
const templates = ref<any[]>([])
const tplDlg = reactive({ visible: false, form: {} as any })

async function loadTemplates() { templates.value = await templateApi.list() }
function openTpl() { tplDlg.form = { templateCode: '', templateName: '', channel: 'system', titleTpl: '', contentTpl: '', status: 1 }; tplDlg.visible = true }
async function saveTpl() { await templateApi.save(tplDlg.form); ElMessage.success('模板已保存'); tplDlg.visible = false; loadTemplates() }

const pubDlg = reactive({
  visible: false,
  form: { title: '', noticeType: 'notice', scopeType: 'org', content: '', needReadBack: 1 } as any,
  classIds: [] as number[]
})

async function load() {
  loading.value = true
  try {
    const res = await msgApi.pageNotice({ ...query })
    list.value = res.records
    total.value = res.total
  } finally { loading.value = false }
}

async function loadClasses() { classes.value = await classApi.list() }

function openPublish() {
  pubDlg.form = { title: '', noticeType: 'notice', scopeType: 'org', content: '', needReadBack: 1 }
  pubDlg.classIds = []
  pubDlg.visible = true
}

async function publish() {
  if (!pubDlg.form.title) { ElMessage.warning('标题必填'); return }
  await msgApi.publish({ ...pubDlg.form, classIds: pubDlg.classIds, userIds: [] })
  ElMessage.success('通知已发布')
  pubDlg.visible = false
  load()
}

onMounted(() => { load(); loadClasses(); loadTemplates(); loadMessages() })
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>