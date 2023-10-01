import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectors_center/Presenter/ObjectsPresenter.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'dart:io';

const double iconSize = 60;
const String imageUrlKey = 'Image URL';

class verObjetosGenerales extends StatefulWidget {
  const verObjetosGenerales({Key? key}) : super(key: key);

  @override
  _verObjetosGeneralesState createState() => _verObjetosGeneralesState();
}

class _verObjetosGeneralesState extends State<verObjetosGenerales> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> _objectList = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchObjects();
  }

  Future<void> _fetchObjects() async {
    try {
      final List<Map<String, dynamic>> objects = await fetchAllObjects();

      setState(() {
        _objectList = objects;
        _isLoading = false;
        _error = '';
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = 'Error fetching objects: $error';
      });
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
                            size: iconSize,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth - 160,
                        ),
                        IconButton(
                          onPressed: () {
                            goToAgregarObjectsGenerales(context);
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            size: iconSize,
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
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _error.isNotEmpty
                      ? Center(
                          child: Text(_error),
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
    final String? imageUrl1 = object1[imageUrlKey];
    final String? imageUrl2 = object2?[imageUrlKey];

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
                        future: imageUrl1 != null
                            ? storage.ref().child(imageUrl1).getDownloadURL()
                            : null,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error loading image');
                          } else if (!snapshot.hasData) {
                            return Text('No image available');
                          } else {
                            final imageUrl = snapshot.data.toString();
                            return CachedNetworkImage(
                              imageUrl: imageUrl,
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
                        future: imageUrl2 != null
                            ? storage.ref().child(imageUrl2).getDownloadURL()
                            : null,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error loading image');
                          } else if (!snapshot.hasData) {
                            return Text('No image available');
                          } else {
                            final imageUrl = snapshot.data.toString();
                            return CachedNetworkImage(
                              imageUrl: imageUrl,
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
