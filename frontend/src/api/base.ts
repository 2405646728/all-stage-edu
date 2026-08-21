import request from './request'
import type { PageResult } from '@/types'

export interface SchoolYear {
  id: number
  orgId: number
  yearName: string
  startDate?: string
  endDate?: string
  status: number
}

export interface Grade {
  id: number
  orgId: number
  stage: string
  gradeName: string
  gradeNo: number
  schoolYearId: number
  classCapacity: number
  status: number
}

export interface ClassItem {
  id: number
  orgId: number
  stage: string
  gradeId: number
  className: string
  classType: string
  classCapacity: number
  status: number
}

export interface Student {
  id: number
  orgId: number
  stage: string
  studentNo: string
  name: string
  gender: number
  birthDate?: string
  idCard?: string
  nation?: string
  address?: string
  admitDate?: string
  studyStatus: string
  boarder: number
  currentClassId?: number
  createdAt?: string
}

export interface Teacher {
  id: number
  orgId: number
  staffNo: string
  name: string
  gender: number
  phone?: string
  education?: string
  title?: string
  hireDate?: string
  workStatus: string
}

export interface Guardian {
  id: number
  orgId: number
  name: string
  phone: string
  relation: string
  isEmergency: number
}

// ---- 架构 ----
export const schoolYearApi = {
  list: (orgId?: number) => request.get('/base/arch/school-year/list', { params: { orgId } }),
  save: (data: Partial<SchoolYear>) => request.post('/base/arch/school-year/save', data),
  remove: (id: number) => request.delete('/base/arch/school-year/' + id)
}
export const gradeApi = {
  list: (orgId?: number, schoolYearId?: number) => request.get('/base/arch/grade/list', { params: { orgId, schoolYearId } }),
  save: (data: Partial<Grade>) => request.post('/base/arch/grade/save', data),
  remove: (id: number) => request.delete('/base/arch/grade/' + id)
}
export const classApi = {
  list: (orgId?: number, gradeId?: number) => request.get('/base/arch/class/list', { params: { orgId, gradeId } }),
  save: (data: Partial<ClassItem>) => request.post('/base/arch/class/save', data),
  remove: (id: number) => request.delete('/base/arch/class/' + id)
}

// ---- 学生 ----
export const studentApi = {
  page: (params: Record<string, any>) => request.get('/base/student/page', { params }),
  detail: (id: number) => request.get('/base/student/' + id),
  create: (data: Record<string, any>) => request.post('/base/student/create', data),
  update: (id: number, data: Record<string, any>) => request.put('/base/student/' + id, data),
  remove: (id: number) => request.delete('/base/student/' + id),
  enrollChange: (data: Record<string, any>) => request.post('/base/student/enroll-change', data),
  pageStatusChange: (params: Record<string, any>) => request.get<PageResult<any>>('/base/student/status-change/page', { params }),
  pageClassStudent: (params: Record<string, any>) => request.get<PageResult<any>>('/base/student/class-student/page', { params }),
  assignClass: (data: Record<string, any>) => request.post('/base/student/assign-class', data)
}

// ---- 教师 ----
export const teacherApi = {
  page: (params: Record<string, any>) => request.get('/base/teacher/page', { params }),
  save: (data: Partial<Teacher>) => request.post('/base/teacher/save', data),
  remove: (id: number) => request.delete('/base/teacher/' + id),
  savePost: (data: Record<string, any>) => request.post('/base/teacher/post/save', data),
  listPosts: (teacherId: number) => request.get('/base/teacher/post/list', { params: { teacherId } })
}

// ---- 监护人 ----
export const guardianApi = {
  page: (params: Record<string, any>) => request.get('/base/guardian/page', { params }),
  save: (data: Partial<Guardian>) => request.post('/base/guardian/save', data),
  bind: (params: Record<string, any>) => request.post('/base/guardian/bind', null, { params }),
  listByStudent: (orgId: number | undefined, studentId: number) =>
    request.get('/base/guardian/list-by-student', { params: { orgId, studentId } }),
  unbind: (studentId: number, guardianId: number) =>
    request.delete('/base/guardian/unbind', { params: { studentId, guardianId } })
}

// ---- 健康档案 ----
export const healthApi = {
  get: (studentId: number) => request.get('/base/health/get', { params: { studentId } }),
  save: (data: Record<string, any>) => request.post('/base/health/save', data)
}