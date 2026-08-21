<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">字</div>
          <div><h3>字典管理</h3></div>
        </div>
    <el-row :gutter="12">
      <el-col :span="9">
        <el-card shadow="never" header="字典类型">
          <div class="toolbar">
            <el-button type="success" size="small" :icon="Plus" @click="openType()">新增类型</el-button>
          </div>
          <el-table :data="types" border size="small" highlight-current-row @current-change="selType" height="480">
            <el-table-column prop="typeCode" label="编码" width="130" />
            <el-table-column prop="typeName" label="名称" />
            <el-table-column prop="isFrozen" label="冻结" width="60">
              <template #default="{ row }">{{ row.isFrozen === 1 ? '是' : '否' }}</template>
            </el-table-column>
            <el-table-column label="操作" width="70">
              <template #default="{ row }">
                <el-button link type="danger" @click="removeType(row)">删</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="15">
        <el-card shadow="never" :header="'字典项：' + (currentType?.typeName || '请选择类型')">
          <div class="toolbar">
            <el-button type="success" size="small" :icon="Plus" :disabled="!currentType" @click="openItem()">新增字典项</el-button>
          </div>
          <el-table :data="items" border size="small" height="480">
            <el-table-column prop="itemCode" label="编码" width="120" />
            <el-table-column prop="itemName" label="名称" />
            <el-table-column prop="stage" label="适用学段" width="100">
              <template #default="{ row }">{{ row.stage || '全学段' }}</template>
            </el-table-column>
            <el-table-column prop="sortNo" label="排序" width="60" />
            <el-table-column prop="status" label="状态" width="70">
              <template #default="{ row }">{{ row.status === 1 ? '启用' : '停用' }}</template>
            </el-table-column>
            <el-table-column label="操作" width="70">
              <template #default="{ row }">
                <el-button link type="danger" @click="removeItem(row)">删</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <el-dialog v-model="typeDlg.visible" title="字典类型" width="420px">
      <el-form label-width="70px">
        <el-form-item label="编码"><el-input v-model="typeDlg.form.typeCode" /></el-form-item>
        <el-form-item label="名称"><el-input v-model="typeDlg.form.typeName" /></el-form-item>
        <el-form-item label="冻结"><el-switch v-model="typeDlg.form.isFrozen" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="typeDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveType">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="itemDlg.visible" title="字典项" width="420px">
      <el-form label-width="70px">
        <el-form-item label="编码"><el-input v-model="itemDlg.form.itemCode" /></el-form-item>
        <el-form-item label="名称"><el-input v-model="itemDlg.form.itemName" /></el-form-item>
        <el-form-item label="排序"><el-input-number v-model="itemDlg.form.sortNo" :min="0" /></el-form-item>
        <el-form-item label="学段">
          <el-select v-model="itemDlg.form.stage" clearable style="width: 100%">
            <el-option label="全学段通用" :value="undefined" />
            <el-option v-for="s in stages" :key="s.value" :label="s.label" :value="s.value" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="itemDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveItem">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { dictApi } from '@/api/sys'

const stages = [
  { label: '幼儿园', value: 'kindergarten' }, { label: '小学', value: 'primary' },
  { label: '初中', value: 'junior' }, { label: '普高', value: 'senior' },
  { label: '职高', value: 'vocational' }, { label: '大学', value: 'university' }
]
const types = ref<any[]>([])
const items = ref<any[]>([])
const currentType = ref<any>()
const typeDlg = reactive({ visible: false, form: {} as any })
const itemDlg = reactive({ visible: false, form: {} as any })

async function loadTypes() { types.value = await dictApi.listTypes() }
async function selType(row: any) {
  currentType.value = row
  items.value = await dictApi.listItems(row.typeCode)
}
function openType() { typeDlg.form = { typeCode: '', typeName: '', isFrozen: 0 }; typeDlg.visible = true }
async function saveType() { await dictApi.saveType(typeDlg.form); ElMessage.success('已保存'); typeDlg.visible = false; loadTypes() }
async function removeType(row: any) {
  await ElMessageBox.confirm('删除类型将同时删除其字典项，确认？', '提示', { type: 'warning' })
  await dictApi.removeType(row.id); ElMessage.success('已删除'); loadTypes(); items.value = []
}
function openItem() {
  itemDlg.form = { typeCode: currentType.value.typeCode, itemCode: '', itemName: '', sortNo: 0, stage: undefined, status: 1 }
  itemDlg.visible = true
}
async function saveItem() {
  const payload = { ...itemDlg.form }
  if (!payload.stage) delete payload.stage
  await dictApi.saveItem(payload); ElMessage.success('已保存'); itemDlg.visible = false; items.value = await dictApi.listItems(currentType.value.typeCode)
}
async function removeItem(row: any) {
  await dictApi.removeItem(row.id); ElMessage.success('已删除'); items.value = await dictApi.listItems(currentType.value.typeCode)
}
onMounted(loadTypes)
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 12px; }
</style>
