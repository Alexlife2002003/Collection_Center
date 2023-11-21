//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Tacos de Asada                                                        //
//   Fecha:                           16/11/23                                                              //
//   Descripción:                     View de las colecciones de los amigos                                 //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
import 'package:collectors_center/Presenter/Amigos.dart';
import 'package:collectors_center/View/Amigos/verAmigos.dart';
import 'package:collectors_center/View/Amigos/verObjetosAmigos.dart';
import 'package:collectors_center/View/recursos/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/Inicio.dart';
import 'package:collectors_center/View/recursos/colors.dart';

String imageUrlKey = 'Image URL';
String nameKey = 'Name';
String descriptionKey = 'Description';

class MyObject {
  String imageUrl;
  String name;
  String description;
  MyObject(
      {required this.imageUrl, required this.name, required this.description});

  factory MyObject.fromMap(Map<String, dynamic> map) {
    return MyObject(
        imageUrl: map[imageUrlKey],
        name: map[nameKey],
        description: map[descriptionKey]);
  }
}

class verColeccionesAmigos extends StatefulWidget {
  final String amigo;

  verColeccionesAmigos({required this.amigo});

  @override
  _verColeccionesAmigosState createState() => _verColeccionesAmigosState();
}

class _verColeccionesAmigosState extends State<verColeccionesAmigos> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<MyObject> _objectList = [];

  String selectedCategory = 'Default';
  List<String> categories = [];

  @override
  void initState() {
    super.initState();

    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    categories = await obtenerCategoriasAmigos(widget.amigo);
    setState(() {
      if (categories.isNotEmpty) {
        selectedCategory = categories[0];
        _fetchObjects();
      } else {
        selectedCategory = 'Sin categorias';
      }
    });
  }

  Future<void> _fetchObjects() async {
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
    try {
      final List<Map<String, dynamic>> objects =
          await obtenerObjetosCategoriasAmigos(widget.amigo, selectedCategory);

      final List<MyObject> myObjects = objects.map((object) {
        return MyObject.fromMap(object);
      }).toList();

      setState(() {
        _objectList = myObjects;
      });
      Navigator.pop(context);
    } catch (error) {
      showSnackbar(context, "Error al obtener categorías", red);
    }
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
          MaterialPageRoute(builder: (context) => const VerAmigos()),
        );
        return true;
      },
      child: AppWithDrawer(
        currentPage: "verColeccionesAmigos",
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
                    Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: amigosBrown,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 20),
                          Icon(
                            Icons.person,
                            size: 50,
                            color: peach,
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                widget.amigo,
                                style: TextStyle(
                                  color: peach,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                "\nColecciones",
                                style: TextStyle(color: peach),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ],
                      ),
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            verObjetosIndividuales(
                                              url: imageUrl,
                                              name: object1.name,
                                              category: selectedCategory,
                                              description: object1.description,
                                            )));
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
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              verObjetosIndividuales(
                                                url: imageUrl,
                                                name: object2!.name,
                                                category: selectedCategory,
                                                description:
                                                    object2.description,
                                              )));
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
