import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/Categorias/VerCategorias.dart';
import 'package:collectors_center/View/Categorias/agregarCategorias.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

//////////////////////////////////
//  Navegacion dentro de la app encargado de categorias //
//////////////////////////////////
///

//Se encarga de borrar categorías
Future<void> borrarCategorias(BuildContext context, String categoria) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    final storageRef = FirebaseStorage.instance.ref();
    if (user != null) {
      // Reference to the user's "Categories" subcollection
      CollectionReference categoriesCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Categories');

      // Query for the document with a specific "Name" field value
      QuerySnapshot querySnapshot =
          await categoriesCollection.where('Name', isEqualTo: categoria).get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first matching category document
        final categoryDoc = querySnapshot.docs.first;

        // Reference to the "Objects" subcollection within the category document
        CollectionReference objectsCollection =
            categoryDoc.reference.collection('Objects');

        // Query all documents within the "Objects" subcollection
        QuerySnapshot objectsQuerySnapshot = await objectsCollection.get();

        // Delete each document and associated image
        for (final objectDoc in objectsQuerySnapshot.docs) {
          try {
            final imageUrl = objectDoc['Image_url'];
            final categRef = storageRef.child(imageUrl);
            await categRef.delete();
          } catch (e) {
            Fluttertoast.showToast(
              msg: "La categoría no se ha eliminado",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }

          // Delete the object document
          await objectDoc.reference.delete();
        }

        // Delete the category document after deleting associated objects
        await categoryDoc.reference.delete();

        Fluttertoast.showToast(
          msg: "La categoría ha sido eliminada correctamente",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        // Handle the case where no matching document was found
        Fluttertoast.showToast(
          msg: "La categoría no se ha eliminado",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "La categoría no se ha eliminado",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

// Te lleva a la pantalla de mostrar las categorías
void goToVerCategorias(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const verCategorias()),
  );
}

// Te lleva a la pantalla de agregar Categorias
void agregarCategoria(BuildContext context) {
  Navigator.push(context,
      MaterialPageRoute(builder: (context) => const agregarCategorias()));
}

//Permite agregar categorías
void agregarCategoriaBase(BuildContext context, String categoria) async {
  bool internet = await conexionInternt();
  if (internet == false) {
    return;
  }
  if (categoria.trim() == "") {
    Fluttertoast.showToast(
      msg: "Ingrese un nombre",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return;
  }
  if (categoria.length > 20) {
    mostrarToast("El nombre debe ser de máximo 20 carácteres");
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

    if (categoryQuery.docs.isEmpty) {
      // Category name does not exist, so add it
      categoriasCollection.add({
        'Name': categoria,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Fluttertoast.showToast(
        msg: "Categoría agregada exitosamente",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      goToVerCategorias(context);
    } else {
      Fluttertoast.showToast(
        msg: "La categoria ya existe",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
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
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

// Te permite obtener las categorías
Future<List<String>> fetchCategories() async {
  List<String> categories = [];

  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid) // Assuming you have access to the user object
          .collection('Categories')
          .orderBy('timestamp', descending: false)
          .get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        String categoryName = document['Name'] as String;
        categories.add(categoryName);
      }
    }
  } catch (e) {
    print('Error fetching categories: $e');
  }

  return categories;
}

// Te permite obtener la información de la imágen en base a la Url de la imágen
Future<Map<String, String>> getImageInfoByImageUrl(
    BuildContext context, String imageUrl) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Reference to the user's "Categories" subcollection
      CollectionReference categoriesCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Categories');

      // Query all category documents
      QuerySnapshot categoriesQuerySnapshot = await categoriesCollection.get();

      // Loop through the category documents
      for (final categoryDoc in categoriesQuerySnapshot.docs) {
        // Reference to the "Objects" subcollection within the category document
        CollectionReference objectsCollection =
            categoryDoc.reference.collection('Objects');

        // Query all documents within the "Objects" subcollection
        QuerySnapshot objectsQuerySnapshot = await objectsCollection.get();

        // Loop through the objects in the category
        for (final objectDoc in objectsQuerySnapshot.docs) {
          // Check if the image URL matches the desired URL
          if (objectDoc['Image_url'] == imageUrl) {
            // Extract image information (Name and Description)
            final imageName = objectDoc['Name'];
            final imageDescription = objectDoc['Description'];

            // Return the image information as a Map
            return {
              'imageName': imageName,
              'imageDescription': imageDescription,
            };
          }
        }
      }
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Error al buscar la imagen",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Return an empty Map if no matching image URL was found or there's an error
  return {
    'imageName': '',
    'imageDescription': '',
  };
}
