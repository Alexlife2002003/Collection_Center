//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Alexia                         //
//   Fecha:                              25/09/23                                                               //
//   Descripción:                    Vista de registro de nuevos usuarios        //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:collectors_center/Presenter/Presenter.dart';

class Registrarse extends StatefulWidget {
  const Registrarse({super.key});

  @override
  State<Registrarse> createState() => _RegistrarseState();
}

class _RegistrarseState extends State<Registrarse> {
  final _nombreUsuarioController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  //Crea todos los textfields para recibir los datos
  Widget buildInputField(String hintText, TextEditingController controller,
      bool obscureText, TextInputType inputType, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        width: screenWidth - 50,
        height: 61,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.8),
          border: Border.all(color: Colors.white, width: .2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: inputType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF503A27),
                  fontSize: 20),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreUsuarioController.dispose();
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

    ///Se comunica con el presentador para registrarse
    void registrarse() {
      registrarUsuario(
          context,
          _nombreUsuarioController.text,
          _emailController.text,
          _passwordController.text,
          _confirmPasswordController.text);
    }

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'lib/assets/images/library-bg.png',
            fit: BoxFit.cover,
            width: screenWidth,
            height: screenheight,
          ),
          Container(
              child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 55,
                ),
                Center(
                  child: Image.asset(
                    'lib/assets/images/Usuario.png',
                    width: screenWidth - 160,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                buildInputField('Nombre de Usuario', _nombreUsuarioController,
                    false, TextInputType.text, screenWidth),
                SizedBox(
                  height: 15,
                ),
                buildInputField('e-mail', _emailController, false,
                    TextInputType.emailAddress, screenWidth),
                SizedBox(
                  height: 15,
                ),
                buildInputField('Password', _passwordController, true,
                    TextInputType.text, screenWidth),
                SizedBox(
                  height: 15,
                ),
                buildInputField('Confirm password', _confirmPasswordController,
                    true, TextInputType.text, screenWidth),
                SizedBox(
                  height: 35,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: registrarse,
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: screenWidth - 100,
                        height: 50,
                        decoration: BoxDecoration(
                            color: myColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2)),
                        child: Center(
                            child: Text(
                          'Registrar',
                          style: TextStyle(
                            color: brown,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
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
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2)),
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
