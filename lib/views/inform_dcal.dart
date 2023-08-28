import 'dart:io';
import 'package:appredmine_certto/handlers/backend.dart';
import 'package:appredmine_certto/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InformDcal extends StatefulWidget {
  final int id;
  final String apiKey;

  const InformDcal({Key? key, required this.id, required this.apiKey}) : super(key: key);

  @override
  State<InformDcal> createState() => _InformDcalState();
}

class _InformDcalState extends State<InformDcal> {
  bool isLoading = false;
  bool isUploading = false;

  final backend = BackendHandler();

  final codCliField = TextEditingController();
  final codHsiField = TextEditingController();
  final svcValueField = TextEditingController(text: "R\$");
  final dscValueField = TextEditingController(text: "R\$");
  final dscAutField = TextEditingController();

  final ImagePicker picker = ImagePicker();
  final List<Map> pickedImages = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (pickedImages.isNotEmpty) {
      for (final image in pickedImages) {
        File(image["path"]).delete();
      }
    }

    codCliField.dispose();
    codHsiField.dispose();
    svcValueField.dispose();
    dscValueField.dispose();
    dscAutField.dispose();

    super.dispose();
  }

  Widget imageGrid() {
    if (pickedImages.isEmpty) {
      return const Center(
        child:Text(
          "Não há fotos anexadas.",
          textAlign: TextAlign.start,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        physics: const ScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          childAspectRatio: 1.2,
        ),
        itemCount: pickedImages.length,
        itemBuilder: (context, index) => Stack(
          children: [
            Image.file(
              File(pickedImages[index]["path"]),
              height: 120,
              width: 120,
              fit: BoxFit.cover,
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
                onPressed: () {
                  if (isLoading != true && isUploading != true) {
                    File(pickedImages[index]["path"]).delete();
                    setState(() {
                      pickedImages.removeAt(index);
                    });
                  }
                }
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffffffff),
          appBar: AppBar(
            title: const Text("Informe ao despacho"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            "Código cliente:",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                            child: TextField(
                              controller: codCliField,
                              keyboardType: TextInputType.number,
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
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            "N° Plano:",
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
                            controller: codHsiField,
                            keyboardType: TextInputType.number,
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
                                horizontal: 12
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Color(0xff808080),
                  height: 16,
                  thickness: 0,
                  indent: 0,
                  endIndent: 0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            "Valor dos serviços:",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                            child: TextField(
                              controller: svcValueField,
                              keyboardType: TextInputType.number,
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
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            "Valor do desconto:",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                            child: TextField(
                              controller: dscValueField,
                              keyboardType: TextInputType.number,
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Color(0xff808080),
                  height: 16,
                  thickness: 0,
                  indent: 0,
                  endIndent: 0,
                ),
                const Text(
                  "Autorizador do desconto:",
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
                  controller: dscAutField,
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
                const Text(
                  "Fotos do serviço e comprovante:",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: imageGrid(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 2, 0),
                      child: MaterialButton(
                        onPressed: () async {
                          if (isLoading != true && isUploading != true) {
                            final XFile? image = await picker.pickImage(source: ImageSource.camera);
                            if (image!.path.isNotEmpty) {
                              setState(() {
                                isUploading = true;
                              });

                              final upload = await backend.doUpload(widget.id, widget.apiKey, image.path, false);
                              if (upload["error"] == false) {
                                pickedImages.add({
                                  "token":upload["upload"]["token"],
                                  "filename":upload["upload"]["filename"],
                                  "path":image.path});
                              }

                              setState(() {
                                isUploading = false;
                              });
                            }
                          }
                        },
                        color: const Color(0xffffffff),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(
                            color: Color(0xff808080),
                            width: 1
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
                      padding: const EdgeInsets.fromLTRB(2, 10, 0, 0),
                      child: MaterialButton(
                        onPressed: () async {
                          if (isLoading != true && isUploading != true) {
                            final List<XFile> images = await picker.pickMultiImage();
                            if (images.isNotEmpty) {
                              setState(() {
                                isUploading = true;
                              });
                              for(final image in images) {
                                if (image.path.isNotEmpty) {
                                  final upload = await backend.doUpload(widget.id, widget.apiKey, image.path, false);
                                  if (upload["error"] == false) {
                                    pickedImages.add({
                                      "token":upload["upload"]["token"],
                                      "filename":upload["upload"]["filename"],
                                      "path":image.path});
                                  }
                                }
                              }
                              setState(() {
                                isUploading = false;
                              });
                            }
                          }
                        },
                        color: const Color(0xffffffff),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(
                            color: Color(0xff808080),
                            width: 1
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        textColor: const Color(0xff000000),
                        height: 40,
                        minWidth: 140,
                        child: const Text(
                          "Adicionar fotos",
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
              ],
            ),
          ),
          bottomNavigationBar: InkWell(
            onTap: () async {
              if (isLoading != true && isUploading != true) {
                setState(() {
                  isLoading = true;
                });

                bool error = false;
                String errorMsg = "";
                if(codCliField.text.isEmpty) {
                  error==false?error=true:null;
                  errorMsg += "\n- Campo \"código cliente\" em branco.";
                }
                if(codHsiField.text.isEmpty) {
                  error==false?error=true:null;
                  errorMsg += "\n- Campo \"n° plano\" em branco.";
                }
                if(svcValueField.text.isEmpty || svcValueField.text == "R\$") {
                  error==false?error=true:null;
                  errorMsg += "\n- Campo \"valor serviços\" em branco.";
                }
                if(dscValueField.text.isEmpty || dscValueField.text == "R\$") {
                  error==false?error=true:null;
                  errorMsg += "\n- Campo \"valor desconto\" em branco.";
                }
                if(dscAutField.text.isEmpty) {
                  error==false?error=true:null;
                  errorMsg += "\n- Campo \"autorizador desconto\" em branco.";
                }
                if(pickedImages.isEmpty) {
                  error==false?error=true:null;
                  errorMsg += "\n- Necessário anexar foto.";
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
                  Map dcalInform = await backend.newDcalInform(widget.id, widget.apiKey, codCliField.text,
                      codHsiField.text, svcValueField.text, dscValueField.text, dscAutField.text, pickedImages);

                  if (context.mounted) {
                    if (dcalInform["error"] == false) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Sucesso! :D"),
                            content: Text("Tarefa #${dcalInform["issue"]["id"]} criada com sucesso para \"${dcalInform["issue"]["assigned_to"]["name"]}\"."),
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
                            content: Text(dcalInform["error_msg"]),
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
                'Enviar informe ao despacho',
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
      ]
    );
  }
}