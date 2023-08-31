import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:appredmine_certto/handlers/backend.dart';
import 'package:appredmine_certto/views/home_screen.dart';
import 'package:appredmine_certto/views/devolution/new_dvl_item.dart';

class DevolutionScreen extends StatefulWidget {
  const DevolutionScreen({Key? key}) : super(key: key);

  @override
  State<DevolutionScreen> createState() => _DevolutionScreenState();
}

class _DevolutionScreenState extends State<DevolutionScreen> with RestorationMixin {
  @override
  String? get restorationId => "devolution";

  @pragma('vm:entry-point')
  static Route<Map> buildDvlItemRoute(BuildContext context, Object? arguments) {
    return MaterialPageRoute<Map>(
      settings: RouteSettings(arguments: arguments),
      builder: (BuildContext context) => const NemDvlItem(),
    );
  }

  bool isLoading = false;
  List items = [];
  late RestorableRouteFuture<Map> newDvlItemRoute;
  final backupItems = RestorableString("");

  final backend = BackendHandler();

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(backupItems, "items_list");
    registerForRestoration(newDvlItemRoute, "newdvlitem_route");
  }

  @override
  void initState() {
    super.initState();
    newDvlItemRoute = RestorableRouteFuture<Map>(
      onPresent: (NavigatorState navigator, Object? arguments) {
        return Navigator.restorablePush(context, buildDvlItemRoute, arguments: arguments);
      }, onComplete: (Map result) {
        setState(() {
          items.add(result);
          backupItems.value = jsonEncode(items);
        });
      }
    );
  }

  @override
  void dispose() {
    newDvlItemRoute.dispose();
    backupItems.dispose();
    if (items.isNotEmpty) {
      for (final item in items) {
        File(item["image"]["path"]).delete();
      }
    }
    super.dispose();
  }

  Widget itemList() {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Não há itens na lista.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0
          ),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.blueGrey.shade200,
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.file(
                    File(items[index]["image"]["path"]),
                    height: 80,
                    width: 80,
                  ),
                  SizedBox(
                    width: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 5.0,
                        ),
                        RichText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          text: TextSpan(
                            text: 'Equipamento: ',
                            style: TextStyle(
                              color: Colors.blueGrey.shade800,
                              fontSize: 16.0
                            ),
                            children: [
                              TextSpan(
                                text: items[index]["equip"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          maxLines: 1,
                          text: TextSpan(
                            text: 'Serial: ',
                            style: TextStyle(
                              color: Colors.blueGrey.shade800,
                              fontSize: 16.0
                            ),
                            children: [
                              TextSpan(
                                text: items[index]["serial"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (isLoading != true) {
                        File(items[index]["image"]["path"]).delete();
                        setState(() {
                          items.removeAt(index);
                          backupItems.value = jsonEncode(items);
                        });
                      }
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)?.settings.arguments as Map<Object?, Object?>;
    if (backupItems.value != "") {
      items = jsonDecode(backupItems.value);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devolução ao estoque'),
      ),
      body: Column(
        children: [
          Expanded(
            child: itemList(),
          ),
        ],
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () async {
                if (isLoading != true) {
                  newDvlItemRoute.present({"id":args["id"],"apiKey":args["apiKey"]});
                }
              },
              child: Container(
                color: Colors.yellow.shade600,
                alignment: Alignment.center,
                height: 50.0,
                child: const Text(
                  'Adicionar item',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                if (isLoading != true) {
                  setState(() {
                    isLoading = true;
                  });

                  if(items.isNotEmpty) {
                    Map devolution = await backend.newDevolution(args["id"], args["apiKey"], args["author"], items);
                    if (context.mounted) {
                      if (devolution["error"] == false) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Sucesso! :D"),
                              content: Text("Tarefa #${devolution["issue"]["id"]} criada com sucesso para \"${devolution["issue"]["assigned_to"]["name"]}\"."),
                              actions: [
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute<void>(
                                        builder: (BuildContext context) => const HomeScreen(),
                                      ),
                                    );
                                  },
                                )
                              ]
                            );
                          }
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Ocorreu um erro..."),
                              content: Text(devolution["error_msg"]),
                              actions: [
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ]
                            );
                          }
                        );
                      }
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Ocorreu um erro..."),
                          content: const Text("Não há items na lista para devolução."),
                          actions: [
                            TextButton(
                              child: const Text("OK"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ]
                        );
                      }
                    );
                  }

                  setState(() {
                    isLoading = false;
                  });
                }
              },
              child: Container(
                color: Colors.green.shade600,
                alignment: Alignment.center,
                height: 50.0,
                child: isLoading ? const Center(child: CircularProgressIndicator()) :
                const Text(
                  'Enviar solicitação',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}