//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Equipo Tacos de asada                                                 //
//   Descripción:                     Editar los objetos                                       //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
import 'dart:io';
import 'package:collectors_center/Presenter/Objects.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/Inicio.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:collectors_center/View/recursos/utils.dart';
import 'package:collectors_center/View/recursos/validaciones.dart';
import 'package:flutter/material.dart';
import 'package:collectors_center/View/Objects/verObjetos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  String filepath = "";
  File? uploadImage;
  Map<String, String> imageInfo = {};
  String name = "";
  String descripcion = "";
  String category = "";
  PickedFile? _selectedImage;

  final _descripcionController = TextEditingController();

  bool isEditing = false;

  void cancelar() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => verObjectsCategoria(categoria: category)),
    );
  }

  void borrarObjeto() async {
    // Mostrar un diálogo de confirmación
    bool confirmacion = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: peach,
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Está seguro de que desea eliminar el artículo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Eliminar',
                style: TextStyle(color: red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmacion == true) {
      showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              color: peach,
            ),
          );
        },
      );
      eliminarObjeto(context, widget.firebaseURL, category);
    }
  }

  void editDescription() async {
    bool internet = await conexionInternt(context);
    if (internet == false) {
      return;
    }
    descripcion = _descripcionController.text;
    final containsLetter = RegExp(r'[a-zA-Z]').hasMatch(descripcion);
    if (descripcion.length < 10 && descripcion.length != 0) {
      showSnackbar(context,
          "Descripción debe contener mínimo 10 caracteres si no es vacia", red);
      return;
    }

    if (descripcion.length > 300) {
      showSnackbar(
          context, "No puede exceder la descripción los 300 caracteres", red);
      return;
    }

    if (!containsLetter && descripcion.isNotEmpty) {
      showSnackbar(context, "Descripción debe contener letras", red);
      return;
    }
    if (descripcion.trim() == category) {
      showSnackbar(context,
          "La descripción no puede ser igual al nombre de la categoría", red);
      return;
    }
    if (descripcion.trim() == name) {
      showSnackbar(context,
          "La descripción no puede ser igual al nombre del artículo", red);
      return;
    }
    if (isEditing) {
      editarDescripcion(
          context, widget.firebaseURL, _descripcionController.text);
    }
    isEditing = !isEditing;
  }

  void borrarDescripcion() async {
    if (_descripcionController.text.isEmpty) {
      showSnackbar(context, "La descripción se encuentra vacía", red);
      return;
    }
    bool internet = await conexionInternt(context);
    if (internet == false) {
      return;
    }
    // Mostrar un diálogo de confirmación
    bool confirmacion = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: peach,
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Está seguro de que desea eliminar la descripción?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Eliminar',
                style: TextStyle(color: red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmacion == true) {
      setState(() {
        descripcion = "";
        isEditing = false;
        _descripcionController.text = "";
        eliminarDescripcion(context, widget.firebaseURL, "");
      });
    }
  }

  void agregar() async {
    bool internet = await conexionInternt(context);
    if (internet == false) {
      return;
    }
    if (!isEditing) {
      await _pickImage();
    }
    if (_selectedImage != null) {
      await subirStorage();
      deleteImageByImageUrlNoMessage(context, widget.firebaseURL);
    }
  }

  void setImageInfo() async {
    imageInfo = await obtenerObjeto(context, widget.firebaseURL);

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
        agregarObjeto(
            context,
            'images/$randomFileName.jpg',
            name,
            descripcion,
            category,
            "Imagen modificada correctamente",
            "No se pudo modificar la imagen");

        // Close the progress dialog
        Navigator.of(context).pop();
      });
    } catch (e) {
      showSnackbar(context, "Error al subir la imagen", red);

      Navigator.of(context).pop();
    }
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

    return WillPopScope(
      onWillPop: () async {
        cancelar();
        return true;
      },
      child: AppWithDrawer(
        currentPage: "editarObjetos",
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
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              agregar();
                            });
                          },
                          child: Stack(
                            children: [
                              if (_selectedImage != null)
                                Image.file(
                                  File(_selectedImage!.path),
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              else
                                CachedNetworkImage(
                                  imageUrl: widget.url,
                                  width: 200,
                                  height: 200,
                                ),
                              Container(
                                width: 200,
                                height: 200,
                                // Adjust the opacity as needed
                                color: Colors.grey.withOpacity(
                                    0.4), 
                              ),
                              const Positioned(
                                top: 50,
                                right: 50,
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 100,
                                ),
                              ),
                            ],
                          ),
                        )
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
                              border:
                                  Border.all(color: Colors.white, width: .2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: isEditing
                                        ? TextFormField(
                                            keyboardType:
                                                TextInputType.multiline,
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
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isEditing ? Icons.check : Icons.edit,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            editDescription();
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            borrarDescripcion();
                                          });
                                        },
                                      ),
                                    ],
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
                    child: SizedBox(
                      width: screenWidth - 200,
                      child: ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                        ),
                        onPressed: () {
                          borrarObjeto();
                        },
                        child: const Text('Eliminar'),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: screenWidth - 200,
                      child: ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.blue),
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
      ),
    );
  }
}
