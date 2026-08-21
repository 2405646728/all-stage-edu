import json, urllib.request

BASE = 'http://127.0.0.1:8080/api'

def call(path, method='GET', body=None, token=None, params=None):
    url = BASE + path
    if params:
        from urllib.parse import urlencode
        url += '?' + urlencode(params)
    req = urllib.request.Request(url, method=method)
    req.add_header('Content-Type', 'application/json; charset=utf-8')
    if token:
        req.add_header('Authorization', 'Bearer ' + token)
    data = json.dumps(body, ensure_ascii=False).encode('utf-8') if body is not None else None
    with urllib.request.urlopen(req, data) as resp:
        return json.loads(resp.read().decode('utf-8'))

login = call('/auth/login', 'POST', {'username': 'superadmin', 'password': '123456'})
token = login['data']['token']
print('login:', login['data']['user']['realName'])

tree = call('/sys/perm/menu/tree', token=token)
print('menu tree roots:', len(tree['data']), [r['menuName'] for r in tree['data']])

roles = call('/sys/perm/role/list', token=token)
print('roles:', [(r['roleCode'], r['roleName']) for r in roles['data']])

r1 = call('/sys/perm/role/menus', token=token, params={'roleId': 1})
print('super admin menu ids count:', len(r1['data']))

dicts = call('/sys/dict/type/list', token=token)
print('dict types:', len(dicts['data']), [d['typeCode'] for d in dicts['data'][:4]])

items = call('/sys/dict/item/list', token=token, params={'typeCode': 'stage'})
print('stage dict items:', len(items['data']), [i['itemName'] for i in items['data']])

mods = call('/sys/module/list', token=token)
print('modules:', len(mods['data']), mods['data'][0]['moduleName'])

sw = call('/sys/module/org-switch/list', token=token, params={'orgId': 1})
print('org1 module switches:', len(sw['data']), [(s['moduleCode'], s['enabled']) for s in sw['data']])

params = call('/sys/param/list', token=token)
print('global params:', len(params['data']), params['data'][0]['paramKey'])

dev = call('/sys/device/page', token=token, params={'current': 1, 'size': 5})
print('gate devices total:', dev['data']['total'])

logs = call('/sys/log/operation/page', token=token, params={'current': 1, 'size': 5})
print('operation logs total:', logs['data']['total'])

alerts = call('/sys/alert/page', token=token, params={'current': 1, 'size': 5})
print('alerts total:', alerts['data']['total'])

campus = call('/sys/campus/list', token=token, params={'orgId': 1})
print('campus:', campus['data'][0]['campusName'])

versions = call('/sys/version/list', token=token)
print('versions:', len(versions['data']))
print('SYS_ALL_OK')