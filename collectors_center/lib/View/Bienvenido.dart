//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Alexia                                                                //
//   Fecha:                           25/09/23                                                              //
//   Descripción:                     Pantalla de bienvida despues de registrarse o iniciar sesión          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/AntesDeIngresar/Inicio.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:flutter/material.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Bienvenido extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Si el usuario no está autenticado, redirigirlo a la pantalla de inicio de sesión
      return const Inicio();
    }

    conexionInternt();

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AppWithDrawer(
        content: Container(
          color: peach,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Bienvenido',
                  style: TextStyle(
                      fontSize: 60, color: brown, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Image.asset(
                  'lib/assets/images/logo.png',
                  width: screenWidth - 50,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
