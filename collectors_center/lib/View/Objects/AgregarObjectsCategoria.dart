//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Alexia                                                                //
//   Fecha:                              29/09/23                                                           //
//   Descripción:                    Permite agregar objetos a las categorias                    //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'dart:io';

import 'package:collectors_center/Presenter/ObjectsPresenter.dart';
import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class agregarObjectsCategoria extends StatefulWidget {
  final String categoria;
  const agregarObjectsCategoria({super.key, required this.categoria});

  @override
  State<agregarObjectsCategoria> createState() =>
      _agregarObjectsCategoriaState();
}

@override
void dispose() {}

class _agregarObjectsCategoriaState extends State<agregarObjectsCategoria> {
  PickedFile? _selectedImage;
  String filepath = "";
  File? uplaodImage;

  final _nombreArticuloController = TextEditingController();
  final _descripcionController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = PickedFile(pickedFile.path);
        filepath = pickedFile.path;
        uplaodImage = File(pickedFile.path);
      });
    }
  }

  Future<void> subirStorage() async {
    try {
      // Show the progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      String randomFileName = generateRandomFileName();
      final storageReference =
          FirebaseStorage.instance.ref().child('images/$randomFileName.jpg');

      // Upload the image to Firebase Storage
      final UploadTask uploadTask = storageReference.putFile(uplaodImage!);

      // Wait for the upload to complete
      await uploadTask.whenComplete(() async {
        // Get the download URL of the uploaded image
        final imageUrl = await storageReference.getDownloadURL();
        agregarObjetoCategoria(
            'images/$randomFileName.jpg',
            _nombreArticuloController.text.trim(),
            _descripcionController.text,
            widget.categoria);

        // Close the progress dialog
        Navigator.of(context).pop();

        goToVerObjectsCategorias(context, widget.categoria);
      });

      // Close the progress dialog if an error occurs
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error al subir la imagen",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pop();
    }
  }

  void agregar() {
    subirStorage();
  }

  void cancelar() {
    regresarAnterior(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return AppWithDrawer(
      content: Scaffold(
        body: Container(
          height: screenheight,
          width: screenWidth,
          color: peach,
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Nuevo\nartículo',
                  style: TextStyle(
                      fontSize: 42, color: brown, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Column(
                  children: [
                    if (_selectedImage != null)
                      Image.file(
                        File(_selectedImage!.path),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    else
                      Icon(
                        Icons.add_a_photo,
                        size: 120,
                      ),
                  ],
                ),
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _nombreArticuloController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Nombre',
                        hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF503A27),
                            fontSize: 20),
                      ),
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Descripcion',
                        hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF503A27),
                            fontSize: 20),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: (screenheight / 33),
              ),
              Container(
                width: screenWidth - 200,
                child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.blue)),
                  onPressed: agregar,
                  child: const Text('Guardar'),
                ),
              ),
              Container(
                width: screenWidth - 200,
                child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red)),
                  onPressed: cancelar,
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
