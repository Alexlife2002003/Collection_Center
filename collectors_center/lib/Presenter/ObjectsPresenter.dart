//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Alexia                                                                //
//   Fecha:                              29/09/23                                                           //
//   Descripción:                    Permite hacer operaciones sobre los objetos                    //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'dart:math';
import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/Objects/AgregaObjetosGeneral.dart';
import 'package:collectors_center/View/Objects/AgregarObjectsCategoria.dart';
import 'package:collectors_center/View/Objects/verObjectsCategoria.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

void goToVerObjectsCategorias(BuildContext context, String name) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
        builder: (context) => verObjectsCategoria(categoria: name)),
  );
}

void goToAgregarObjectsCategorias(BuildContext context, String name) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => agregarObjectsCategoria(categoria: name)));
}

void goToAgregarObjectsGenerales(BuildContext context) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => agregarObjectsGeneral(categoria: "")));
}

String generateRandomFileName() {
  final random = Random.secure();
  return DateTime.now().millisecondsSinceEpoch.toString() +
      random.nextInt(999999).toString();
}

void agregarObjetoCategoria(
    String url, String name, String descripcion, String categoria) async {
  bool internet = await conexionInternt();
  if (internet == false) {
    return;
  }
  if (name.trim() == "") {
    Fluttertoast.showToast(
      msg: "Ingrese un nombre",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return;
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? user = auth.currentUser;
  if (user != null) {
    String uid = user.uid;
    DocumentReference usersDoc = firestore.collection('Users').doc(uid);
    CollectionReference categoriasCollection =
        usersDoc.collection('Categories');

    // Check if the category name already exists
    QuerySnapshot categoryQuery =
        await categoriasCollection.where('Name', isEqualTo: categoria).get();

    if (categoryQuery.docs.isNotEmpty) {
      // Category name exists, so add the object to the subcollection
      DocumentReference categoryDoc = categoryQuery.docs.first.reference;
      CollectionReference categoriaSubcollection =
          categoryDoc.collection('Objects');

      // Add the object data to the subcollection
      await categoriaSubcollection.add({
        'Name': name,
        'Image_url': url,
        'Description': descripcion,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Fluttertoast.showToast(
        msg: "Articulo agregado exitosamente",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "No se pudo agregar el articulo",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } else {
    Fluttertoast.showToast(
      msg: "No estas logeado",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

Future<List<Map<String, dynamic>>> fetchAllObjects() async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    User? user = auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentReference usersDoc = firestore.collection('Users').doc(uid);
      CollectionReference categoriasCollection =
          usersDoc.collection('Categories');

      // Query all categories
      QuerySnapshot categoriesQuery = await categoriasCollection.get();

      // List to store objects from all categories
      List<Map<String, dynamic>> allObjects = [];

      for (QueryDocumentSnapshot categoryDoc in categoriesQuery.docs) {
        CollectionReference categoriaSubcollection =
            categoriasCollection.doc(categoryDoc.id).collection('Objects');

        // Query the objects in the subcollection for this category
        QuerySnapshot objectsQuery = await categoriaSubcollection.get();

        // Process the objects and add them to the list
        for (QueryDocumentSnapshot doc in objectsQuery.docs) {
          Map<String, dynamic> objectData = doc.data() as Map<String, dynamic>;
          String name = objectData['Name'];
          String imageUrl = objectData['Image_url'];
          String description = objectData['Description'];

          // Build a map representation of the object and add it to the list
          Map<String, dynamic> objectInfo = {
            'Category': categoryDoc['Name'],
            'Name': name,
            'Image URL': imageUrl,
            'Description': description,
          };
          allObjects.add(objectInfo);
        }
      }

      return allObjects; // Return the list of objects as a Future
    } else {
      // User not logged in
      throw Exception('User is not logged in.');
    }
  } catch (error) {
    print('Error fetching objects: $error');
    throw error; // Rethrow the error for higher-level handling
  }
}

Future<List<Map<String, dynamic>>> fetchObjectsByCategory(
    String categoryName) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? user = auth.currentUser;
  if (user != null) {
    String uid = user.uid;
    DocumentReference usersDoc = firestore.collection('Users').doc(uid);
    CollectionReference categoriasCollection =
        usersDoc.collection('Categories');

    // Query the category by name
    QuerySnapshot categoryQuery =
        await categoriasCollection.where('Name', isEqualTo: categoryName).get();

    if (categoryQuery.docs.isNotEmpty) {
      // Category exists, retrieve its reference
      DocumentSnapshot categoryDoc = categoryQuery.docs.first;
      CollectionReference categoriaSubcollection =
          categoriasCollection.doc(categoryDoc.id).collection('Objects');

      // Query the objects in the subcollection
      QuerySnapshot objectsQuery = await categoriaSubcollection.get();

      // Process the objects and collect them into a list of maps
      List<Map<String, dynamic>> objectList = [];
      for (QueryDocumentSnapshot doc in objectsQuery.docs) {
        Map<String, dynamic> objectData = doc.data() as Map<String, dynamic>;
        String name = objectData['Name'];
        String imageUrl = objectData['Image_url'];
        String description = objectData['Description'];

        // Create a map representation of the object and add it to the list
        Map<String, dynamic> objectInfo = {
          'Name': name,
          'Image URL': imageUrl,
          'Description': description,
        };
        objectList.add(objectInfo);
      }
      print("printing passion $objectList");
      return objectList; // Return the list of objects as a Future
    } else {
      // Category doesn't exist
      return []; // Return an empty list
    }
  } else {
    // User not logged in
    return []; // Return an empty list
  }
}
