import request from './request'
import type { PageResult } from '@/types'

export const uniApi = {
  listDepartments: (orgId?: number) => request.get('/uni/department/list', { params: { orgId } }),
  listMajors: (params: Record<string, any>) => request.get('/uni/major/list', { params }),
  listPrograms: (params: Record<string, any>) => request.get('/uni/program/list', { params }),
  listProgramCourses: (programId: number) => request.get('/uni/program-course/list', { params: { programId } }),
  listOffers: (params: Record<string, any>) => request.get('/uni/offer/list', { params }),
  saveSelect: (data: Record<string, any>) => request.post('/uni/select/save', data),
  listSelects: (params: Record<string, any>) => request.get('/uni/select/list', { params }),
  pageScore: (params: Record<string, any>) => request.get<PageResult<any>>('/uni/score/page', { params }),
  saveScore: (data: Record<string, any>) => request.post('/uni/score/save', data),
  listEvals: (params: Record<string, any>) => request.get('/uni/eval/list', { params }),
  listScholarships: (params: Record<string, any>) => request.get('/uni/scholarship/list', { params }),
  listInnovations: (params: Record<string, any>) => request.get('/uni/innovation/list', { params }),
  listClubs: (orgId?: number) => request.get('/uni/club/list', { params: { orgId } }),
  listTheses: (params: Record<string, any>) => request.get('/uni/thesis/list', { params }),
  saveThesis: (data: Record<string, any>) => request.post('/uni/thesis/save', data),
  listPrechecks: (params: Record<string, any>) => request.get('/uni/precheck/list', { params }),
  listEmployments: (params: Record<string, any>) => request.get('/uni/employment/list', { params }),
  listBuildings: (orgId?: number) => request.get('/uni/dorm/building/list', { params: { orgId } }),
  listRooms: (buildingId: number) => request.get('/uni/dorm/room/list', { params: { buildingId } }),
  listDormStudents: (params: Record<string, any>) => request.get('/uni/dorm/student/list', { params }),
  assignDorm: (data: Record<string, any>) => request.post('/uni/dorm/student/assign', data),
  listRepairs: (params: Record<string, any>) => request.get('/uni/repair/list', { params }),
  saveRepair: (data: Record<string, any>) => request.post('/uni/repair/save', data),
  listDormChecks: (params: Record<string, any>) => request.get('/uni/dorm/check/list', { params }),
  listHealthRecords: (params: Record<string, any>) => request.get('/uni/health/list', { params })
}
