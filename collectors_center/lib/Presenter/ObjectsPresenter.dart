//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Alexia                                                                //
//   Fecha:                              29/09/23                                                           //
//   Descripción:                    Permite hacer operaciones sobre los objetos                    //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'dart:math';
import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/Objects/AgregaObjetosGeneral.dart';
import 'package:collectors_center/View/Objects/AgregarObjectsCategoria.dart';
import 'package:collectors_center/View/Objects/EditarObjetos.dart';
import 'package:collectors_center/View/Objects/EditarObjetosGenerales.dart';
import 'package:collectors_center/View/Objects/verObjectsCategoria.dart';
import 'package:collectors_center/View/Objects/verObjetosGenerales.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Método encargado de realizar la descripción del artículo.
Future<void> editDescriptionByImageUrl(
    BuildContext context, String imageUrl, String description) async {
  bool internet = await conexionInternt();
  if (internet == false) {
    return;
  }
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Reference to the user's "Users" collection
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

      // Query for the user's document
      DocumentSnapshot userDocSnapshot =
          await usersCollection.doc(user.uid).get();

      if (userDocSnapshot.exists) {
        // Reference to the "Categories" subcollection within the user's document
        CollectionReference categoriesCollection =
            userDocSnapshot.reference.collection('Categories');

        // Query all category documents
        QuerySnapshot categoriesQuerySnapshot =
            await categoriesCollection.get();

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
              // Update the "Description" field to be blank ("")
              await objectDoc.reference.update({'Description': description});

              // You can show a success message here if needed
              Fluttertoast.showToast(
                msg: "Se han guardado los cambios",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );

              // Exit the function after successfully clearing the description
              return;
            }
          }
        }
      }
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "No es posible guardar los cambios",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

// Método encargado de eliminar la descripción de un artículo y dejar vacío el campo de descripción
Future<void> clearDescriptionByImageUrl(
    BuildContext context, String imageUrl, String description) async {
  bool internet = await conexionInternt();
  if (internet == false) {
    return;
  }
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Reference to the user's "Users" collection
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

      // Query for the user's document
      DocumentSnapshot userDocSnapshot =
          await usersCollection.doc(user.uid).get();

      if (userDocSnapshot.exists) {
        // Reference to the "Categories" subcollection within the user's document
        CollectionReference categoriesCollection =
            userDocSnapshot.reference.collection('Categories');

        // Query all category documents
        QuerySnapshot categoriesQuerySnapshot =
            await categoriesCollection.get();

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
              // Update the "Description" field to be blank ("")
              await objectDoc.reference.update({'Description': description});

              // You can show a success message here if needed
              Fluttertoast.showToast(
                msg: "Descripción borrada exitosamente",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );

              // Exit the function after successfully clearing the description
              return;
            }
          }
        }
      }
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "La descripción no se ha eliminado",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

void goToEditarObjetoGeneral(
    BuildContext context, String url, String firebase) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => EditarObjetosGenerales(
              url: url,
              firebaseURL: firebase,
            )),
  );
}

void goToEditarObjeto(BuildContext context, String url, String firebase) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => EditarObjetos(
              url: url,
              firebaseURL: firebase,
            )),
  );
}

void goToVerObjectsCategorias(BuildContext context, String name) {
  Navigator.push(
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
          builder: (context) => const agregarObjectsGeneral(categoria: "")));
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

      return objectList;
    } else {
      // Category doesn't exist
      return [];
    }
  } else {
    // User not logged in
    return [];
  }
}

Future<Map<String, String>> getImageInfoByImageUrl(
    BuildContext context, String imageUrl) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    final storageRef = FirebaseStorage.instance.ref();
    if (user != null) {
      // Reference to the user's "Users" collection
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

      // Query for the user's document
      DocumentSnapshot userDocSnapshot =
          await usersCollection.doc(user.uid).get();

      if (userDocSnapshot.exists) {
        // Reference to the "Categories" subcollection within the user's document
        CollectionReference categoriesCollection =
            userDocSnapshot.reference.collection('Categories');

        // Query all category documents
        QuerySnapshot categoriesQuerySnapshot =
            await categoriesCollection.get();

        // Loop through the category documents
        for (final categoryDoc in categoriesQuerySnapshot.docs) {
          // Reference to the "Objects" subcollection within the category document
          CollectionReference objectsCollection =
              categoryDoc.reference.collection('Objects');
          final categoryName = categoryDoc['Name'];

          // Query all documents within the "Objects" subcollection
          QuerySnapshot objectsQuerySnapshot = await objectsCollection.get();
          final imageref = storageRef.child(imageUrl);
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
                'imageCategory': categoryName
              };
            }
          }
        }
      }
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Error al buscar la imagen",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Return an empty Map if no matching image URL was found or there's an error
  return {'imageName': '', 'imageDescription': '', 'imageCategory': ''};
}

Future<void> deleteByCategory(
    BuildContext context, String imageUrl, String category) async {
  await deleteImageByImageUrl(imageUrl);

  goToVerObjectsCategorias(context, category);
}

Future<void> deleteByCategoryNoMessage(
    BuildContext context, String imageUrl, String category) async {
  await deleteImageByImageUrlNoMessage(imageUrl);

  goToVerObjectsCategorias(context, category);
}

Future<void> deleteByGeneral(BuildContext context, String imageUrl) async {
  await deleteImageByImageUrl(imageUrl);

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const verObjetosGenerales(),
    ),
  );
}

Future<void> deleteByGeneralNoMessage(
    BuildContext context, String imageUrl) async {
  await deleteImageByImageUrlNoMessage(imageUrl);

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const verObjetosGenerales(),
    ),
  );
}

Future<void> deleteImageByImageUrl(String imageUrl) async {
  bool internet = await conexionInternt();
  final storageRef = FirebaseStorage.instance.ref();
  if (internet == false) {
    return;
  }
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Reference to the user's "Users" collection
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

      // Query for the user's document
      DocumentSnapshot userDocSnapshot =
          await usersCollection.doc(user.uid).get();

      if (userDocSnapshot.exists) {
        // Reference to the "Categories" subcollection within the user's document
        CollectionReference categoriesCollection =
            userDocSnapshot.reference.collection('Categories');

        // Query all category documents
        QuerySnapshot categoriesQuerySnapshot =
            await categoriesCollection.get();

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
              // Delete the document if a match is found

              await objectDoc.reference.delete();
              final imageref = storageRef.child(imageUrl);
              await imageref.delete();
              // Return after deletion or handle as needed
              Fluttertoast.showToast(
                msg: "“El artículo ha sido eliminado correctamente",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return;
            }
          }
        }
      }
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "“El artículo no se ha eliminado",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

Future<void> deleteImageByImageUrlNoMessage(String imageUrl) async {
  bool internet = await conexionInternt();
  final storageRef = FirebaseStorage.instance.ref();
  if (internet == false) {
    return;
  }
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Reference to the user's "Users" collection
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

      // Query for the user's document
      DocumentSnapshot userDocSnapshot =
          await usersCollection.doc(user.uid).get();

      if (userDocSnapshot.exists) {
        // Reference to the "Categories" subcollection within the user's document
        CollectionReference categoriesCollection =
            userDocSnapshot.reference.collection('Categories');

        // Query all category documents
        QuerySnapshot categoriesQuerySnapshot =
            await categoriesCollection.get();

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
              // Delete the document if a match is found

              await objectDoc.reference.delete();
              final imageref = storageRef.child(imageUrl);
              await imageref.delete();
              // Return after deletion or handle as needed

              return;
            }
          }
        }
      }
    }
  } catch (e) {
    print("");
  }
}
