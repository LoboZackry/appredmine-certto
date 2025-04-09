# -*- coding: utf-8 -*-
from io import BytesIO
from uuid import uuid4
from requests import get, post

class Redmine():
    def __init__(self, redmine_url, redmine_key):
        self.url = redmine_url
        self.key = redmine_key
    
    def doCheck(self, uid, key):
        result = {}
        try:
            user = get("%s/users/%s.json?key=%s" % (self.url, uid, self.key)).json()
        except:
            result['error'] = True
            result['error_msg'] = "Não foi possivel se conectar ao Redmine."
        else:
            result['error'] = False
            if user['user']['api_key'] == key and user['user']['status'] == 1:
                result['allowed'] = True
            else:
                result['allowed'] = False

        return result

    def doUpload(self, key, image, scan):
        result = {}
        if len(scan) > 0:
            image = scan['image']
        
        try:
            filename = "%s.jpg" % str(uuid4()).upper().replace("-", "")[0:10]
            headers={'Content-Type': 'application/octet-stream'}
            data = BytesIO(image)
            upload = post("%s/uploads.json?key=%s&filename=%s" % (self.url, key, filename), headers=headers, data=data)
        except:
            result['error'] = True
            result['status_code'] = 502
            result['status_msg'] = "Não foi possivel se conectar ao Redmine."
        else:
            if upload.status_code == 201:
                upload = upload.json()
                result['error'] = False
                result['status_code'] = 201
                result['status_msg'] = 'OK'
                result['upload'] = {}
                result['upload']['token'] = upload['upload']['token']
                result['upload']['filename'] = filename
                if len(scan) > 0:
                    result['upload']['scan'] = {}
                    result['upload']['scan']['description'] = scan['desc']
                    result['upload']['scan']['data'] = scan['data']
            elif upload.status_code == 406 or upload.status_code == 422:
                result['error'] = True
                result['status_code'] = 422
                result['status_msg'] = "Arquivo enviado não compativel ou muito grande."
            else:
                result['error'] = True
                result['status_code'] = upload.status_code
                result['status_msg'] = "Arquivo não enviado devido a um erro desconhecido."

        return result
    
    def doAuth(self, username, password):
        result = {}
        try:
            auth = get("%s/users/current.json" % (self.url), auth=(username, password))
        except:
            result['error'] = True
            result['error_msg'] = "Não foi possivel se conectar ao Redmine."
        else:
            if auth.status_code == 200:
                try:
                    auth = auth.json()
                    user = get("%s/users/%s.json?include=groups&key=%s" % (self.url, auth['user']['id'], self.key)).json()
                except:
                    result['error'] = True
                    result['error_msg'] = "Não foi possivel se conectar ao Redmine."
                else:
                    result['error'] = False
                    if user['user']['status'] == 1:
                        result['allowed'] = True
                        result['user'] = {}
                        result['user']['id'] = user['user']['id']
                        result['user']['login'] = user['user']['login']
                        result['user']['mail'] = user['user']['mail']
                        result['user']['firstname'] = user['user']['firstname']
                        result['user']['lastname'] = user['user']['lastname']
                        result['user']['api_key'] = user['user']['api_key']
                        result['user']['allowed_issues'] = self.getAllowedIssuesByGroups(user['user']['groups'])
                    else:
                        result['allowed'] = False
            elif auth.status_code == 401:
                result['error'] = False
                result['allowed'] = False
            else:
                result['error'] = True
                result['error_msg'] = "Não foi possivel se conectar ao Redmine."
        
        return result
    
    def doNewInform(self, key, payload):
        result = {}
        request = {}
        
        request['issue'] = {}
        request["issue"]["project_id"] = 20 # CAL - Call Center
        request["issue"]["tracker_id"] = 6 # Solicitação
        request["issue"]["priority_id"] = 4 # ID 1 = 5 - Planejado (ID 4 = 4 - Baixo)
        request["issue"]["assigned_to_id"] = 60 # 60 (OPE - CAL - Despacho)
        request["issue"]["uploads"] = []
        request["issue"]["subject"] = "Negociação em campo - Cliente %s" % (payload['cod_cli'])
        request["issue"]["description"] = "<p>Informo que foi realizada a seguinte negocia&ccedil;&atilde;o em campo:</p>"
        request["issue"]["description"] += "<ul><li>C&oacute;digo do cliente: %s</li>" % (payload['cod_cli'])
        request["issue"]["description"] += "<li>N&deg; do plano: %s</li>" % (payload['cod_hsi'])
        request["issue"]["description"] += "<li>Valor dos servi&ccedil;os: %s</li>" % (payload['svc_val'])
        request["issue"]["description"] += "<li>Valor do desconto: %s</li>" % (payload['dsc_val'])
        request["issue"]["description"] += "<li>Autorizador do desconto: %s</li></ul>" % (payload['dsc_aut'])
        
        for image in payload['images']:
            request["issue"]["uploads"].append(
                {"token":image["file_token"],
                 "filename":image["file_name"],
                 "content_type":image["file_type"]})
        
        request["issue"]["description"] += "<p>Segue fotos do servi&ccedil;os e comprovantes em anexo.</p>"
        
        try:
            inform = post("%s/issues.json?key=%s" % (self.url, key), json=request)
        except:
            result['error'] = True
            result['status_msg'] = "Não foi possivel se conectar ao redmine."
        else:
            if inform.status_code == 201:
                inform = inform.json()
                if 'errors' not in inform.keys():
                    result['error'] = False
                    result['status_msg'] = "OK."
                    result['issue'] = inform['issue']
                else:
                    result['error'] = True
                    result['status_msg'] = "Ocorreu um erro ao tentar criar a tarefa."
            else:
                result['error'] = True
                result['status_msg'] = "Ocorreu um erro ao tentar criar a tarefa."

        return result

    def doNewDevolution(self, uid, key, payload):
        result = {}
        request = {}
        
        request['issue'] = {}
        request["issue"]["project_id"] = 17 # ADM - Administrativo
        request["issue"]["tracker_id"] = 32 # Devolução
        request["issue"]["priority_id"] = 2 # ID 1 = 5 - Planejado (ID 2 = 3 - Médio)
        request["issue"]["assigned_to_id"] = 297 # 297 (ADM - Almoxarifado)
        request["issue"]["custom_fields"] = [{"id":110,"value":uid}] # Custom field "Instalador" = 110
        request["issue"]["uploads"] = []
        request["issue"]["subject"] = "Devolução de materiais | %s" % (payload['author'])
        request["issue"]["description"] = "<p>Informo os seguintes itens para devolu&ccedil;&atilde;o:</p><ul>"
        
        for item in payload['items']:
            description = item["description"]
            file_descr = item["description"]
            if 'data' in item.keys():
                description += " | Serial: %s" % (item['data'])
                file_descr += " (SN: %s)" % (item['data'])
            request["issue"]["uploads"].append(
                {"token":item["file_token"],
                 "filename":item["file_name"],
                 "description":file_descr,
                 "content_type":item["file_type"]})
            
            request["issue"]["description"] += "<li>1x %s</li>" % (description)
        
        request["issue"]["description"] += "</ul><p>Segue fotos dos itens em anexo, por gentileza verificar e realizar a movimenta&ccedil;&atilde;o do material.</p>"
        
        try:
            devolution = post("%s/issues.json?key=%s" % (self.url, key), json=request)
        except:
            result['error'] = True
            result['status_msg'] = "Não foi possivel se conectar ao redmine."
        else:
            if devolution.status_code == 201:
                devolution = devolution.json()
                if 'errors' not in devolution.keys():
                    result['error'] = False
                    result['status_msg'] = "OK."
                    result['issue'] = devolution['issue']
                else:
                    result['error'] = True
                    result['status_msg'] = "Ocorreu um erro ao tentar criar a tarefa."
            else:
                result['error'] = True
                result['status_msg'] = "Não foi possivel se conectar ao redmine."

        return result

    def getUser(self, uid):
        result = {}
        try:
            user = get("%s/users/%s.json?include=groups&key=%s" % (self.url, uid, self.key)).json()
        except:
            result['error'] = True
            result['error_msg'] = "Não foi possivel se conectar ao Redmine."
        else:
            result['error'] = False
            result['user'] = {}
            result['user']['id'] = user['user']['id']
            result['user']['login'] = user['user']['login']
            result['user']['mail'] = user['user']['mail']
            result['user']['firstname'] = user['user']['firstname']
            result['user']['lastname'] = user['user']['lastname']
            result['user']['allowed_issues'] = self.getAllowedIssuesByGroups(user['user']['groups'])

        return result
    
    def getAllowedIssuesByGroups(self, groups):
        result = []
        
        for group in groups:
            try:
                get_group = get("%s/groups/%s.json?key=%s" % (self.url, group['id'], self.key)).json()
            except:
                pass
            else:
                if 'custom_fields' in get_group['group'].keys():
                    for field in get_group['group']['custom_fields']:
                        if field['id'] == 116:
                            if field['value'] is not None:
                                split = field['value'].split(",")
                                if split != ['']:
                                    for value in split:
                                        if value not in result:
                                            result.append(value)

        return result
    
    def getRandomString(self, string_length=10):
        return str(uuid4()).upper().replace("-", "")[0:string_length]
