import 'package:flutter/material.dart';
import 'package:collectors_center/Presenter/CategoriasPresenter.dart';
import 'package:collectors_center/Presenter/ObjectsPresenter.dart';
import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';

class verCategorias extends StatefulWidget {
  const verCategorias({Key? key}) : super(key: key);

  @override
  _verCategoriasState createState() => _verCategoriasState();
}

class _verCategoriasState extends State<verCategorias> {
  Future<List<String>> ver() async {
    return fetchCategories();
  }

<<<<<<< HEAD
  bool isEdit = false;
=======
  bool isEdit = false; 
>>>>>>> d35d0eb88202c6cb8d24811870d9d89203b10366

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

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
<<<<<<< HEAD

=======
    
>>>>>>> d35d0eb88202c6cb8d24811870d9d89203b10366
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
<<<<<<< HEAD

                  const SizedBox(height: 20),

=======
    
                  const SizedBox(height: 20),
    
>>>>>>> d35d0eb88202c6cb8d24811870d9d89203b10366
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
<<<<<<< HEAD

=======
    
>>>>>>> d35d0eb88202c6cb8d24811870d9d89203b10366
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
<<<<<<< HEAD
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
=======
                                      // Add your icon here
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Icon(
                                          isEdit ? Icons.delete : null,
                                          // isEdit ? Icons.delete : Icons.edit_note,
                                          color: Colors.black,
                                          size: 40,
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          category,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
>>>>>>> d35d0eb88202c6cb8d24811870d9d89203b10366
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
