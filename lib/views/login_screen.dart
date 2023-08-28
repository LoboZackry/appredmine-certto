import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:appredmine_certto/handlers/session.dart';
import 'package:appredmine_certto/views/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  final session = SessionHandler();

  final usernameField = TextEditingController();
  final passwordField = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    usernameField.dispose();
    passwordField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Image(
              image: const AssetImage("assets/images/login_background.png"),
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.65,
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0)
                  ),
                  border: Border.all(
                    color: const Color(0x4d9e9e9e),
                    width: 1
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text(
                          "Bem-vindo(a)!",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            fontSize: 20,
                            color: Color(0xff000000),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Text(
                            "Faça login para continuar",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff5e5e5e),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: TextField(
                            controller: usernameField,
                            obscureText: false,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                            decoration: InputDecoration(
                              disabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff000000),
                                  width: 1
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff000000),
                                  width: 1
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff000000),
                                   width: 1
                                ),
                              ),
                              labelText: "Usuário",
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 16,
                                color: Color(0xff000000),
                              ),
                              filled: true,
                              fillColor: const Color(0x00ffffff),
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12
                              ),
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Color(0xff212435),
                                size: 18
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: TextField(
                            controller: passwordField,
                            obscureText: true,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                            decoration: InputDecoration(
                              disabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff000000),
                                  width: 1
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff000000),
                                  width: 1
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff000000),
                                  width: 1
                                ),
                              ),
                              labelText: "Senha",
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 16,
                                color: Color(0xff000000),
                              ),
                              filled: true,
                              fillColor: const Color(0xffffffff),
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Color(0xff212435),
                                size: 18
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: isLoading ? const Center(child: CircularProgressIndicator()) :
                          MaterialButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });

                              final login = await session.attemptLogin(usernameField.text, passwordField.text);
                              if (context.mounted) {
                                if (login['error'] == false) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Usuário logado com sucesso!"),
                                      ),
                                    );
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute<void>(
                                        builder: (BuildContext context) => const HomeScreen(),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(login['error_msg']),
                                    ),
                                  );
                                }
                              }

                              setState(() {
                                isLoading = false;
                              });
                            },
                            color: const Color(0xff3a57e8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(16),
                            textColor: const Color(0xffffffff),
                            height: 45,
                            minWidth: MediaQuery.of(context).size.width,
                            child: const Text(
                              "Entrar »",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () async {
                                const url = 'https://brain.certto.com.br/account/lost_password';
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                }
                              },
                              child: const Text(
                                "Perdi minha senha",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff5e5e5e),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}