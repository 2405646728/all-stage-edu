import axios from 'axios'
import { ElMessage } from 'element-plus'
import type { R } from '@/types'

const request = axios.create({
  baseURL: '/api',
  timeout: 20000
})

request.interceptors.request.use((config) => {
  const token = localStorage.getItem('asedu_token')
  if (token) {
    config.headers.Authorization = 'Bearer ' + token
  }
  return config
})

request.interceptors.response.use(
  (response) => {
    const r = response.data as R
    if (r.code !== 200) {
      ElMessage.error(r.msg || '请求失败')
      if (r.code === 401) {
        localStorage.removeItem('asedu_token')
        localStorage.removeItem('asedu_user')
        window.location.href = '/login'
      }
      return Promise.reject(new Error(r.msg || '请求失败'))
    }
    return r.data
  },
  (error) => {
    ElMessage.error(error.message || '网络异常')
    return Promise.reject(error)
  }
)

export default request
