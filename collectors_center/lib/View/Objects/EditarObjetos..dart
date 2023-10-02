import 'dart:io';
import 'package:collectors_center/Presenter/ObjectsPresenter.dart';
import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:cached_network_image/cached_network_image.dart';

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
  PickedFile? _selectedImage;
  String filepath = "";
  File? uploadImage;
  Map<String, String> imageInfo = {};
  String name = "";
  String descripcion = "";
  String category = "";

  final _nombreArticuloController = TextEditingController();
  final _descripcionController = TextEditingController();

  void cancelar() {
    regresarAnterior(context);
  }

  void setImageInfo() async {
    imageInfo = await getImageInfoByImageUrl(context, widget.firebaseURL);
    print(imageInfo);
    setState(() {
      // Update the state with the fetched data
      name = imageInfo['imageName'] != null
          ? imageInfo['imageName'].toString()
          : "";
      descripcion = imageInfo['imageDescription'] != null
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

// Define a variable to store the result

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
                        fontWeight: FontWeight.bold),
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
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    width: screenWidth - 150,
                    height: 50,
                    decoration: BoxDecoration(
                      color: myColor,
                      border: Border.all(color: Colors.white, width: .2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        name,
                        style: TextStyle(color: brown, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                      width: screenWidth - 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: myColor,
                        border: Border.all(color: Colors.white, width: .2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          descripcion,
                          style: TextStyle(color: brown, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ),
                SizedBox(
                  height: (screenHeight / 33),
                ),
                Container(
                  width: screenWidth - 200,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.red)),
                    onPressed: () {
                      deleteByCategory(context, widget.firebaseURL, category);
                    },
                    child: const Text('Eliminar'),
                  ),
                ),
                Container(
                  width: screenWidth - 200,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.blue)),
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
