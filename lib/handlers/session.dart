import 'package:get_storage/get_storage.dart';
import 'package:appredmine_certto/handlers/backend.dart';

class SessionHandler {
  static final session = GetStorage();
  static final backend = BackendHandler();

  Future<void> initSession() async {
    await GetStorage.init();
  }

  Future<bool> checkLogin() async {
    bool result = false;
    final uID = session.read('id');
    final apiKey = session.read('api_key');

    if (uID != null && apiKey != null) {
      final user = await backend.checkKey(uID, apiKey);
      if (user['error'] != true) {
        if (user["allowed"] == true) {
          for (final key in user["user"].keys) {
            final currValue = session.read(key);
            if (currValue != user["user"][key]) {
              session.write(key, user["user"][key]);
            }
          }
          result = true;
        } else {
          session.erase();
        }
      } else {
        result = true;
      }
    }

    return result;
  }

  Future<Map> attemptLogin(String userName, String passWord) async {
    final result = {};

    if (userName != "" && passWord != "") {
      final login = await backend.tryLogIn(userName, passWord);
      if (login["error"] != true) {
        for (final key in login["user"].keys) {
          session.write(key, login["user"][key]);
        }
        result["error"] = false;
      } else {
        result["error"] = true;
        result["error_msg"] = login["error_msg"];
      }
    } else {
      result["error"] = true;
      result["error_msg"] = "Um dos campos está vazio.";
    }

    return result;
  }

  void doLogout() {
    session.erase();
  }

  String getUsername() {
    return "${session.read("firstname")} ${session.read("lastname")}";
  }

  String getApiKey() {
    return session.read("api_key");
  }

  String getEmail() {
    return session.read("mail");
  }

  int getID() {
    return session.read("id");
  }

  List getAllowedIds() {
    return session.read("allowed_issues");
  }
}