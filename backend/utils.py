# -*- coding: utf-8 -*-
from io import BytesIO
from base64 import b64decode
from pyzbar.pyzbar import decode
from numpy import uint8, frombuffer
from cv2 import imdecode, imencode, rectangle

def checkValidRequest(json):
    valid = False
    
    if all(key in json.keys() for key in ("endpoint", "payload")):
        if json['endpoint'] == 'auth':
            auth_values = ("username", "password")
            if all(key in json['payload'].keys() for key in auth_values):
                valid = True
        elif json['endpoint'] == 'check':
            valid = True
        elif json['endpoint'] == 'upload':
            upload_values = ("scan","image")
            if all(key in json['payload'].keys() for key in upload_values):
                valid = True
        elif json['endpoint'] == 'newifm':
            ifm_values = ("cod_cli","cod_hsi","svc_val","dsc_val","dsc_aut","images")
            if all(key in json['payload'].keys() for key in ifm_values):
                if len(json['payload']['images']) != 0:
                    valid = True
                    image_values = ("file_token","file_name","file_type")
                    for image in json['payload']['images']:
                        if valid == True:
                            if all(key in image.keys() for key in image_values):
                                valid = True
                            else:
                                valid = False
        elif json['endpoint'] == 'newdvl':
            dvl_values = ("author", "items")
            if all(key in json['payload'].keys() for key in dvl_values):
                if len(json['payload']['items']) != 0:
                    valid = True
                    item_values = ("description","file_token","file_name","file_type")
                    for item in json['payload']['items']:
                        if valid == True:
                            if all(key in item.keys() for key in item_values):
                                valid = True
                            else:
                                valid = False

    return valid

def decodeImage(base64_encoded):
    result = False
    try:
        base64_decoded = imdecode(frombuffer(BytesIO(b64decode(base64_encoded)).getbuffer(), uint8), 1)
    except:
        pass
    else:
        result = imencode(".jpg", base64_decoded)[1]

    return result

def readBarcode(image):
    result = {}
    try:
        image = imdecode(frombuffer(BytesIO(image).getbuffer(), uint8), 1)
        scan = decode(image)
    except:
        pass
    else:
        for obj in scan:
            if len(result) == 0:
                if len(obj.data.decode()) == 16:
                    result['desc'] = "ONT/ONU HUAWEI"
                elif len(obj.data.decode()) == 13:
                    result['desc'] = "Roteador TP-Link/Intelbras/Zyxel"
                elif len(obj.data.decode()) == 9:
                    result['desc'] = "ONT/ONU INTELBRAS"
                
                if len(result) > 0:
                    result['data'] = obj.data.decode()
                    image = rectangle(image,(obj.rect.left, obj.rect.top),(obj.rect.left + obj.rect.width, obj.rect.top + obj.rect.height),color=(0, 255, 0),thickness=5)
                    result['image'] = imencode(".jpg", image)[1]

    return result