import 'package:collectors_center/Presenter/CategoriasPresenter.dart';
import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/AntesDeIngresar/Inicio.dart';
import 'package:collectors_center/View/Categorias/VerCategorias.dart';
import 'package:collectors_center/View/Objects/verObjectsCategoria.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditarCategoria extends StatefulWidget {
  String categoryName;
  EditarCategoria({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<EditarCategoria> createState() => _EditarCategoriaState();
}

@override
void dispose() {}

class _EditarCategoriaState extends State<EditarCategoria> {
  final _descripcionCategoriaController = TextEditingController();
  final _nombreCategoriaController = TextEditingController();
  bool isEditing = false;
  bool isEditingNombre = false;
  String nombre = "";
  String description = "";

  void cancelar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const verCategorias()),
    );
  }

  void borrar() async {
    // Show a confirmation dialog
    bool confirmation = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: peach,
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Está seguro de que desea eliminar la categoría?'),
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
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      //deleteCategory(context, widget.categoryName);
    }
  }

  void editDescription() async {
    bool internet = await conexionInternt();
    if (internet == false) {
      return;
    }
    description = _descripcionCategoriaController.text;
    final containsLetter = RegExp(r'[a-zA-Z]').hasMatch(description);

    if (description.length < 15 && description.isNotEmpty) {
      mostrarToast(
          "La descripción debe tener al menos 15 caracteres si no está vacía");
      return;
    }

    if (description.length > 300) {
      mostrarToast("La descripción no puede exceder los 300 caracteres");
      return;
    }

    if (!containsLetter && description.isNotEmpty) {
      mostrarToast("La descripción debe contener letras");
      return;
    }
    if (description == widget.categoryName) {
      mostrarToast(
          "La descripción no puede ser igual al nombre de la categoría");
      return;
    }

    if (isEditing) {
      editCategoryDescription(
          widget.categoryName, _descripcionCategoriaController.text);
    }
    isEditing = !isEditing;
  }

  void editNombre() async {
    bool internet = await conexionInternt();
    if (internet == false) {
      return;
    }
    nombre = _nombreCategoriaController.text.trim();
    if ((nombre != widget.categoryName) && (await categoriesExist(nombre))) {
      mostrarToast("El nombre de la categoría ya existe");
      return;
    }
    if (nombre.isEmpty) {
      mostrarToast("Ingrese un nombre");
      return;
    }
    final containsLetter = RegExp(r'[a-zA-Z]').hasMatch(nombre);

    if (isEditingNombre) {
      editCategoryName(widget.categoryName, _nombreCategoriaController.text);
      setState(() {
        widget.categoryName = _nombreCategoriaController.text;
      });
    }
    isEditingNombre = !isEditingNombre;
  }

  void borrarDescripcion() async {
    bool internet = await conexionInternt();
    if (internet == false) {
      return;
    }
    description = "";
    isEditing = false;
    _descripcionCategoriaController.text = "";
    clearCategoryDescription(widget.categoryName);
  }

  @override
  void initState() {
    super.initState();
    fetchDescription();
  }

  Future<void> fetchDescription() async {
    final String categoryDescription =
        await fetchDescriptions(widget.categoryName);
    setState(() {
      _nombreCategoriaController.text = widget.categoryName;
      nombre = widget.categoryName;
      description = categoryDescription;
      _descripcionCategoriaController.text = categoryDescription;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If the user is not authenticated, redirect them to the login screen
      return const Inicio();
    }
    return WillPopScope(
      onWillPop: () async {
        goToVerCategorias(context);
        return true;
      },
      child: AppWithDrawer(
        currentPage: "editarCategorias",
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
                      'Editar\nCategoría',
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
                  const SizedBox(height: 25),
                  Text(
                    "       Nombre:",
                    style: TextStyle(color: brown, fontSize: 22),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      width: screenWidth - 50,
                      height: 70,
                      decoration: BoxDecoration(
                        color: myColor,
                        border: Border.all(color: Colors.white, width: .2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Expanded(
                                child: isEditingNombre
                                    ? TextFormField(
                                        keyboardType: TextInputType.text,
                                        maxLength: 20,
                                        controller: _nombreCategoriaController,
                                        style: TextStyle(
                                            color: brown, fontSize: 16),
                                        textAlign: TextAlign.center,
                                      )
                                    : Text(
                                        widget.categoryName,
                                        style: TextStyle(
                                          color: brown,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isEditingNombre
                                            ? Icons.check
                                            : Icons.edit,
                                        color: Colors.green,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          editNombre();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
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
                                            controller:
                                                _descripcionCategoriaController,
                                            style: TextStyle(
                                                color: brown, fontSize: 16),
                                            textAlign: TextAlign.center,
                                          )
                                        : Text(
                                            description,
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
                          borrar();
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
