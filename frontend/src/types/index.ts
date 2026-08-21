// 统一后端响应
export interface R<T = any> {
  code: number
  msg: string
  data: T
}

export interface PageResult<T = any> {
  total: number
  pages: number
  current: number
  size: number
  records: T[]
}

export interface UserInfo {
  id: number
  username: string
  realName: string
  userType: string
  orgId: number | null
  orgName: string | null
  stage: string | null
  campusId: number | null
  avatar?: string
  phone?: string
  email?: string
  mustChangePwd: boolean
  roles: string[]
}

export interface LoginResult {
  token: string
  user: UserInfo
}

export interface OrgVO {
  id: number
  orgCode: string
  orgName: string
  stage: string
  schoolType: string
  province: string
  city: string
  district: string
  address: string
  contactName: string
  contactPhone: string
  status: number
  serviceStart?: string
  serviceEnd?: string
  auditRemark?: string
  createdAt?: string
}
