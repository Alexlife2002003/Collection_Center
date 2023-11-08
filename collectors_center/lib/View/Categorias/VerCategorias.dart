//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Equipo Tacos de asada                                                 //
//   Descripción:                     Ver categorias                                        //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/Presenter/Categorias.dart';
import 'package:collectors_center/Presenter/Cuentas.dart';
import 'package:collectors_center/Presenter/Objects.dart';
import 'package:collectors_center/View/recursos/Bienvenido.dart';
import 'package:collectors_center/View/recursos/Inicio.dart';
import 'package:flutter/material.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class verCategorias extends StatefulWidget {
  const verCategorias({Key? key}) : super(key: key);

  @override
  _verCategoriasState createState() => _verCategoriasState();
}

class _verCategoriasState extends State<verCategorias> {
  bool isEdit = false;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    conexionInternt();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final loadedCategories = await fetchCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If the user is not authenticated, redirect them to the login screen
      return const Inicio();
    }

    void borrar(String categoria) async {
      // Mostrar un diálogo de confirmación
      bool confirmacion = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: peach,
            title: const Text('Confirmar eliminación'),
            content: Text(
                '¿Está seguro de que desea borrar la categoría "$categoria"?'),
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
        await borrarCategorias(context, categoria.trim());
        loadCategories();
      }
    }

    return WillPopScope(
      onWillPop: () async {
         Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Bienvenido()),
  );
        return true;
      },
      child: AppWithDrawer(
        currentPage: "Categorias",
        content: Scaffold(
          backgroundColor: peach,
          body: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Categorías',
                    style: TextStyle(
                      fontSize: 42,
                      color: brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Icons and Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (categories.isNotEmpty) {
                              isEdit = !isEdit;
                            } else {
                              mostrarToast("No existen categorías");
                            }
                          });
                        },
                        icon: Icon(
                          isEdit && categories.isNotEmpty
                              ? Icons.check_circle_outlined
                              : Icons.delete,
                          size: 60,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth - 160,
                      ),
                      IconButton(
                        onPressed: () {
                          agregarCategoria(context);
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          size: 60,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  // List of Categories
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return GestureDetector(
                          onTap: () {
                            if (isEdit) {
                              borrar(category);
                              setState(() {
                                isEdit = false;
                              });
                            } else {
                              goToVerObjectsCategorias(
                                context,
                                category,
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 2,
                                    offset: Offset(2, 2))
                              ],
                              color: myColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                ListTile(
                                  title: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      if (isEdit) {
                                        // Handle delete action
                                        borrar(category);
                                      } else {
                                        // Handle edit action
                                        goToEditarCategoria(context, category);
                                      }
                                    },
                                    child: Icon(
                                      isEdit ? Icons.delete : Icons.edit,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
