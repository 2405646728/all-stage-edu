<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-title">
        <h1>全学段一站式学生综合管理系统</h1>
        <p>幼儿园 · 小学 · 初中 · 普高 · 职高 · 大学</p>
      </div>
      <el-form ref="formRef" :model="form" :rules="rules" size="large" @keyup.enter="handleLogin">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="请输入账号" :prefix-icon="User" clearable />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" :prefix-icon="Lock" show-password />
        </el-form-item>
        <el-button type="primary" size="large" class="login-btn" :loading="loading" @click="handleLogin">
          登 录
        </el-button>
      </el-form>
      <div class="login-tip">测试账号：superadmin / admin_kg（密码 123456）</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'
import type { FormInstance, FormRules } from 'element-plus'
import { useAuthStore } from '@/store/auth'

const router = useRouter()
const auth = useAuthStore()
const formRef = ref<FormInstance>()
const loading = ref(false)

const form = reactive({ username: '', password: '' })
const rules: FormRules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

async function handleLogin() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      await auth.login(form.username.trim(), form.password.trim())
      ElMessage.success('登录成功')
      router.push('/dashboard')
    } catch (e) {
      // 错误提示已由拦截器处理
    } finally {
      loading.value = false
    }
  })
}
</script>

<style scoped>
.login-page {
  height: 100vh; display: flex; align-items: center; justify-content: center;
  background: linear-gradient(135deg, #1f6feb 0%, #3a9bff 55%, #6ec3ff 100%);
}
.login-card { width: 420px; padding: 40px 36px 28px; background: #fff; border-radius: 14px; box-shadow: 0 16px 48px rgba(15, 42, 80, 0.22); }
.login-title { text-align: center; margin-bottom: 28px; }
.login-title h1 { font-size: 20px; color: #1f2d3d; }
.login-title p { margin-top: 8px; font-size: 13px; color: #8492a6; }
.login-btn { width: 100%; }
.login-tip { margin-top: 16px; text-align: center; font-size: 12px; color: #a3aab8; }
</style>