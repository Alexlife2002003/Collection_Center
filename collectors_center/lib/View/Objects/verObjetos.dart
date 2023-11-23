//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Equipo Tacos de asada                                                 //
//   Descripción:                     Ver los objetos                                                       //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
import 'package:collectors_center/Presenter/Categorias.dart';
import 'package:collectors_center/View/Objects/AgregarObjetos.dart';
import 'package:collectors_center/View/Objects/EditarObjetos.dart';
import 'package:collectors_center/View/recursos/Bienvenido.dart';
import 'package:collectors_center/View/recursos/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/Inicio.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:collectors_center/Presenter/Objects.dart';

String imageUrlKey = 'Image URL';

class MyObject {
  String imageUrl;
  bool isSelected;

  MyObject({
    required this.imageUrl,
    this.isSelected = false,
  });

  factory MyObject.fromMap(Map<String, dynamic> map) {
    return MyObject(
      imageUrl: map[imageUrlKey],
    );
  }
}

class verObjectsCategoria extends StatefulWidget {
  final String categoria;

  verObjectsCategoria({required this.categoria});

  @override
  _verObjectsCategoriaState createState() => _verObjectsCategoriaState();
}

class _verObjectsCategoriaState extends State<verObjectsCategoria> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<MyObject> _objectList = [];
  List<MyObject> _selectedObjects = [];
  bool deleteActivated = false;
  String selectedCategory = 'Default';
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _fetchObjects();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    List<String> fetchedCategories = [];

    try {
      fetchedCategories = await fetchCategories();
    } catch (e) {
      showSnackbar(context, "Error al buscar categorías", red);
    }

    setState(() {
      categories = fetchedCategories;
      if (categories.isNotEmpty && widget.categoria.isEmpty) {
        selectedCategory = categories[0];
        _fetchObjects();
      } else if (widget.categoria.isNotEmpty) {
        selectedCategory = widget.categoria;
        _fetchObjects();
      } else {
        selectedCategory = 'Sin categorias';
      }
    });
  }

  Future<void> _fetchObjects() async {
    try {
      final List<Map<String, dynamic>> objects =
          await fetchObjectsByCategory(selectedCategory);

      final List<MyObject> myObjects = objects.map((object) {
        return MyObject.fromMap(object);
      }).toList();

      setState(() {
        _objectList = myObjects;
      });
    } catch (error) {
      showSnackbar(context, "Error al obtener categorías", red);
    }
  }

  void _toggleSelection(MyObject myObject) {
    setState(() {
      myObject.isSelected = !myObject.isSelected;
      if (myObject.isSelected) {
        _selectedObjects.add(myObject);
      } else {
        _selectedObjects.remove(myObject);
      }
    });
  }

  void _deleteConfirmation() async {
    bool confirmacion = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: peach,
          title: const Text('Confirmar eliminación'),
          content: const Text(
              '¿Está seguro de que desea borrar los artículos seleccionados?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                setState(() {
                  deleteActivated = !deleteActivated;
                });
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
      _deleteSelectedObjects();
    }
  }

  void _deleteSelectedObjects() async {
    try {
      for (MyObject selectedObject in _selectedObjects) {
        if (_selectedObjects.isNotEmpty) {
          eliminarVariosObjetos(
              context, selectedObject.imageUrl, widget.categoria);
        }
      }
      showSnackbar(context, "Los artículos han sido eliminados", green);
      Navigator.pop(context);
    } catch (e) {
      showSnackbar(context, "Los artículos no han sido eliminados", red);
      Navigator.pop(context);
    }
    setState(() {
      _objectList.removeWhere((object) => object.isSelected);
      _selectedObjects.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Inicio();
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
        currentPage: "Objetos",
        content: Scaffold(
          backgroundColor: peach,
          body: Column(
            children: <Widget>[
              Container(
                color: peach,
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Artículos',
                      style: TextStyle(
                        fontSize: 42,
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (deleteActivated) {
                              setState(() {
                                deleteActivated = !deleteActivated;
                              });
                              if (_selectedObjects.isNotEmpty) {
                                _deleteConfirmation();
                              }
                            } else {
                              if (_objectList.isNotEmpty) {
                                setState(() {
                                  deleteActivated = !deleteActivated;
                                });
                              }
                            }
                          },
                          icon: Icon(
                            deleteActivated
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) =>
                                        agregarObjectsCategoria(
                                            categoria: selectedCategory))));
                          },
                          icon: const Icon(
                            Icons.add_circle_outline,
                            size: 60,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: screenWidth - 150,
                            height: 50,
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: myColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCategory = newValue!;
                                    _fetchObjects();
                                  });
                                },
                                items: categories.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }).toList(),
                                dropdownColor: myColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Object listing
              Expanded(
                child: ListView(
                  children: <Widget>[
                    if (_objectList.isEmpty)
                      Center(
                        child: Container(
                          color: peach,
                        ),
                      )
                    else
                      Column(
                        children: <Widget>[
                          for (int i = 0; i < _objectList.length; i += 2)
                            _buildObjectRow(
                                _objectList[i],
                                i + 1 < _objectList.length
                                    ? _objectList[i + 1]
                                    : null),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectRow(MyObject object1, MyObject? object2) {
    final String imageUrl1 = object1.imageUrl;
    final String? imageUrl2 = object2?.imageUrl;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              color: peach,
              child: Card(
                elevation: 3,
                child: Stack(
                  children: [
                    Container(
                      color: peach,
                      child: FutureBuilder(
                        future: storage.ref().child(imageUrl1).getDownloadURL(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(
                              color: peach,
                            );
                          } else if (snapshot.hasError) {
                            return const Text('Error loading image');
                          } else {
                            final imageUrl = snapshot.data.toString();
                            return GestureDetector(
                              onTap: () {
                                if (deleteActivated) {
                                  _toggleSelection(object1);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditarObjetos(
                                              url: imageUrl,
                                              firebaseURL: imageUrl1,
                                            )),
                                  );
                                }
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 2,
                                          offset: Offset(2, 2))
                                    ]),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      width: 188,
                                      height: 188,
                                    ),
                                  ),
                                  if (object1.isSelected)
                                    const Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 24,
                                      ),
                                    ),
                                ],
                              ),
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
          if (imageUrl2 == null)
            const SizedBox(
              width: 8,
            ),
          if (imageUrl2 == null)
            Container(
              color: peach,
              width: 188,
              height: 188,
            ),
          if (imageUrl2 != null) const SizedBox(width: 8),
          if (imageUrl2 != null)
            Expanded(
              child: Container(
                color: peach,
                child: Card(
                  elevation: 3,
                  child: Stack(
                    children: [
                      Container(
                        color: peach,
                        child: FutureBuilder(
                          future:
                              storage.ref().child(imageUrl2).getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator(
                                color: peach,
                              );
                            } else if (snapshot.hasError) {
                              return const Text('Error loading image');
                            } else {
                              final imageUrl = snapshot.data.toString();
                              return GestureDetector(
                                onTap: () {
                                  if (deleteActivated) {
                                    _toggleSelection(object2!);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditarObjetos(
                                                url: imageUrl,
                                                firebaseURL: imageUrl2,
                                              )),
                                    );
                                  }
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey,
                                                blurRadius: 2,
                                                offset: Offset(2, 2))
                                          ]),
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        width: 188,
                                        height: 188,
                                      ),
                                    ),
                                    if (object2!.isSelected)
                                      const Align(
                                        alignment: Alignment.topRight,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 24,
                                        ),
                                      ),
                                  ],
                                ),
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
        ],
      ),
    );
  }
}
