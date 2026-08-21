<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">版</div>
          <div><h3>版本热补丁</h3></div>
        </div>
    <el-tabs v-model="tab">
      <el-tab-pane label="版本迭代" name="version">
        <el-card shadow="never">
          <div class="toolbar"><el-button type="success" :icon="Plus" @click="openV()">发布版本</el-button></div>
          <el-table :data="versions" border stripe>
            <el-table-column prop="versionNo" label="版本号" width="110" />
            <el-table-column prop="versionName" label="版本名称" width="150" />
            <el-table-column prop="releaseNote" label="发布说明" min-width="220" show-overflow-tooltip />
            <el-table-column label="类型" width="100"><template #default="{ row }">{{ row.releaseType === 'full' ? '全量' : row.isHotpatch === 1 ? '热补丁' : '补丁' }}</template></el-table-column>
            <el-table-column label="状态" width="110"><template #default="{ row }"><el-tag>{{ { draft: '草稿', gray: '灰度中', published: '已发布', rolled_back: '已回滚' }[row.status] || row.status }}</el-tag></template></el-table-column>
            <el-table-column prop="publishedAt" label="发布时间" width="170" />
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="热补丁记录" name="patch">
        <el-card shadow="never">
          <el-alert type="info" :closable="false" title="无感知热补丁（文档 1.6.3）：单模块精准更新、用户无感刷新、补丁版本溯源归档可回滚" style="margin-bottom: 14px" />
          <el-table :data="patches" border stripe size="small">
            <el-table-column prop="patchCode" label="补丁编码" width="130" />
            <el-table-column prop="moduleCode" label="修复模块" width="120" />
            <el-table-column prop="fixDesc" label="修复说明" min-width="200" show-overflow-tooltip />
            <el-table-column label="状态" width="120"><template #default="{ row }"><el-tag>{{ { draft: '草稿', applied: '已部署', verified: '核验通过', rolled_back: '已回滚' }[row.status] || row.status }}</el-tag></template></el-table-column>
            <el-table-column prop="appliedAt" label="部署时间" width="170" />
            <el-table-column prop="verifiedAt" label="核验时间" width="170" />
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="灰度发布" name="gray">
        <el-card shadow="never">
          <div class="toolbar">
            <el-select v-model="grayVersionId" placeholder="选择版本" clearable style="width: 200px">
              <el-option v-for="v in versions" :key="v.id" :label="v.versionNo + ' ' + v.versionName" :value="v.id" />
            </el-select>
            <el-button type="primary" @click="loadGray">查询灰度范围</el-button>
            <el-button type="success" @click="openGray">指定机构试用</el-button>
          </div>
          <el-alert type="info" :closable="false" title="新功能灰度上线（文档 1.3.6-3）：指定机构试用后再全量推送，规避全量更新风险" style="margin-bottom: 14px" />
          <el-table :data="grayList" border stripe size="small">
            <el-table-column prop="versionId" label="版本ID" width="90" />
            <el-table-column prop="orgId" label="机构ID" width="90" />
            <el-table-column label="灰度状态" width="120"><template #default="{ row }"><el-tag>{{ { graying: '试用中', applied: '已应用', rolled_back: '已回滚' }[row.grayStatus] || row.grayStatus }}</el-tag></template></el-table-column>
            <el-table-column prop="updatedAt" label="更新时间" width="170" />
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>
    <el-dialog v-model="grayDlg.visible" title="灰度指定机构" width="420px">
      <el-form label-width="90px">
        <el-form-item label="版本"><el-select v-model="grayDlg.form.versionId" style="width: 100%"><el-option v-for="v in versions" :key="v.id" :label="v.versionNo" :value="v.id" /></el-select></el-form-item>
        <el-form-item label="机构ID"><el-input-number v-model="grayDlg.form.orgId" :min="1" /></el-form-item>
        <el-form-item label="状态"><el-select v-model="grayDlg.form.grayStatus" style="width: 100%"><el-option label="试用中" value="graying" /></el-select></el-form-item>
      </el-form>
      <template #footer><el-button @click="grayDlg.visible = false">取消</el-button><el-button type="primary" @click="saveGray">确认</el-button></template>
    </el-dialog>
    <el-dialog v-model="vDlg.visible" title="发布版本" width="480px">
      <el-form label-width="90px">
        <el-form-item label="版本号"><el-input v-model="vDlg.form.versionNo" placeholder="如 v1.1.0" /></el-form-item>
        <el-form-item label="版本名称"><el-input v-model="vDlg.form.versionName" /></el-form-item>
        <el-form-item label="发布说明"><el-input v-model="vDlg.form.releaseNote" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="热补丁"><el-switch v-model="vDlg.form.isHotpatch" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="vDlg.visible = false">取消</el-button><el-button type="primary" @click="saveV">发布</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { platformApi } from '@/api/sys'
import { securityApi } from '@/api/security'

const tab = ref('version')
const versions = ref<any[]>([])
const patches = ref<any[]>([])
const vDlg = reactive({ visible: false, form: {} as any })
const grayVersionId = ref<number>()
const grayList = ref<any[]>([])
const grayDlg = reactive({ visible: false, form: {} as any })

async function loadGray() { grayList.value = await securityApi.listVersionOrgs(grayVersionId.value) }
function openGray() { grayDlg.form = { versionId: grayVersionId.value, orgId: 1, grayStatus: 'graying' }; grayDlg.visible = true }
async function saveGray() { await securityApi.saveVersionOrg(grayDlg.form); ElMessage.success('已加入灰度范围'); grayDlg.visible = false; loadGray() }
async function load() { versions.value = await platformApi.listVersions(); patches.value = await platformApi.listHotpatches() }
function openV() { vDlg.form = { versionNo: '', versionName: '', releaseNote: '', isHotpatch: 0, releaseType: 'patch', status: 'published' }; vDlg.visible = true }
async function saveV() { await platformApi.saveVersion(vDlg.form); ElMessage.success('已发布'); vDlg.visible = false; load() }
onMounted(load)
</script>

<style scoped>.toolbar { margin-bottom: 14px; }</style>