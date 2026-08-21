import request from './request'
import type { OrgVO, PageResult } from '@/types'

export const orgApi = {
  page: (params: Record<string, any>) => request.get('/sys/org/page', { params }),
  current: () => request.get<OrgVO>('/sys/org/current'),
  detail: (id: number) => request.get<OrgVO>('/sys/org/' + id)
}
