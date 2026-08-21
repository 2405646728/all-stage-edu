import request from './request'
import type { PageResult } from '@/types'

export interface AttRecord {
  id: number
  studentId: number
  classId?: number
  attDate: string
  attendScene: string
  signInTime?: string
  signOutTime?: string
  stayMinutes: number
  status: string
  deviceName?: string
}
export interface AttLeave {
  id: number
  studentId: number
  leaveType: string
  startTime: string
  endTime: string
  durationHours: number
  reason: string
  approveStatus: string
  approveRemark?: string
}
export interface GatePass {
  id: number
  personType: string
  personName: string
  deviceName: string
  passTime: string
  direction: string
  passWay: string
  result: string
  failReason?: string
}
export interface MsgNotice {
  id: number
  noticeType: string
  scopeType: string
  title: string
  content: string
  publishStatus: string
  publishedAt?: string
}
export interface FeeItem { id?: number; orgId?: number; itemCode: string; itemName: string; feeType: string; defaultAmount: number; status?: number }
export interface FinBill {
  id: number
  billNo: string
  studentId: number
  feeItemId: number
  billAmount: number
  reducedAmount: number
  paidAmount: number
  billStatus: string
  dueDate?: string
}

export const attApi = {
  pageStudent: (params: Record<string, any>) => request.get<PageResult<AttRecord>>('/att/student/page', { params }),
  checkIn: (data: Record<string, any>) => request.post('/att/student/check-in', data),
  pageLeave: (params: Record<string, any>) => request.get<PageResult<AttLeave>>('/att/leave/page', { params }),
  leaveApply: (data: Record<string, any>) => request.post('/att/leave/apply', data),
  leaveApprove: (params: Record<string, any>) => request.post('/att/leave/approve', null, { params })
}

export const gateApi = {
  pagePass: (params: Record<string, any>) => request.get<PageResult<GatePass>>('/gate/pass/page', { params }),
  pageAlert: (params: Record<string, any>) => request.get('/gate/alert/page', { params }),
  pageVisitor: (params: Record<string, any>) => request.get('/gate/visitor/page', { params }),
  listPermission: (params: Record<string, any>) => request.get('/gate/permission/list', { params }),
  savePermission: (data: Record<string, any>) => request.post('/gate/permission/save', data),
  handleAlert: (params: Record<string, any>) => request.post('/gate/alert/handle', null, { params })
}

export const msgApi = {
  pageNotice: (params: Record<string, any>) => request.get<PageResult<MsgNotice>>('/msg/notice/page', { params }),
  publish: (data: Record<string, any>) => request.post('/msg/notice/publish', data),
  pageMessage: (params: Record<string, any>) => request.get<PageResult<any>>('/msg/message/page', { params }),
  send: (data: Record<string, any>) => request.post('/msg/message/send', data)
}

export const finApi = {
  listItems: (orgId?: number) => request.get<FeeItem[]>('/fin/item/list', { params: { orgId } }),
  saveItem: (data: FeeItem) => request.post('/fin/item/save', data),
  pageBill: (params: Record<string, any>) => request.get<PageResult<FinBill>>('/fin/bill/page', { params }),
  generateBill: (params: Record<string, any>) => request.post('/fin/bill/generate', null, { params }),
  createPayment: (data: Record<string, any>) => request.post('/fin/payment/create', data),
  pageLedger: (params: Record<string, any>) => request.get<PageResult<any>>('/fin/ledger/page', { params }),
  paymentsByBill: (billId: number) => request.get<any[]>('/fin/payment/by-bill', { params: { billId } })
}