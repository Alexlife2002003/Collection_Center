//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Alexia                         //
//   Fecha:                              25/09/23                                                               //
//   Descripción:                    Viene toda la logica de la app                     //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/View/AntesDeIngresar/Registrarse.dart';
import 'package:collectors_center/View/Bienvenido.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//////////////////////////////
//Navegacion dentro de la app
////////////////////////////

//Te lleva a la pantalla de registro
void goToRegistrarse(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Registrarse()),
  );
}

//te regresa a la pantalla anterior
void regresarAnterior(BuildContext context) {
  Navigator.of(context).pop();
}

//te lleva a la pantalla de bienvenido
void goToBienvenido(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Bienvenido()),
  );
}

////////////////////////////////////////////////
///Acciones de registro, inicio de sesion y fin de sesion
//////////////////////////////////////////////////
///

//Logica para registrar usuario
Future<void> registrarUsuario(BuildContext context, String usuario,
    String correo, String password, String confirmPassword) async {
  try {
    // Check if the username is already taken in Firestore
    final QuerySnapshot usernameCheck = await FirebaseFirestore.instance
        .collection('Users')
        .where('User', isEqualTo: usuario)
        .get();

    if (usernameCheck.docs.isNotEmpty) {
      // Username is already taken
      print("Username already exists");
      return;
    }

    if (password == confirmPassword) {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correo,
        password: password,
      );

      // Create the user in Firestore
      createUserDatabase(userCredential.user!.uid, usuario, correo);
      goToBienvenido(context);
    } else {
      print("Passwords don't match");
    }
  } on FirebaseAuthException catch (e) {
    print("este es el error: " + e.code);
    if (e.code == 'email-already-in-use') {
      print("Email already in use");
    }
  }
}

/////////////////////////////////////
///Operaciones de la base de datos
/////////////////////////////////////

//Crea la coleccion USERS con los datos del usuario
void createUserDatabase(String UID, String usuario, String correo) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference usersDetails = firestore.collection('Users');
  usersDetails.doc(UID).set({'User': usuario, 'Email': correo});
}
