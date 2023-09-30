//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Alexia                                                                //
//   Fecha:                              29/09/23                                                           //
//   Descripción:                    Permite ver objetos desde las categorias                     //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/Presenter/ObjectsPresenter.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class verObjectsCategoria extends StatefulWidget {
  final String categoria;

  verObjectsCategoria({required this.categoria});

  @override
  _verObjectsCategoriaState createState() => _verObjectsCategoriaState();
}

class _verObjectsCategoriaState extends State<verObjectsCategoria> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> _objectList = [];

  @override
  void initState() {
    super.initState();
    _fetchObjects();
  }

  Future<void> _fetchObjects() async {
    try {
      final List<Map<String, dynamic>> objects =
          await fetchObjectsByCategory(widget.categoria);

      setState(() {
        _objectList = objects;
      });
    } catch (error) {
      print("Error fetching objects: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AppWithDrawer(
      content: Scaffold(
        backgroundColor: peach,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: peach,
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
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
                          onPressed: () {},
                          icon: Icon(
                            Icons.delete,
                            size: 60,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth - 160,
                        ),
                        IconButton(
                          onPressed: () {
                            goToAgregarObjectsCategorias(
                                context, widget.categoria);
                          },
                          icon: Icon(
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
                            child: Text(
                              widget.categoria,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _objectList.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          for (int i = 0; i < _objectList.length; i += 2)
                            _buildObjectRow(
                                _objectList[i],
                                i + 1 < _objectList.length
                                    ? _objectList[i + 1]
                                    : null),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectRow(
      Map<String, dynamic> object1, Map<String, dynamic>? object2) {
    final String imageUrl1 = object1['Image URL'];
    final String? imageUrl2 = object2?['Image URL'];

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
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error loading image');
                          } else {
                            final imageUrl = snapshot.data.toString();
                            return Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: 188,
                              height: 188,
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
            SizedBox(
              width: 8,
            ),
          if (imageUrl2 == null)
            Container(
              color: peach,
              width: 188,
              height: 188,
            ),
          if (imageUrl2 != null) SizedBox(width: 8),
          if (imageUrl2 != null)
            Expanded(
              child: Card(
                elevation: 3,
                child: Stack(
                  children: [
                    Container(
                      color: peach,
                      child: FutureBuilder(
                        future: storage.ref().child(imageUrl2).getDownloadURL(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error loading image');
                          } else {
                            final imageUrl = snapshot.data.toString();
                            return Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: 188,
                              height: 188,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
