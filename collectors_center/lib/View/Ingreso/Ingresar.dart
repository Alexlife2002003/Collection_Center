//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Armando                                                               //
//   Fecha:                           26/09/23                                                              //
//   Descripción:                     Vista de inicio de sesión de usuarios ya registrados                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:collectors_center/Presenter/Presenter.dart';

class Ingresar extends StatefulWidget {
  const Ingresar({super.key});

  @override
  State<Ingresar> createState() => _IngresarState();
}

class _IngresarState extends State<Ingresar> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: inputType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(143, 64, 52, 42),
                  fontSize: 24),
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

    ///Se comunica con el presentador para ingresar a la aplicación
    void ingresar() {
      ingresarUsuario(context, _emailController.text, _passwordController.text);
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
                const SizedBox(
                  height: 55,
                ),
                Center(
                  child: Image.asset(
                    'lib/assets/images/Usuario.png',
                    width: screenWidth - 160,
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                buildInputField('e-mail', _emailController, false,
                    TextInputType.emailAddress, screenWidth),
                const SizedBox(
                  height: 15,
                ),
                buildInputField('Password', _passwordController, true,
                    TextInputType.text, screenWidth),
                const SizedBox(
                  height: 110,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: ingresar,
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: screenWidth - 100,
                        height: 50,
                        decoration: BoxDecoration(
                            color: myColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2)),
                        child: Center(
                            child: Text(
                          'Ingresar',
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
