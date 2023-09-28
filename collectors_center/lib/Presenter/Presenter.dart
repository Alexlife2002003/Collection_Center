//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Alexia                                                                //
//   Fecha:                           25/09/23                                                              //
//   Descripción:                     Viene toda la logica de la app                                        //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/View/AntesDeIngresar/Inicio.dart';
import 'package:collectors_center/View/AntesDeIngresar/Registrarse.dart';
import 'package:collectors_center/View/Ingreso/Ingresar.dart';
import 'package:collectors_center/View/Bienvenido.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';

//////////////////////////////////
//  Navegacion dentro de la app //
//////////////////////////////////

Future<bool> conexionInternt() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    // No internet connection
    Fluttertoast.showToast(
      msg: "No internet connection",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return false;
  }
  return true;
}

// Te lleva a la pantalla de registro
void goToRegistrarse(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Registrarse()),
  );
}

// Te lleva a la pantalla de inicio de sesión
void goToIngresar(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Ingresar()),
  );
}

// Te regresa a la pantalla anterior
void regresarAnterior(BuildContext context) {
  Navigator.of(context).pop();
}

// Te lleva a la pantalla de bienvenido
void goToBienvenido(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Bienvenido()),
  );
}

//////////////////////////////////////////////////////////////
// Acciones de registro, inicio de sesión y fin de sesión   //
//////////////////////////////////////////////////////////////

//Logica para registrar usuario
Future<void> registrarUsuario(BuildContext context, String usuario,
    String correo, String password, String confirmPassword) async {
  bool internet = await conexionInternt();
  if (internet == false) {
    return;
  }

  try {
    // Check if the username is already taken in Firestore
    final QuerySnapshot usernameCheck = await FirebaseFirestore.instance
        .collection('Users')
        .where('User', isEqualTo: usuario)
        .get();

    if (usernameCheck.docs.isNotEmpty) {
      // Username is already taken

      mostrarToast('User already in use');

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
      mostrarToast('Passwords do not match');
    }
  } on FirebaseAuthException catch (e) {
    print("este es el error: " + e.code);
    if (e.code == 'email-already-in-use') {
      mostrarToast('Email already in use');
    }
  }
}

// Funcion encargada de ingresar a la sesión del usuario que ya creó anteriormente
Future<void> ingresarUsuario(
    BuildContext context, String correo, String password) async {
  bool internet = await conexionInternt();
  if (internet == false) {
    return;
  }
  try {
    final userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: correo,
      password: password,
    );

    if (userCredential.user != null) {
      // El inicio de sesión fue exitoso
      goToBienvenido(context);
    } else {
      mostrarToast("Inicio de sesión fallido");
    }
  } on FirebaseAuthException catch (e) {
    print("Este es el error: " + e.code);
    if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      print("este es el error: " + e.code);
      mostrarToast("Credenciales incorrectas");
    } else if (e.code == 'user-disabled') {
      print("este es el error: " + e.code);
      mostrarToast("La cuenta ha sido desactivada");
    }
  }
}

// Función para mostrar el mensaje con Fluttertoast
void mostrarToast(String mensaje) {
  Fluttertoast.showToast(
    msg: mensaje,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

// Método encargado de cerrar la sesión del usuario
Future<void> cerrarSesion(BuildContext context) async {
  bool internet = await conexionInternt();
  if (internet == false) {
    return;
  }
  try {
    await FirebaseAuth.instance.signOut();
    goToInicio(context); // Llama a la función para ir a la pantalla de inicio
  } catch (e) {
    print("Error al cerrar la sesión: $e");
    // Manejar errores, si es necesario
  }
}

// Método encargado de regresarte a la pantalla de incio
void goToInicio(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const Inicio()),
    (Route<dynamic> route) => false,
  );
}

//////////////////////////////////////
// Operaciones de la base de datos  //
//////////////////////////////////////

//Crea la coleccion USERS con los datos del usuario
void createUserDatabase(String UID, String usuario, String correo) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference usersDetails = firestore.collection('Users');
  usersDetails.doc(UID).set({'User': usuario, 'Email': correo});
}
