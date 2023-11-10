//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Alexia                                                                //
//   Fecha:                           25/09/23                                                              //
//   Descripción:                     Viene toda la logica de la app                                        //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/View/recursos/Bienvenido.dart';
import 'package:collectors_center/View/recursos/Inicio.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:collectors_center/View/recursos/utils.dart';
import 'package:collectors_center/View/recursos/validaciones.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

//////////////////////////////////
//  Navegacion dentro de la app encargada de acciones de registro e inicio de sesion del usuarios//
//////////////////////////////////

//////////////////////////////////////////////////////////////
// Acciones de registro, inicio de sesión y fin de sesión   //
//////////////////////////////////////////////////////////////

Future<void> registrarUsuario(BuildContext context, String usuario,
    String correo, String password, String confirmPassword) async {
  bool internet = await conexionInternt(context);
  if (internet == false) {
    return;
  }

  if (correo.isEmpty ||
      usuario.isEmpty ||
      password.isEmpty ||
      confirmPassword.isEmpty) {
    showSnackbar(context, 'Ingresa los datos faltantes.', red);
    return;
  }

  if (!isValidEmail(correo)) {
    showSnackbar(context, 'Ingresa un correo válido', red);
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
      showSnackbar(context, 'Usuario ya se encuentra en uso ', red);
      return;
    }

    if (password == confirmPassword) {
      if (password.length < 6) {
        showSnackbar(context, 'Contraseña debe tener 6 caracteres o más', red);
      } else if (!isStrongPassword(password)) {
        showSnackbar(
            context,
            'La contraseña debe contener al menos una letra, una mayúscula y un símbolo especial.',
            red);
      } else {
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: correo,
          password: password,
        );

        // Create the user in Firestore
        createUserDatabase(userCredential.user!.uid, usuario, correo);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Bienvenido()),
        );
      }
    } else {
      showSnackbar(context, 'Las contraseñas no son iguales', red);
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      showSnackbar(context, 'Correo ya se encuentra en uso', red);
    }
  }
}

// Funcion encargada de ingresar a la sesión del usuario que ya creó anteriormente
Future<void> ingresarUsuario(
    BuildContext context, String correo, String password) async {
  bool internet = await conexionInternt(context);
  if (internet == false) {
    showSnackbar(
        context, 'No tienes conexión a Internet. Verifica tu conexión.', red);
    return;
  }

  if (correo.isEmpty || password.isEmpty) {
    showSnackbar(context, 'Ingresa tu correo electrónico y contraseña.', red);
    return;
  }

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: correo,
      password: password,
    );

    // Guardar el estado de autenticación en Shared Preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Bienvenido()),
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'INVALID_LOGIN_CREDENTIALS' ||
        e.code == 'user-not-found' ||
        e.code == 'wrong-password' ||
        e.code == 'invalid-email') {
      showSnackbar(context,
          'La contraseña o el correo electrónico son incorrectos', red);
    }
  }
}

// Método encargado de cerrar la sesión del usuario
Future<void> cerrarSesion(BuildContext context) async {
  bool internet = await conexionInternt(context);
  if (internet == false) {
    return;
  }
  try {
    await FirebaseAuth.instance.signOut();
    // Llama a la función para ir a la pantalla de inicio
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Inicio()),
      (Route<dynamic> route) => false,
    );
  } catch (e) {
    showSnackbar(context, "Error al cerrar la sesión", red);
  }
}

//////////////////////////////////////
// Operaciones de la base de datos  //
//////////////////////////////////////

//Crea la coleccion USERS con los datos del usuario
void createUserDatabase(String UID, String usuario, String correo) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference usersDetails = firestore.collection('Users');
  usersDetails.doc(UID).set({'User': usuario, 'Email': correo});
  FirebaseAuth.instance.currentUser?.updateDisplayName(usuario);
}
