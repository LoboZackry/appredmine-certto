import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appredmine_certto/handlers/backend.dart';

class NemDvlItem extends StatefulWidget {
  const NemDvlItem({Key? key}) : super(key: key);

  @override
  State<NemDvlItem> createState() => _NemDvlItemState();
}

class _NemDvlItemState extends State<NemDvlItem> with RestorationMixin {
  @override
  String? get restorationId => "new_dvl_item";

  bool purgeCache = true;
  bool isUploading = false;
  Map uploadedImage = {};

  final backend = BackendHandler();

  final backupImage = RestorableString("");
  final descriptionField = RestorableTextEditingController();
  final serialCodeField = RestorableTextEditingController();

  final ImagePicker picker = ImagePicker();

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(backupImage, "image_map");
    registerForRestoration(serialCodeField, "serial_field");
    registerForRestoration(descriptionField, "description_field");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (purgeCache == true) {
      if (uploadedImage.isNotEmpty) {
        File(uploadedImage["path"]).delete();
      }
    }
    backupImage.dispose();
    serialCodeField.dispose();
    descriptionField.dispose();
    super.dispose();
  }

  void setImage(String path, token, filename) {
    uploadedImage["token"] = token;
    uploadedImage["filename"] = filename;
    uploadedImage["path"] = path;
    backupImage.value = jsonEncode(uploadedImage);
  }

  void checkLostImage(context, int id, String key) async {
    final LostDataResponse lostData = await picker.retrieveLostData();
    if (lostData.isEmpty == false) {
      if (lostData.file!.path.isNotEmpty) {
        setState(() {
          isUploading = true;
        });
        var upload = await backend.doUpload(id, key, lostData.file!.path, true);
        if (upload["error"] == false) {
          setState(() {
            setImage(lostData.file!.path,upload["upload"]["token"],upload["upload"]["filename"]);
            if (upload["upload"].containsKey("scan")) {
              if (descriptionField.value.text.isEmpty) {
                descriptionField.value.text = upload["upload"]["scan"]["description"];
              }
              if (serialCodeField.value.text.isEmpty) {
                serialCodeField.value.text = upload["upload"]["scan"]["data"];
              }
            } else {
              if (serialCodeField.value.text.isEmpty) {
                serialCodeField.value.text = "N/A";
              }
            }
            isUploading = false;
          });
        } else {
          setState(() {
            isUploading = false;
          });
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Ops, ocorreu um erro:"),
                  content: Text(upload["error_msg"]),
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
      }
    }
  }

  Widget imageDisplay(int id, String apiKey) {
    if (uploadedImage.isEmpty) {
      return const Text(
        "Nenhuma foto anexada.",
        textAlign: TextAlign.center,
        overflow: TextOverflow.clip,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      );
    } else {
      return Stack(
        children: [
          Image.file(
            File(uploadedImage["path"]),
          ),
          Positioned(
            right: -11,
            top: -11,
            child: IconButton(
              icon: Icon(
                Icons.cancel,
                color: Colors.red.withOpacity(0.8),
                size: 18,
              ),
              onPressed: () => setState(() {
                if (isUploading != true) {
                  if (uploadedImage.isNotEmpty) {
                    File(uploadedImage["path"]).delete();
                  }
                  descriptionField.value.text = "";
                  serialCodeField.value.text = "";
                  uploadedImage = {};
                  backupImage.value = "";
                }
              }),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)?.settings.arguments as Map<Object?, Object?>;

    if (backupImage.value != "") {
      uploadedImage = jsonDecode(backupImage.value);
    }

    checkLostImage(context, args["id"], args["apiKey"]);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffffffff),
          appBar: AppBar(
            title: const Text("Adicionar item a lista"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: Text(
                    "Descrição do item:",
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                  ),
                ),
                TextField(
                  controller: descriptionField.value,
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
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xff000000),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xff000000),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xff000000),
                        width: 1,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xfff2f2f3),
                    isDense: false,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                  ),
                ),
                const Divider(
                  color: Color(0xff808080),
                  height: 16,
                  thickness: 0,
                  indent: 0,
                  endIndent: 0,
                ),
                const Text(
                  "Serial do item (se houver):",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                ),
                TextField(
                  controller: serialCodeField.value,
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
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xff000000),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xff000000),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: const BorderSide(
                        color: Color(0xff000000),
                        width: 1
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xfff2f2f3),
                    isDense: false,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                  ),
                ),
                const Divider(
                  color: Color(0xff808080),
                  height: 16,
                  thickness: 0,
                  indent: 0,
                  endIndent: 0,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: Text(
                    "Foto do item:",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: imageDisplay(args["id"],args["apiKey"]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 2, 2),
                      child: MaterialButton(
                        onPressed: () async {
                          if (isUploading != true) {
                            final XFile? image = await picker.pickImage(source: ImageSource.camera);
                            if (image!.path.isNotEmpty) {
                              setState(() {
                                isUploading = true;
                              });
                              var upload = await backend.doUpload(args["id"], args["apiKey"], image.path, true);
                              if (upload["error"] == false) {
                                setState(() {
                                  setImage(image.path, upload["upload"]["token"], upload["upload"]["filename"]);
                                  if (upload["upload"].containsKey("scan")) {
                                    if (descriptionField.value.text.isEmpty) {
                                      descriptionField.value.text = upload["upload"]["scan"]["description"];
                                    }
                                    if (serialCodeField.value.text.isEmpty) {
                                      serialCodeField.value.text = upload["upload"]["scan"]["data"];
                                    }
                                  } else {
                                    if (serialCodeField.value.text.isEmpty) {
                                      serialCodeField.value.text = "N/A";
                                    }
                                  }
                                  isUploading = false;
                                });
                              } else {
                                setState(() {
                                  isUploading = false;
                                });
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Ops, ocorreu um erro:"),
                                        content: Text(upload["error_msg"]),
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
                            }
                          }
                        },
                        color: const Color(0xffffffff),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(
                            color: Color(0xff808080),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        textColor: const Color(0xff000000),
                        height: 40,
                        minWidth: 140,
                        child: const Text(
                          "Tirar foto",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 5, 0, 2),
                      child: MaterialButton(
                        onPressed: () async {
                          if (isUploading != true) {
                            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                            if (image!.path.isNotEmpty) {
                              setState(() {
                                isUploading = true;
                              });
                              var upload = await backend.doUpload(args["id"], args["apiKey"], image.path, true);
                              if (upload["error"] == false) {
                                setState(() {
                                  setImage(image.path, upload["upload"]["token"], upload["upload"]["filename"]);
                                  if (upload["upload"].containsKey("scan")) {
                                    if (descriptionField.value.text.isEmpty) {
                                      descriptionField.value.text = upload["upload"]["scan"]["description"];
                                    }
                                    if (serialCodeField.value.text.isEmpty) {
                                      serialCodeField.value.text = upload["upload"]["scan"]["data"];
                                    }
                                  } else {
                                    if (serialCodeField.value.text.isEmpty) {
                                      serialCodeField.value.text = "N/A";
                                    }
                                  }
                                  isUploading = false;
                                });
                              } else {
                                setState(() {
                                  isUploading = false;
                                });
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Ops, ocorreu um erro:"),
                                        content: Text(upload["error_msg"]),
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
                            }
                          }
                        },
                        color: const Color(0xffffffff),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(
                            color: Color(0xff808080),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        textColor: const Color(0xff000000),
                        height: 40,
                        minWidth: 140,
                        child: const Text(
                          "Adicionar foto",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  "*Descrição e serial serão preenchidos automaticamente caso a foto anexada esteja nitida.",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                    color: Color(0xff000000),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: InkWell(
            onTap: () {
              if (isUploading != true) {
                bool error = false;
                String errorMsg = "";
                if (uploadedImage.isEmpty) {
                  error==false?error=true:null;
                  errorMsg += "\n- Necessário anexar foto.";
                }
                if (descriptionField.value.text.isEmpty) {
                  error==false?error=true:null;
                  errorMsg += "\n- Campo descrição está vazio.";
                }
                if (serialCodeField.value.text.isEmpty) {
                  serialCodeField.value.text = "N/A";
                }

                if (error == true) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Ops, há campos em branco:"),
                        content: Text(errorMsg),
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
                } else {
                  purgeCache = false;
                  Navigator.pop(context, {"image":uploadedImage,"equip":descriptionField.value.text, "serial":serialCodeField.value.text});
                }
              }
            },
            child: Container(
              color: Colors.green.shade600,
              alignment: Alignment.center,
              height: 50.0,
              child: const Text(
                'Adicionar item a lista',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (isUploading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(
              dismissible: false,
              color: Colors.black
            ),
          ),
        if (isUploading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}