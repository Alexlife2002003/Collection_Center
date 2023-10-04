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
  File? uploadImage;

  final _nombreArticuloController = TextEditingController();
  final _descripcionController = TextEditingController();

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    Navigator.pop(context);
    if (pickedFile != null) {
      final File compressedImage = await _compressImage(File(pickedFile.path));
      setState(() {
        _selectedImage = PickedFile(compressedImage.path);
        filepath = compressedImage.path;
        uploadImage = compressedImage;
      });
    }
  }

  Future<File> _compressImage(File originalImage) async {
    final img.Image image = img.decodeImage(await originalImage.readAsBytes())!;

    // Define the maximum dimensions for the compressed image
    const int maxWidth = 800;
    const int maxHeight = 800;

    // Resize the image while maintaining aspect ratio
    img.Image resizedImage =
        img.copyResize(image, width: maxWidth, height: maxHeight);

    // Encode the resized image to JPEG format with a specified quality (adjust quality as needed)
    final List<int> compressedImageData =
        img.encodeJpg(resizedImage, quality: 80);

    // Create a new File with the compressed image data
    final File compressedFile = File(originalImage.path)
      ..writeAsBytesSync(compressedImageData);

    return compressedFile;
  }

  Future<void> subirStorage() async {
    try {
      // Show the progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      String randomFileName = generateRandomFileName();
      final storageReference =
          FirebaseStorage.instance.ref().child('images/$randomFileName.jpg');

      // Upload the image to Firebase Storage
      final UploadTask uploadTask = storageReference.putFile(uploadImage!);

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

  void agregar() async {
    bool internet = await conexionInternt();
    if (internet == false) {
      return;
    }
    subirStorage();
  }

  void cancelar() {
    regresarAnterior(context);
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
                    'Nuevo\nartículo',
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
                        Image.asset(
                          'lib/assets/images/add_image.png',
                          width: 200,
                          height: 200,
                        )
                    ],
                  ),
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Center(
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
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    width: screenWidth - 50,
                    decoration: BoxDecoration(
                      color: myColor,
                      border: Border.all(color: Colors.white, width: .2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Center(
                        child: TextField(
                          controller: _descripcionController,
                          maxLines: null, // Permite múltiples líneas
                          keyboardType: TextInputType
                              .multiline, // Activa el teclado multilinea
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Descripción',
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF503A27),
                                fontSize: 16),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: (screenHeight / 33),
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
            ),
          ),
        ),
      ),
    );
  }
}
