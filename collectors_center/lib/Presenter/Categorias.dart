import 'package:collectors_center/View/Categorias/verCategorias.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:collectors_center/View/recursos/utils.dart';
import 'package:collectors_center/View/recursos/validaciones.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> eliminarDescripcion(BuildContext context, String category) async {
  bool internet = await conexionInternt(context);
  if (!internet) {
    Navigator.pop(context);
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
            showSnackbar(context,
                "Descripción de la categoría eliminada exitosamente", green);

            // Exit the function after successfully clearing the category description
            return;
          }
        }
      }
    }
  } catch (e) {
    showSnackbar(
        context, "La descripción de la categoría no se ha eliminado", red);
  }
}

//////////////////////////////////
//  Navegacion dentro de la app encargado de categorías //
//////////////////////////////////
///

//Se encarga de borrar categorías
Future<void> eliminarCategoria(BuildContext context, String categoria) async {
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
            showSnackbar(context, "La categoría no se ha eliminado", red);
          }

          // Delete the object document
          await objectDoc.reference.delete();
        }

        // Delete the category document after deleting associated objects
        await categoryDoc.reference.delete();
        showSnackbar(
            context, "La categoría ha sido eliminada correctamente", green);
      } else {
        // Handle the case where no matching document was found
        showSnackbar(context, "La categoría no se ha eliminado", red);
      }
    }
  } catch (e) {
    showSnackbar(context, "La categoría no se ha eliminado", red);
  }
}

//Permite agregar categorías con descripcion ademas de mostrar advertencias
void agregarCategoria(
    BuildContext context, String categoria, String descripcion) async {
  bool internet = await conexionInternt(context);
  if (!internet) {
    showSnackbar(
        context, "No tienes conexión a Internet. Verifica tu conexión.", red);
    return;
  }

  if (categoria.trim() == "") {
    showSnackbar(context, "Ingrese un nombre", red);
    return;
  }

  if (categoria.length > 20) {
    showSnackbar(context, "El nombre debe ser de máximo 20 caracteres", red);
    return;
  }

  if ((descripcion.length < 15 && descripcion.isNotEmpty) ||
      (!descripcion.contains(RegExp(r'[a-zA-Z]')) && descripcion.isNotEmpty)) {
    showSnackbar(
        context,
        "La descripción debe contener letras y tener al menos 15 caracteres",
        red);
    return;
  }

  if (descripcion == categoria) {
    showSnackbar(context,
        "La descripción no puede ser igual al nombre de la categoría.", red);
    return;
  }

  if (descripcion.length > 300) {
    showSnackbar(
        context, "La descripción no puede exceder los 300 caracteres", red);
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
      showSnackbar(context, "Categoría agregada exitosamente", green);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const verCategorias()),
      );
    } else {
      showSnackbar(context, "La categoría ya existe", red);
    }
  } else {
    showSnackbar(context, "No estás logeado", red);
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

Future<void> editarDescripcion(
    BuildContext context, String categoryName, String description) async {
  bool internet = await conexionInternt(context);
  if (internet == false) {
    return;
  }

  final containsLetter = RegExp(r'[a-zA-Z]').hasMatch(description);

  if (description.length < 15 && description.isNotEmpty) {
    showSnackbar(
        context,
        "La descripción debe tener al menos 15 caracteres si no está vacía",
        red);
    return;
  }

  if (description.length > 300) {
    showSnackbar(
        context, "La descripción no puede exceder los 300 caracteres", red);
    return;
  }

  if (!containsLetter && description.isNotEmpty) {
    showSnackbar(context, "La descripción debe contener letras", red);
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
          showSnackbar(context, "Se han guardado los cambios", green);

          // You can exit the function here if needed
          return;
        }
      }
    }
  } catch (e) {
    showSnackbar(context, "No es posible guardar los cambios", red);
  }
}

Future<void> editarNombre(
    BuildContext context, String categoryName, String newName) async {
  bool internet = await conexionInternt(context);
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
          showSnackbar(context, "Se han guardado los cambios", green);

          // You can exit the function here if needed
          return;
        }
      }
    }
  } catch (e) {
    showSnackbar(context, "No es posible guardar los cambios", red);
  }
}
