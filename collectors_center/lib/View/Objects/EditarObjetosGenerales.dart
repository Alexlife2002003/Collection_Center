import 'dart:io';
import 'package:collectors_center/Presenter/ObjectsPresenter.dart';
import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

class EditarObjetosGenerales extends StatefulWidget {
  final String url;
  final String firebaseURL;
  const EditarObjetosGenerales(
      {super.key, required this.url, required this.firebaseURL});

  @override
  State<EditarObjetosGenerales> createState() => _EditarObjetosGeneralesState();
}

@override
void dispose() {}

class _EditarObjetosGeneralesState extends State<EditarObjetosGenerales> {
  String filepath = "";
  File? uploadImage;
  Map<String, String> imageInfo = {};
  String name = "";
  String descripcion = "";
  String category = "";

  final _nombreArticuloController = TextEditingController();
  final _descripcionController = TextEditingController();

  bool isEditing = false;

  void cancelar() {
    regresarAnterior(context);
  }

  void setImageInfo() async {
    imageInfo = await getImageInfoByImageUrl(context, widget.firebaseURL);
    setState(() {
      // Update the state with the fetched data
      name = imageInfo['imageName'] != null
          ? imageInfo['imageName'].toString()
          : "";
      descripcion = imageInfo['imageDescription'] != null
          ? imageInfo['imageDescription'].toString()
          : "";
      _descripcionController.text = imageInfo['imageDescription'] != null
          ? imageInfo['imageDescription'].toString()
          : "";
      category = imageInfo['imageCategory'] != null
          ? imageInfo['imageCategory'].toString()
          : "";
    });
  }

  @override
  void initState() {
    super.initState();
    setImageInfo();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AppWithDrawer(
      content: Scaffold(
        body: Container(
          height: screenHeight,
          width: screenWidth,
          color: peach,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Editar\nartículo',
                    style: TextStyle(
                      fontSize: 42,
                      color: brown,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.url,
                      width: 200,
                      height: 200,
                    )
                  ],
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    width: screenWidth - 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: myColor,
                      border: Border.all(color: Colors.white, width: .2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: brown,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: screenWidth - 50,
                          decoration: BoxDecoration(
                            color: myColor,
                            border: Border.all(color: Colors.white, width: .2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: isEditing
                                ? TextFormField(
                                    controller: _descripcionController,
                                    style:
                                        TextStyle(color: brown, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  )
                                : Text(
                                    descripcion,
                                    style:
                                        TextStyle(color: brown, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isEditing ? Icons.check : Icons.edit,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isEditing) {
                              descripcion = _descripcionController.text;
                              editDescriptionByImageUrl(
                                  context,
                                  widget.firebaseURL,
                                  _descripcionController.text);
                              // You can save the edited description here
                            }

                            isEditing = !isEditing;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          // Handle deleting the description here
                          setState(() {
                            descripcion = "";
                            isEditing = false;
                            _descripcionController.text = "";
                            clearDescriptionByImageUrl(
                                context, widget.firebaseURL, "");
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: (screenHeight / 33),
                ),
                Container(
                  width: screenWidth - 200,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red),
                    ),
                    onPressed: () {
                      deleteByGeneral(context, widget.firebaseURL);
                    },
                    child: const Text('Eliminar'),
                  ),
                ),
                Container(
                  width: screenWidth - 200,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.blue),
                    ),
                    onPressed: cancelar,
                    child: const Text('Regresar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
