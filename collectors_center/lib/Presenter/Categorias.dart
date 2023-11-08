import 'package:collectors_center/Presenter/Cuentas.dart';
import 'package:collectors_center/View/Categorias/VerCategorias.dart';
import 'package:collectors_center/View/Categorias/agregarCategorias.dart';
import 'package:collectors_center/View/recursos/validaciones.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> clearCategoryDescription(String category) async {
  bool internet = await conexionInternt();
  if (!internet) {
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
          // Check if the category name matches the desired category
          if (categoryDoc['Name'] == category) {
            // Update the "Description" field to be blank ("")
            await categoryDoc.reference.update({'Description': ''});

            // You can show a success message here if needed
            Fluttertoast.showToast(
              msg: "Descripción de la categoría eliminada exitosamente",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            // Exit the function after successfully clearing the category description
            return;
          }
        }
      }
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "La descripción de la categoría no se ha eliminado",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

//////////////////////////////////
//  Navegacion dentro de la app encargado de categorías //
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
// Te lleva a la pantalla de agregar Categorías
void agregarCategoria(BuildContext context) {
  Navigator.push(context,
      MaterialPageRoute(builder: (context) => const agregarCategorias()));
}

//Permite agregar categorías con descripcion ademas de mostrar advertencias
void agregarCategoriaBase(
    BuildContext context, String categoria, String descripcion) async {
  bool internet = await conexionInternt();
  if (!internet) {
    mostrarToast("No tienes conexión a Internet. Verifica tu conexión.");
    return;
  }

  if (categoria.trim() == "") {
    mostrarToast("Ingrese un nombre");
    return;
  }

  if (categoria.length > 20) {
    mostrarToast("El nombre debe ser de máximo 20 caracteres");
    return;
  }

  if ((descripcion.length < 15 && descripcion.isNotEmpty) ||
      (!descripcion.contains(RegExp(r'[a-zA-Z]')) && descripcion.isNotEmpty)) {
    mostrarToast(
        "La descripción debe contener letras y tener al menos 15 caracteres");
    return;
  }

  if (descripcion == categoria) {
    mostrarToast(
        "La descripción no puede ser igual al nombre de la categoría.");
    return;
  }

  if (descripcion.length > 300) {
    mostrarToast("La descripción no puede exceder los 300 caracteres");
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

    QuerySnapshot categoryQuery =
        await categoriasCollection.where('Name', isEqualTo: categoria).get();

    if (categoryQuery.docs.isEmpty) {
      categoriasCollection.add({
        'Name': categoria,
        'Description': descripcion,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Fluttertoast.showToast(
        msg: "Categoría agregada exitosamente",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green, // Cambiado a color verde para éxito
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const verCategorias()),
  );
    } else {
      mostrarToast("La categoría ya existe");
    }
  } else {
    mostrarToast("No estás logeado");
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
          .doc(user.uid)
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

Future<bool> categoriesExist(String category) async {
  List<String> categories = [];

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

        if (categoryName == category) {
          return true;
        }
      }
    }
  } catch (e) {
    print('Error fetching categories: $e');
  }

  return false;
}

Future<String> fetchDescriptions(String category) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      DocumentReference usersDoc = firestore.collection('Users').doc(uid);
      CollectionReference categoriesCollection =
          usersDoc.collection("Categories");

      QuerySnapshot categoryQuery =
          await categoriesCollection.where('Name', isEqualTo: category).get();

      if (categoryQuery.docs.isNotEmpty) {
        DocumentSnapshot categoryDoc = categoryQuery.docs.first;

        return categoryDoc['Description'];
      } else {
        return "";
      }
    }
  } catch (e) {
    print('Error fetching categories: $e');
  }

  return "";
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

Future<void> editCategoryDescription(
    String categoryName, String description) async {
  bool internet = await conexionInternt();
  if (internet == false) {
    return;
  }

  final containsLetter = RegExp(r'[a-zA-Z]').hasMatch(description);

  if (description.length < 15 && description.isNotEmpty) {
    mostrarToast(
        "La descripción debe tener al menos 15 caracteres si no está vacía");
    return;
  }

  if (description.length > 300) {
    mostrarToast("La descripción no puede exceder los 300 caracteres");
    return;
  }

  if (!containsLetter && description.isNotEmpty) {
    mostrarToast("La descripción debe contener letras");
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

        // Query for the category document with the specified name
        QuerySnapshot categoryQuerySnapshot = await categoriesCollection
            .where('Name', isEqualTo: categoryName)
            .get();

        if (categoryQuerySnapshot.docs.isNotEmpty) {
          // Get the reference to the category document
          DocumentReference categoryDocRef =
              categoryQuerySnapshot.docs.first.reference;

          // Update the category's description
          await categoryDocRef.update({'Description': description});

          // Show a success message
          mostrarToastCorrecto("Se han guardado los cambios");

          // You can exit the function here if needed
          return;
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

Future<void> editCategoryName(String categoryName, String newName) async {
  bool internet = await conexionInternt();
  if (internet == false) {
    return;
  }

  final containsLetter = RegExp(r'[a-zA-Z]').hasMatch(newName);

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

        // Query for the category document with the specified name
        QuerySnapshot categoryQuerySnapshot = await categoriesCollection
            .where('Name', isEqualTo: categoryName)
            .get();

        if (categoryQuerySnapshot.docs.isNotEmpty) {
          // Get the reference to the category document
          DocumentReference categoryDocRef =
              categoryQuerySnapshot.docs.first.reference;

          // Update the category's description
          await categoryDocRef.update({'Name': newName});

          // Show a success message
          mostrarToastCorrecto("Se han guardado los cambios");

          // You can exit the function here if needed
          return;
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
