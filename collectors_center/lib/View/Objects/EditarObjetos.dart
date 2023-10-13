import 'dart:io';
import 'package:collectors_center/Presenter/ObjectsPresenter.dart';
import 'package:collectors_center/View/AntesDeIngresar/Inicio.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectors_center/View/Objects/verObjectsCategoria.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditarObjetos extends StatefulWidget {
  final String url;
  final String firebaseURL;
  const EditarObjetos(
      {super.key, required this.url, required this.firebaseURL});

  @override
  State<EditarObjetos> createState() => _EditarObjetosState();
}

@override
void dispose() {}

class _EditarObjetosState extends State<EditarObjetos> {
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
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => verObjectsCategoria(categoria: category)),
    );
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

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Si el usuario no está autenticado, redirigirlo a la pantalla de inicio de sesión
      return const Inicio();
    }

    return AppWithDrawer(
      content: Scaffold(
        body: Container(
          height: screenHeight,
          width: screenWidth,
          color: peach,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Center(
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.url,
                        width: 200,
                        height: 200,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "       Nombre:",
                  style: TextStyle(color: brown, fontSize: 22),
                ),
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
                Text(
                  "       Descripción:",
                  style: TextStyle(color: brown, fontSize: 22),
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
                            child: Row(
                              children: [
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
                                Expanded(
                                  child: isEditing
                                      ? TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          maxLength: 300,
                                          controller: _descripcionController,
                                          style: TextStyle(
                                              color: brown, fontSize: 16),
                                          textAlign: TextAlign.center,
                                        )
                                      : Text(
                                          descripcion,
                                          style: TextStyle(
                                              color: brown, fontSize: 16),
                                          textAlign: TextAlign.center,
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
                                        descripcion =
                                            _descripcionController.text;
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: (screenHeight / 33),
                ),
                Center(
                  child: Container(
                    width: screenWidth - 200,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.red),
                      ),
                      onPressed: () {
                        deleteByCategory(context, widget.firebaseURL, category);
                      },
                      child: const Text('Eliminar'),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: screenWidth - 200,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.blue),
                      ),
                      onPressed: cancelar,
                      child: const Text('Regresar'),
                    ),
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
