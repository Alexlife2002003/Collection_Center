//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Equipo Tacos de asada                                                 //
//   Descripción:                     Ver objetos de forma general                                         //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/Presenter/Categorias.dart';
import 'package:collectors_center/Presenter/Objects.dart';
import 'package:collectors_center/View/Objects/verObjetosIndividuales.dart';
import 'package:collectors_center/View/recursos/Bienvenido.dart';
import 'package:collectors_center/View/recursos/Inicio.dart';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';

String imageUrlKey = 'Image URL';

class MyObject {
  String imageUrl;

  MyObject({
    required this.imageUrl,
  });

  factory MyObject.fromMap(Map<String, dynamic> map) {
    return MyObject(
      imageUrl: map[imageUrlKey],
    );
  }
}

class verObjetosGenerales extends StatefulWidget {
  const verObjetosGenerales({Key? key}) : super(key: key);

  @override
  _verObjetosGeneralesState createState() => _verObjetosGeneralesState();
}

class _verObjetosGeneralesState extends State<verObjetosGenerales> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<MyObject> _objectList = [];
  List<String> categories = [];
  String selectedCategory = 'Default';
  String selectedDescription = "";

  Future<void> fetchdescr() async {
    selectedDescription = await fetchDescriptions(selectedCategory);
  }

  Future<void> fetchCategories() async {
    List<String> fetchedCategories = [];

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Categories')
            .orderBy('timestamp', descending: false)
            .get();

        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          String categoryName = document['Name'] as String;
          fetchedCategories.add(categoryName);
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }

    setState(() {
      categories = fetchedCategories;
      if (categories.isNotEmpty) {
        selectedCategory = categories[0];
        fetchdescr();
        _fetchObjectscat();
      } else {
        selectedCategory = 'Sin categorias';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _fetchObjectscat();
    fetchdescr();
  }

  Future<void> _fetchObjectscat() async {
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
      print("Error fetching objects: $error");
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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Bienvenido(),
          ),
          (route) => false,
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
                child: SingleChildScrollView(
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
                      Container(
                        width: screenWidth - 30,
                        height: 60,
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
                                _fetchObjectscat();
                                fetchdescr();
                              });
                            },
                            items: categories
                                .map<DropdownMenuItem<String>>((String value) {
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
                    ],
                  ),
                ),
              ),
              if (selectedDescription.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: screenWidth - 50,
                          decoration: BoxDecoration(
                            color: myColor,
                            border: Border.all(color: Colors.white, width: .2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              selectedDescription,
                              style: TextStyle(color: brown, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text('Error loading image');
                          } else {
                            final imageUrl = snapshot.data.toString();
                            return GestureDetector(
                              onTap: () {
                                    Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => verObjetosIndividuales(
              url: imageUrl,
              firebaseURL: imageUrl1,
            )),
  );
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
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text('Error loading image');
                            } else {
                              final imageUrl = snapshot.data.toString();
                              return GestureDetector(
                                onTap: () {
                                

                                      Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => verObjetosIndividuales(
              url: imageUrl,
              firebaseURL: imageUrl2,
            )),
  );
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
