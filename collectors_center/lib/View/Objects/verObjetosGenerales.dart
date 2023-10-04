import 'package:collectors_center/Presenter/ObjectsPresenter.dart';
import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

class verObjetosGenerales extends StatefulWidget {
  const verObjetosGenerales({Key? key}) : super(key: key);

  @override
  _verObjetosGeneralesState createState() => _verObjetosGeneralesState();
}

class _verObjetosGeneralesState extends State<verObjetosGenerales> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<MyObject> _objectList = [];
  List<MyObject> _selectedObjects = [];
  bool deleteActivated = false;

  @override
  void initState() {
    super.initState();
    _fetchObjects();
  }

  Future<void> _fetchObjects() async {
    try {
      final List<Map<String, dynamic>> objects = await fetchAllObjects();

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

  void _deleteSelectedObjects() {
    try {
      for (MyObject selectedObject in _selectedObjects) {
        deleteByGeneralNoMessage(context, selectedObject.imageUrl);
      }
      Fluttertoast.showToast(
        msg: "Los artículos han sido eliminados",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Los artículos no han sido eliminados",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    setState(() {
      _objectList.removeWhere((object) => object.isSelected);

      _selectedObjects.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        goToBienvenido(context);
        return true;
      },
      child: AppWithDrawer(
        content: Scaffold(
          backgroundColor: peach,
          body: SingleChildScrollView(
            child: Column(
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

                                _deleteSelectedObjects();
                              } else {
                                setState(() {
                                  deleteActivated = !deleteActivated;
                                });
                              }
                            },
                            icon: Icon(
                              deleteActivated ? Icons.check : Icons.delete,
                              size: 60,
                            ),
                          ),
                          SizedBox(
                            width: screenWidth - 160,
                          ),
                          IconButton(
                            onPressed: () {
                              goToAgregarObjectsGenerales(context);
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
                    ],
                  ),
                ),
                _objectList.isEmpty
                    ? Center(
                        child: Container(
                          color: peach,
                        ),
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
                                if (deleteActivated) {
                                  _toggleSelection(object1);
                                } else {
                                  goToEditarObjetoGeneral(
                                      context, imageUrl, imageUrl1);
                                }
                              },
                              child: Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    width: 188,
                                    height: 188,
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
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text('Error loading image');
                            } else {
                              final imageUrl = snapshot.data.toString();
                              return GestureDetector(
                                onTap: () {
                                  if (deleteActivated) {
                                    _toggleSelection(object2!);
                                  } else {
                                    goToEditarObjetoGeneral(
                                        context, imageUrl, imageUrl1);
                                  }
                                },
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      width: 188,
                                      height: 188,
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
