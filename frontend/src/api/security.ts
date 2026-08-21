import request from './request'

export const securityApi = {
  listIpRules: (ruleType?: string) => request.get('/sys/ip-rule/list', { params: { ruleType } }),
  saveIpRule: (data: Record<string, any>) => request.post('/sys/ip-rule/save', data),
  deleteIpRule: (id: number) => request.delete('/sys/ip-rule/' + id),
  pageLoginLog: (params: Record<string, any>) => request.get('/sys/log/login/page', { params }),
  listBackups: () => request.get('/sys/backup/list'),
  saveBackup: (data: Record<string, any>) => request.post('/sys/backup/save', data),
  listGov: () => request.get('/sys/gov/list'),
  saveGov: (data: Record<string, any>) => request.post('/sys/gov/save', data),
  listVersionOrgs: (versionId?: number) => request.get('/sys/version-org/list', { params: { versionId } }),
  saveVersionOrg: (data: Record<string, any>) => request.post('/sys/version-org/save', data)
}
