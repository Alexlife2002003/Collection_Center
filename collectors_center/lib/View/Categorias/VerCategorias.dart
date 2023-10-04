import 'package:collectors_center/View/AntesDeIngresar/Inicio.dart';
import 'package:flutter/material.dart';
import 'package:collectors_center/Presenter/CategoriasPresenter.dart';
import 'package:collectors_center/Presenter/ObjectsPresenter.dart';
import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class verCategorias extends StatefulWidget {
  const verCategorias({Key? key}) : super(key: key);

  @override
  _verCategoriasState createState() => _verCategoriasState();
}

class _verCategoriasState extends State<verCategorias> {
  Future<List<String>> ver() async {
    return fetchCategories();
  }

  bool isEdit = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Si el usuario no está autenticado, redirigirlo a la pantalla de inicio de sesión
      return Inicio();
    }
    
    void borrar(String categoria) {
      borrarCategorias(context, categoria.trim());
    }

    return WillPopScope(
      onWillPop: () async {
        goToBienvenido(context);
        return true;
      },
      child: AppWithDrawer(
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
                            isEdit = !isEdit; // Toggle edit mode
                          });
                        },
                        icon: Icon(
                          isEdit ? Icons.check_circle_outlined : Icons.delete,
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
                    child: FutureBuilder<List<String>>(
                      future: ver(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else {
                          List<String> categories = snapshot.data ?? [];

                          return ListView.builder(
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return GestureDetector(
                                onTap: () {
                                  if (isEdit) {
                                    borrar(categories[index].toString());
                                    setState(() {
                                      isEdit = !isEdit;
                                    });
                                  } else {
                                    goToVerObjectsCategorias(
                                        context, categories[index].toString());
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: myColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Stack(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          category,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            isEdit ? Icons.delete : null,
                                            color: Colors.black,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
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
