//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Armando                                                               //
//   Fecha:                           26/09/23                                                              //
//   Descripción:                     Vista de inicio de sesión de usuarios ya registrados                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  TextEditingController _nombreUsuarioController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _idnumber = TextEditingController();

  bool _editingEnabled = false; // Estado para controlar la edición

  //Crea todos los textfields para recibir los datos
  Widget buildInputField(
      String hintText,
      String? valor,
      TextEditingController controller,
      bool obscureText,
      TextInputType inputType,
      double screenWidth) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          width: screenWidth - 50,
          height: 70,
          decoration: BoxDecoration(
            color: myColor.withOpacity(.8),
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            hintText + " " + valor!,
            style: TextStyle(color: brown, fontSize: 26),
          ),
        ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    //Se comunica con el presentador para regresar
    void regresar() {
      regresarAnterior(context);
    }

    ///Se comunica con el presentador para salir de las sesión
    void logout() {
      cerrarSesion(context);
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
              height: screenheight,
              color: peach,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 55,
                    ),
                    Center(
                      child: Image.asset(
                        'lib/assets/images/Usuario.png',
                        width: screenWidth - 20,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    buildInputField(
                        ' Usuario: ',
                        FirebaseAuth.instance.currentUser?.displayName
                            .toString(),
                        _nombreUsuarioController,
                        false,
                        TextInputType.text,
                        screenWidth),
                    const SizedBox(
                      height: 15,
                    ),
                    buildInputField(
                        ' e-mail: ',
                        FirebaseAuth.instance.currentUser?.email.toString(),
                        _emailController,
                        false,
                        TextInputType.emailAddress,
                        screenWidth),
                    const SizedBox(
                      height: 15,
                    ),
                    //buildInputField('ID: ', _idnumber, true, TextInputType.text,
                    //    screenWidth),
                    //const SizedBox(
                    //  height: 15,
                    //),
                    //buildInputField('Password', _passwordController, true,
                    //    TextInputType.text, screenWidth),
                    //const SizedBox(
                    //  height: 35,
                    //),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: GestureDetector(
                        onTap: logout,
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: screenWidth - 100,
                            height: 50,
                            decoration: BoxDecoration(
                                color: red,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.white, width: 2)),
                            child: const Center(
                                child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: GestureDetector(
                        onTap: regresar,
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: screenWidth - 100,
                            height: 50,
                            decoration: BoxDecoration(
                                color: brown,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.white, width: 2)),
                            child: Center(
                                child: Text(
                              'Regresar',
                              style: TextStyle(
                                color: myColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
