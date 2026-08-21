import request from './request'
import type { PageResult } from '@/types'

export const kindApi = {
  // 接送
  listPickupAuth: (params: Record<string, any>) => request.get('/kind/pickup-auth/list', { params }),
  savePickupAuth: (data: Record<string, any>) => request.post('/kind/pickup-auth/save', data),
  approvePickupAuth: (params: Record<string, any>) => request.post('/kind/pickup-auth/approve', null, { params }),
  pagePickupRecord: (params: Record<string, any>) => request.get<PageResult<any>>('/kind/pickup-record/page', { params }),
  recordPickup: (data: Record<string, any>) => request.post('/kind/pickup-record/save', data),
  // 餐食
  listMeal: (params: Record<string, any>) => request.get('/kind/meal/list', { params }),
  saveMeal: (data: Record<string, any>) => request.post('/kind/meal/save', data),
  // 午休/活动/成长
  saveNap: (data: Record<string, any>) => request.post('/kind/nap/save', data),
  listActivity: (params: Record<string, any>) => request.get('/kind/activity/list', { params }),
  pageGrowth: (params: Record<string, any>) => request.get<PageResult<any>>('/kind/growth/page', { params }),
  saveGrowth: (data: Record<string, any>) => request.post('/kind/growth/save', data),
  // 晨午检/异常/巡查
  listHealthCheck: (params: Record<string, any>) => request.get('/kind/health-check/list', { params }),
  saveHealthCheck: (data: Record<string, any>) => request.post('/kind/health-check/save', data),
  listHealthAbnormal: (params: Record<string, any>) => request.get('/kind/health-abnormal/list', { params }),
  saveHealthAbnormal: (data: Record<string, any>) => request.post('/kind/health-abnormal/save', data),
  listInspect: (params: Record<string, any>) => request.get('/kind/inspect/list', { params }),
  saveInspect: (data: Record<string, any>) => request.post('/kind/inspect/save', data)
}