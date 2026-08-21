import request from './request'
import type { PageResult } from '@/types'

export const highApi = {
  listRules: (params: Record<string, any>) => request.get('/high/rule/list', { params }),
  saveRule: (data: Record<string, any>) => request.post('/high/rule/save', data),
  pageChoice: (params: Record<string, any>) => request.get<PageResult<any>>('/high/choice/page', { params }),
  saveChoice: (data: Record<string, any>) => request.post('/high/choice/save', data),
  auditChoice: (params: Record<string, any>) => request.post('/high/choice/audit', null, { params }),
  listConversions: (params: Record<string, any>) => request.get('/high/conversion/list', { params }),
  listPrep: (params: Record<string, any>) => request.get('/high/prep/list', { params }),
  savePrep: (data: Record<string, any>) => request.post('/high/prep/save', data),
  listOutcomes: (params: Record<string, any>) => request.get('/high/outcome/list', { params })
}

export const vocApi = {
  listMajors: (orgId?: number) => request.get('/voc/major/list', { params: { orgId } }),
  saveMajor: (data: Record<string, any>) => request.post('/voc/major/save', data),
  listSites: (orgId?: number) => request.get('/voc/site/list', { params: { orgId } }),
  listDevices: (params: Record<string, any>) => request.get('/voc/device/list', { params }),
  saveDevice: (data: Record<string, any>) => request.post('/voc/device/save', data),
  listPlans: (params: Record<string, any>) => request.get('/voc/plan/list', { params }),
  pageRecords: (params: Record<string, any>) => request.get<PageResult<any>>('/voc/record/page', { params }),
  saveRecord: (data: Record<string, any>) => request.post('/voc/record/save', data),
  listCertificates: (params: Record<string, any>) => request.get('/voc/certificate/list', { params }),
  saveCertificate: (data: Record<string, any>) => request.post('/voc/certificate/save', data),
  listCompanies: (orgId?: number) => request.get('/voc/company/list', { params: { orgId } }),
  saveCompany: (data: Record<string, any>) => request.post('/voc/company/save', data),
  pageInternships: (params: Record<string, any>) => request.get<PageResult<any>>('/voc/internship/page', { params }),
  saveInternship: (data: Record<string, any>) => request.post('/voc/internship/save', data),
  saveCheckin: (data: Record<string, any>) => request.post('/voc/internship/checkin/save', data),
  listCheckins: (internshipId: number) => request.get('/voc/internship/checkin/list', { params: { internshipId } }),
  listEmployments: (params: Record<string, any>) => request.get('/voc/employment/list', { params })
}