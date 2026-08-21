import request from './request'
import type { PageResult } from '@/types'

export interface DictType { id?: number; typeCode: string; typeName: string; isFrozen?: number; remark?: string }
export interface DictItem { id?: number; typeCode: string; itemCode: string; itemName: string; stage?: string; sortNo?: number; status?: number }
export interface ModuleItem { id: number; moduleCode: string; moduleName: string; stageScope: string; isPlugin: number; defaultOn: number; sortNo: number; description?: string }
export interface OrgSwitch { id?: number; orgId: number; moduleCode: string; enabled: number }
export interface GlobalParam { id?: number; paramGroup: string; paramKey: string; paramValue: string; valueType?: string; description?: string }
export interface GateDevice { id?: number; orgId: number; deviceCode: string; deviceName: string; deviceType: string; model?: string; vendor?: string; location?: string; status: number }
export interface OperationLog { id: number; username: string; orgId?: number; bizType: string; action: string; targetTable: string; targetId?: number; ip?: string; operatedAt?: string }
export interface AlertItem { id: number; alertLevel: string; alertType: string; moduleCode: string; title: string; content?: string; orgId?: number; status: number; handleRemark?: string; occurredAt?: string }

export const permApi = {
  listRoles: () => request.get('/sys/perm/role/list'),
  saveRole: (data: Record<string, any>) => request.post('/sys/perm/role/save', data),
  menuTree: () => request.get('/sys/perm/menu/tree'),
  roleMenus: (roleId: number) => request.get('/sys/perm/role/menus', { params: { roleId } }),
  saveRoleMenus: (data: Record<string, any>) => request.post('/sys/perm/role/menus/save', data)
}

export const templateApi = {
  list: () => request.get('/msg/template/list'),
  save: (data: Record<string, any>) => request.post('/msg/template/save', data)
}

export const dictApi = {
  listTypes: (keyword?: string) => request.get<DictType[]>('/sys/dict/type/list', { params: { keyword } }),
  listItems: (typeCode: string, stage?: string) => request.get<DictItem[]>('/sys/dict/item/list', { params: { typeCode, stage } }),
  saveType: (data: DictType) => request.post('/sys/dict/type/save', data),
  removeType: (id: number) => request.delete('/sys/dict/type/' + id),
  saveItem: (data: DictItem) => request.post('/sys/dict/item/save', data),
  removeItem: (id: number) => request.delete('/sys/dict/item/' + id)
}

export const platformApi = {
  listCampus: (orgId: number) => request.get('/sys/campus/list', { params: { orgId } }),
  saveCampus: (data: Record<string, any>) => request.post('/sys/campus/save', data),
  listModules: (stage?: string) => request.get<ModuleItem[]>('/sys/module/list', { params: { stage } }),
  listOrgSwitches: (orgId: number) => request.get<OrgSwitch[]>('/sys/module/org-switch/list', { params: { orgId } }),
  saveOrgSwitch: (data: OrgSwitch) => request.post('/sys/module/org-switch/save', data),
  listParams: (group?: string) => request.get<GlobalParam[]>('/sys/param/list', { params: { group } }),
  saveParam: (data: GlobalParam) => request.post('/sys/param/save', data),
  pageDevice: (params: Record<string, any>) => request.get<PageResult<GateDevice>>('/sys/device/page', { params }),
  saveDevice: (data: GateDevice) => request.post('/sys/device/save', data),
  pageLog: (params: Record<string, any>) => request.get<PageResult<OperationLog>>('/sys/log/operation/page', { params }),
  pageAlert: (params: Record<string, any>) => request.get<PageResult<AlertItem>>('/sys/alert/page', { params }),
  handleAlert: (id: number, remark?: string) => request.post('/sys/alert/handle', null, { params: { id, remark } }),
  listVersions: () => request.get('/sys/version/list'),
  saveVersion: (data: any) => request.post('/sys/version/save', data),
  listHotpatches: () => request.get('/sys/hotpatch/list'),
  listApis: (keyword?: string) => request.get('/sys/api/list', { params: { keyword } })
}