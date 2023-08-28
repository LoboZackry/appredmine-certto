import 'package:flutter/material.dart';
import 'package:appredmine_certto/handlers/session.dart';
import 'package:appredmine_certto/views/login_screen.dart';
import 'package:appredmine_certto/views/home_screen.dart';

void main() async {
  final session = SessionHandler();
  await session.initSession();
  runApp(MaterialApp(
    home: await session.checkLogin() ? const HomeScreen() : const LoginScreen(),
  ));
}