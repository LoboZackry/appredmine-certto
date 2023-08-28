import 'package:flutter/material.dart';
import 'package:appredmine_certto/utils.dart';
import 'package:appredmine_certto/handlers/session.dart';
import 'package:appredmine_certto/views/user_config.dart';
import 'package:appredmine_certto/views/inform_dcal.dart';
import 'package:appredmine_certto/views/devolution/devolution.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget issuesList(context, int uID, String apiKey, author, List allowedIds) {
    final List checkedIds = [];
    for (final id in allowedIds) {
      if([6,32].contains(id)) {
        checkedIds.add(id);
      }
    }
    if (checkedIds.isEmpty) {
      return const Center(
        child: Text(
          "Não há opções liberadas ao seu usuário.",
          textAlign: TextAlign.center,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14,
            color: Color(0xff000000),
          ),
        ),
      );
    } else {
      final List<Widget> widgets = [];
      for (final id in checkedIds) {
        if (id == 32) {
          widgets.add(
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) =>
                      DevolutionScreen(id: uID, apiKey: apiKey, author: author)),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xff5f75e6),
                          shape: BoxShape.circle,
                        ),
                        child: const ImageIcon(
                          AssetImage("assets/images/icons/inventory.png"),
                          size: 30,
                          color: Color(0xffffffff),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                        child: Text(
                          "Devolução ao estoque",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 13,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
          );
        }
        if (id == 6) {
          widgets.add(
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => InformDcal(id: uID, apiKey: apiKey)),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(0),
                      padding: const EdgeInsets.all(0),
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xff60e260),
                        shape: BoxShape.circle
                      ),
                      child: const ImageIcon(
                        AssetImage("assets/images/icons/dispatcher.png"),
                        size: 30,
                        color: Color(0xffffffff),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: Text(
                        "Informe ao despacho",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 13,
                          color: Color(0xff000000)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          );
        }
      }
      return GridView(
        padding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 16
        ),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        children: widgets,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionHandler();
    final int id = session.getID();
    final String apiKey = session.getApiKey();
    final String userName = session.getUsername();
    final List allowedIds = session.getAllowedIds();

    return Scaffold(
      backgroundColor: const Color(0xfff2f3f4),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          getGreetings(),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff8c8989),
                          ),
                        ),
                        Text(
                          userName,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            color: Color(0xff000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                    width: 100,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image(
                          image: AssetImage("assets/images/logo_fiber.png"),
                          height: 100,
                          width: 140,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text(
                    "Tarefas",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 18,
                      color: Color(0xff000000),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const UserConfig()),
                      );
                    },
                    child: const Text(
                      "Configuração",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Color(0xff3a57e8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            issuesList(context, id, apiKey, userName, allowedIds),
          ],
        ),
      ),
    );
  }
}