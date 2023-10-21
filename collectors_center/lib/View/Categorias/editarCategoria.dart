//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Equipo Tacos de asada                                                 //
//   Descripción:                     Editar categorias                                      //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/View/AntesDeIngresar/Inicio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collectors_center/Presenter/CategoriasPresenter.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditarCategoria extends StatefulWidget {
  final String categoryName;
  const EditarCategoria({Key? key, required this.categoryName})
      : super(key: key);

  @override
  State<EditarCategoria> createState() => _EditarCategoriaState();
}

class _EditarCategoriaState extends State<EditarCategoria> {
  final _nombreCategoriaController = TextEditingController();
  final _descripcionCategoriaController = TextEditingController();
  bool isEditing = false;
  String description = "";

  @override
  void initState() {
    super.initState();
    _nombreCategoriaController.text = widget.categoryName;
    fetchDescription();
  }

  Future<void> fetchDescription() async {
    final String categoryDescription =
        await fetchDescriptions(widget.categoryName);
    setState(() {
      description = categoryDescription;
      _descripcionCategoriaController.text = categoryDescription;
    });
  }

  void cancelar() {
    Navigator.pop(context);
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
                    height: 50,
                    decoration: BoxDecoration(
                      color: myColor,
                      border: Border.all(color: Colors.white, width: .2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: isEditing
                          ? TextField(
                              controller: _nombreCategoriaController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Nombre',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xfff503a27),
                                  fontSize: 20,
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 20),
                              ),
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              _nombreCategoriaController.text,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xfff503a27),
                                fontSize: 20,
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
                  child: Container(
                    width: screenWidth - 50,
                    decoration: BoxDecoration(
                      color: myColor,
                      border: Border.all(color: Colors.white, width: .2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: isEditing
                                ? TextField(
                                    maxLines: null,
                                    controller: _descripcionCategoriaController,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Descripción',
                                      hintStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFF503A27),
                                        fontSize: 16,
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : Text(
                                    _descripcionCategoriaController.text,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF503A27),
                                      fontSize: 16,
                                    ),
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
                                  setState(() {});
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight / 3.6,
                ),
                Center(
                  child: SizedBox(
                    width: screenWidth - 200,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                      onPressed: () {},
                      child: Text('Guardar'),
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: screenWidth - 200,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      onPressed: cancelar,
                      child: Text('Cancelar'),
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
