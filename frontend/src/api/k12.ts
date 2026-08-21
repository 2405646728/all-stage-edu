import request from './request'
import type { PageResult } from '@/types'

export const eduApi = {
  listCourses: (params: Record<string, any>) => request.get('/edu/course/list', { params }),
  saveCourse: (data: Record<string, any>) => request.post('/edu/course/save', data),
  listSchedules: (params: Record<string, any>) => request.get('/edu/schedule/list', { params }),
  saveSchedule: (data: Record<string, any>) => request.post('/edu/schedule/save', data),
  pageTeaching: (params: Record<string, any>) => request.get<PageResult<any>>('/edu/teaching/page', { params }),
  saveTeaching: (data: Record<string, any>) => request.post('/edu/teaching/save', data),
  listResources: (params: Record<string, any>) => request.get('/edu/resource/list', { params }),
  listWeakPoints: (params: Record<string, any>) => request.get('/edu/weak-point/list', { params }),
  listTiers: (params: Record<string, any>) => request.get('/edu/tier/list', { params })
}

export const examApi = {
  pageExam: (params: Record<string, any>) => request.get<PageResult<any>>('/exam/plan/page', { params }),
  saveExam: (data: Record<string, any>) => request.post('/exam/plan/save', data),
  listSubjects: (examId: number) => request.get('/exam/subject/list', { params: { examId } }),
  saveSubject: (data: Record<string, any>) => request.post('/exam/subject/save', data),
  pageScore: (params: Record<string, any>) => request.get<PageResult<any>>('/exam/score/page', { params }),
  saveScore: (data: Record<string, any>) => request.post('/exam/score/save', data)
}

export const moralApi = {
  listRules: (orgId?: number) => request.get('/moral/rule/list', { params: { orgId } }),
  saveRule: (data: Record<string, any>) => request.post('/moral/rule/save', data),
  pageRecord: (params: Record<string, any>) => request.get<PageResult<any>>('/moral/record/page', { params }),
  saveRecord: (data: Record<string, any>) => request.post('/moral/record/save', data),
  listClassEval: (params: Record<string, any>) => request.get('/moral/class-eval/list', { params }),
  listActivity: (params: Record<string, any>) => request.get('/moral/activity/list', { params }),
  listEval: (params: Record<string, any>) => request.get('/moral/eval/list', { params }),
  saveEval: (data: Record<string, any>) => request.post('/moral/eval/save', data)
}
