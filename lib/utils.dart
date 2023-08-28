import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

String getGreetings() {
  String timeOfDay = "Bem-vindo(a),";

  final int hourNow = int.parse(DateFormat('H').format(DateTime.now()));
  if (hourNow < 12) {
    timeOfDay = "Bom dia,";
  } else if (hourNow <= 12 || hourNow < 18) {
    timeOfDay = "Boa tarde,";
  } else {
    timeOfDay = "Boa noite,";
  }

  return timeOfDay;
}

String getGravatar(String email) {
  return "https://www.gravatar.com/avatar/${md5.convert(utf8.encode(email)).toString()}.jpg";
}