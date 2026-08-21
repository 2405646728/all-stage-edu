import request from './request'

export const dashboardApi = {
  platform: () => request.get<any>('/dashboard/platform'),
  school: () => request.get<any>('/dashboard/school')
}

export const authOpenApi = {
  createBatch: (data: Record<string, any>) => request.post('/auth/open/batch', data),
  pageBatch: (params: Record<string, any>) => request.get('/auth/open/batch/page', { params }),
  listItems: (batchId: number) => request.get('/auth/open/batch/items', { params: { batchId } }),
  createInvite: (data: Record<string, any>) => request.post('/auth/open/invite', data),
  pageInvites: (params: Record<string, any>) => request.get('/auth/open/invite/page', { params })
}
