import request from './request'
import type { LoginResult, UserInfo } from '@/types'

export function loginApi(data: { username: string; password: string }): Promise<LoginResult> {
  return request.post('/auth/login', data)
}

export function meApi(): Promise<UserInfo> {
  return request.get('/auth/me')
}

export function logoutApi(): Promise<null> {
  return request.post('/auth/logout')
}
export function changePwdApi(data: { oldPassword: string; newPassword: string }): Promise<null> {
  return request.post('/auth/change-pwd', data)
}
