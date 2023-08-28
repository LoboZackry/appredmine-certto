import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class BackendHandler {
  static const url = 'https://appredmine-backend-cfnrl5ud6q-ue.a.run.app/';
  //static const url = 'http://10.0.13.197:8128/endpoints';

  BackendHandler();

  Future<Map> checkKey(final int id, final String key) async {
    final result = {};
    result["error"] = true;
    result["allowed"] = true;

    try {
      final request = {"endpoint":"check","payload":{}};

      final check = await http.post(
        Uri.parse("$url?id=$id&key=$key"),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode(request)
      ).timeout(const Duration(seconds: 20));

      if(check.statusCode == 200) {
        final Map<String,dynamic> response = jsonDecode(check.body);
        result["error"] = false;
        result["allowed"] = true;
        result["user"] = response["user"];
      } else if (check.statusCode == 401) {
        result["error"] = false;
        result["allowed"] = false;
      }
    } catch (error) {
      result["error"] = true;
      result["error_msg"] = error.toString();
    }

    return result;
  }

  Future<Map> tryLogIn(final String userName, passWord) async {
    final result = {};
    result["error"] = true;

    try {
      final request = {"endpoint":"auth","payload":{"username":userName,"password":passWord}};

      final auth = await http.post(
          Uri.parse(url),
          headers: {"Content-Type":"application/json"},
          body: jsonEncode(request)
      ).timeout(const Duration(seconds: 10));

      if(auth.statusCode == 200) {
        final Map<String,dynamic> response = jsonDecode(auth.body);
        if (response["allowed"] == true) {
          result["error"] = false;
          result["user"] = response["user"];
        } else {
          result['error_msg'] = "Usuário ou senha incorretos.";
        }
      } else {
        result['error_msg'] = "Não foi possivel comunicar com o servidor.";
      }
    } catch (e) {
      result['error_msg'] = e.toString();
    }

    return result;
  }

  Future<Map> doUpload(final int id, final String key, path, bool scan) async {
    final result = {};

    try {
      final Uint8List imagebytes = await File(path).readAsBytes();
      final String b64encoded = base64.encode(imagebytes);

      final request = {"endpoint":"upload","payload":{"scan":scan,"image":b64encoded}};

      final upload = await http.post(
          Uri.parse("$url?id=$id&key=$key"),
          headers: {"Content-Type":"application/json"},
          body: jsonEncode(request)
      ).timeout(const Duration(seconds: 10));

      if(upload.statusCode == 201) {
        final Map<String,dynamic> response = jsonDecode(upload.body);
        result["error"] = false;
        result["upload"] = response["upload"];
      } else {
        result["error"] = true;
        result['error_msg'] = "Não foi possivel realizar upload da imagem.";
      }
    } catch (e) {
      result["error"] = true;
      result['error_msg'] = e.toString();
    }

    return result;
  }

  Future<Map> newDevolution(final int id, final String key, author, final List items) async {
    final result = {};
    final dvlItems = [];

    for (final item in items) {
      final dvlItem = {"description":item["equip"],"file_token":item["image"]["token"],
        "file_name":item["image"]["filename"],"file_type":"image/jpg"};

      if (item["serial"] != "N/A") {
        dvlItem["data"] = item["serial"];
      }

      dvlItems.add(dvlItem);
    }

    final request = {"endpoint":"newdvl","payload":{"author":author,"items":dvlItems}};

    final dvl = await http.post(
        Uri.parse("$url?id=$id&key=$key"),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode(request)
    ).timeout(const Duration(seconds: 10));

    if(dvl.statusCode == 200) {
      final Map<String,dynamic> response = jsonDecode(dvl.body);
      result["error"] = false;
      result["issue"] = response["issue"];
    } else {
      result["error"] = true;
      result['error_msg'] = "Não foi possivel comunicar com o servidor.";
    }

    return result;
  }

  Future<Map> newDcalInform(final int id, final String key, codCli, codHsi, svcValue, dscValue, dscAut, final List images) async {
    final result = {};
    final request = {};
    request["endpoint"] = "newifm";
    request["payload"] = {};
    request["payload"]["images"] = [];

    for (final image in images) {
      final uploadImg = {};
      uploadImg["file_token"] = image["token"];
      uploadImg["file_name"] = image["filename"];
      uploadImg["file_type"] = "image/jpg";
      request["payload"]["images"].add(uploadImg);
    }

    request["payload"]["cod_cli"] = codCli;
    request["payload"]["cod_hsi"] = codHsi;
    request["payload"]["svc_val"] = svcValue;
    request["payload"]["dsc_val"] = dscValue;
    request["payload"]["dsc_aut"] = dscAut;

    final ifm = await http.post(
        Uri.parse("$url?id=$id&key=$key"),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode(request)
    ).timeout(const Duration(seconds: 10));

    if(ifm.statusCode == 200) {
      final Map<String,dynamic> response = jsonDecode(ifm.body);
      result["error"] = false;
      result["issue"] = response["issue"];
    } else {
      result["error"] = true;
      result['error_msg'] = "Não foi possivel comunicar com o servidor.";
    }

    return result;
  }
}