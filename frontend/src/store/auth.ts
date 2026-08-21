import { defineStore } from 'pinia'
import { loginApi, logoutApi } from '@/api/auth'
import type { UserInfo } from '@/types'

const TOKEN_KEY = 'asedu_token'
const USER_KEY = 'asedu_user'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem(TOKEN_KEY) || '',
    user: JSON.parse(localStorage.getItem(USER_KEY) || 'null') as UserInfo | null
  }),
  getters: {
    isLogin: (state) => !!state.token,
    isSuperAdmin: (state) => state.user?.userType === 'super_admin'
  },
  actions: {
    async login(username: string, password: string) {
      const res = await loginApi({ username, password })
      this.token = res.token
      this.user = res.user
      localStorage.setItem(TOKEN_KEY, res.token)
      localStorage.setItem(USER_KEY, JSON.stringify(res.user))
      return res
    },
    async logout() {
      try {
        await logoutApi()
      } catch {
        // 忽略登出接口异常
      }
      this.token = ''
      this.user = null
      localStorage.removeItem(TOKEN_KEY)
      localStorage.removeItem(USER_KEY)
    }
  }
})
