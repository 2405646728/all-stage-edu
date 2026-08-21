<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">角</div>
          <div><h3>角色权限</h3></div>
        </div>
    <el-row :gutter="14">
      <!-- 左侧：角色列表 -->
      <el-col :span="8">
        <el-card shadow="never" header="角色（金字塔六级体系）">
          <div class="toolbar"><el-button type="success" size="small" :icon="Plus" @click="openRole()">新增角色</el-button></div>
          <el-table :data="roles" border size="small" highlight-current-row @current-change="selRole">
            <el-table-column prop="roleName" label="角色名称" width="130" />
            <el-table-column prop="roleCode" label="编码" min-width="120" />
            <el-table-column prop="roleLevel" label="层级" width="60" />
          </el-table>
        </el-card>
      </el-col>
      <!-- 右侧：菜单权限授权（菜单/按钮/数据三级） -->
      <el-col :span="16">
        <el-card shadow="never" :header="'权限配置：' + (currentRole?.roleName || '请选择角色')">
          <el-tree ref="treeRef" :data="menuTree" show-checkbox node-key="id" :props="{ label: 'menuName', children: 'children' }" default-expand-all class="perm-tree" />
          <div style="margin-top: 12px; display: flex; gap: 10px">
            <el-button type="primary" :disabled="!currentRole" @click="savePerms">保存授权（权限终审留痕）</el-button>
            <el-button :disabled="!currentRole" @click="loadRoleMenus">重新载入</el-button>
          </div>
          <el-alert type="info" :closable="false" title="权限颗粒度：菜单/按钮/数据三级；授权人、授权时间自动留痕（granted_by），校级特殊权限须平台终审备案" style="margin-top: 12px" />
        </el-card>
      </el-col>
    </el-row>
    <el-dialog v-model="roleDlg.visible" title="角色" width="440px">
      <el-form label-width="80px">
        <el-form-item label="编码"><el-input v-model="roleDlg.form.roleCode" /></el-form-item>
        <el-form-item label="名称"><el-input v-model="roleDlg.form.roleName" /></el-form-item>
        <el-form-item label="层级"><el-input-number v-model="roleDlg.form.roleLevel" :min="1" :max="6" /></el-form-item>
        <el-form-item label="作用域"><el-select v-model="roleDlg.form.scope" style="width:100%"><el-option label="平台级" value="platform" /><el-option label="机构级" value="org" /></el-select></el-form-item>
        <el-form-item label="说明"><el-input v-model="roleDlg.form.description" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="roleDlg.visible = false">取消</el-button><el-button type="primary" @click="saveRole">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { permApi } from '@/api/sys'

const roles = ref<any[]>([])
const currentRole = ref<any>()
const menuTree = ref<any[]>([])
const treeRef = ref<any>()
const roleDlg = reactive({ visible: false, form: {} as any })

async function loadRoles() { roles.value = await permApi.listRoles() }
async function loadTree() { menuTree.value = await permApi.menuTree() }

async function selRole(row: any) {
  currentRole.value = row
  await nextTick()
  loadRoleMenus()
}
async function loadRoleMenus() {
  if (!currentRole.value) return
  const ids = await permApi.roleMenus(currentRole.value.id)
  treeRef.value?.setCheckedKeys(ids)
}
async function savePerms() {
  const checked = treeRef.value?.getCheckedKeys() || []
  const half = treeRef.value?.getHalfCheckedKeys() || []
  await permApi.saveRoleMenus({ roleId: currentRole.value.id, menuIds: [...checked, ...half] })
  ElMessage.success('授权已保存（终审留痕）')
}
function openRole() { roleDlg.form = { roleCode: '', roleName: '', roleLevel: 3, scope: 'org', description: '' }; roleDlg.visible = true }
async function saveRole() { await permApi.saveRole(roleDlg.form); ElMessage.success('已保存'); roleDlg.visible = false; loadRoles() }
onMounted(() => { loadRoles(); loadTree() })
</script>

<style scoped>.toolbar { margin-bottom: 12px; } .perm-tree { max-height: 480px; overflow: auto; }</style>