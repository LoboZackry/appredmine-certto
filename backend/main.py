import os
import utils
from redmine_lib import Redmine
from flask import Flask, request, jsonify

redmine_url = os.environ.get("URL", "https://www.redmine.org")
redmine_key = os.environ.get("KEY", "abcdefghijklmnopqrstuvwxyz1234567890")

app = Flask(__name__)
brain = Redmine(redmine_url, redmine_key)

@app.route('/endpoints', methods=['POST'])
def main_func():
    response = {}
    if 'Content-Type' in dict(request.headers).keys() and request.headers['Content-Type'].startswith("application/json"):
        try:
            req_json = request.get_json()
        except:
            response['code'] = 400
            response['error'] = True
            response['message'] = "O corpo da requisição recebida é inválido."
        else:
            req = utils.checkValidRequest(req_json)
            if req is True:
                if req_json['endpoint'] == "auth":
                    auth = brain.doAuth(req_json['payload']['username'], req_json['payload']['password'])
                    if auth['error'] is False:
                        if auth['allowed'] is True:
                            response['code'] = 200
                            response['error'] = False
                            response['message'] = "OK."
                            response['allowed'] = True
                            response['user'] = auth['user']
                        else:
                            response['code'] = 200
                            response['error'] = False
                            response['message'] = "OK."
                            response['allowed'] = False
                    else:
                        response['code'] = 502
                        response['error'] = True
                        response['message'] = auth['error_msg']
                else:
                    if request.args and all(arg in request.args for arg in ("id", "key")):
                        uid = request.args.get('id')
                        key = request.args.get('key')
                        check = brain.doCheck(uid, key)
                        if check['error'] is False:
                            if check['allowed'] is True:
                                match req_json['endpoint']:
                                    case "check":
                                        user = brain.getUser(uid)
                                        if user['error'] is False:
                                            response['code'] = 200
                                            response['error'] = False
                                            response['message'] = "OK."
                                            response['user'] = user['user']
                                        else:
                                            response['code'] = 502
                                            response['error'] = True
                                            response['message'] = user['error_msg']
                                    case "upload":
                                        decoded = utils.decodeImage(req_json['payload']['image'])
                                        if decoded is not False:
                                            if req_json['payload']['scan'] is True:
                                                scan = utils.readBarcode(decoded)
                                            else:
                                                scan = []
                                            upload = brain.doUpload(key, decoded, scan)
                                            response['code'] = upload['status_code']
                                            response['error'] = upload['error']
                                            response['message'] = upload['status_msg']
                                            if upload['error'] is False:
                                                response['upload'] = upload['upload']
                                    case "newdvl":
                                        devolution = brain.doNewDevolution(uid,key,req_json['payload'])
                                        if devolution['error'] is False:
                                            response['code'] = 200
                                            response['error'] = False
                                            response['message'] = "OK."
                                            response['issue'] = devolution['issue']
                                        else:
                                            response['code'] = 500
                                            response['error'] = True
                                            response['message'] = devolution['status_msg']
                                    case "newifm":
                                        inform = brain.doNewInform(key,req_json['payload'])
                                        if inform['error'] is False:
                                            response['code'] = 200
                                            response['error'] = False
                                            response['message'] = "OK."
                                            response['issue'] = inform['issue']
                                        else:
                                            response['code'] = 500
                                            response['error'] = True
                                            response['message'] = inform['status_msg']
                                    case _:
                                        response['code'] = 400
                                        response['error'] = True
                                        response['message'] = "Endpoint inválido."
                            else:
                                response['code'] = 401
                                response['error'] = True
                                response['message'] = "Credenciais de acesso inválidas."
                        else:
                            response['code'] = 502
                            response['error'] = True
                            response['message'] = check['error_msg']
                    else:
                        response['code'] = 400
                        response['error'] = True
                        response['message'] = "Não há argumentos o suficiente para concluir a solicitação."
            else:
                response['code'] = 400
                response['error'] = True
                response['message'] = "O corpo da requisição recebida é inválido."
    else:
        response['code'] = 415
        response['error'] = True
        response['message'] = "O tipo de requisição recebida não é suportada."

    return jsonify(response), response['code']

if __name__ == "__main__":
    app.run(debug=False, host='0.0.0.0', port=int(os.environ.get("PORT", 8080)))