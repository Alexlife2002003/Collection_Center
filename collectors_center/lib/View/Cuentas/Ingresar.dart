//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Tacos de Asada                                                               //
//   Fecha:                           26/09/23                                                              //
//   Descripción:                     Vista de inicio de sesión de usuarios ya registrados                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/Presenter/Cuentas.dart';
import 'package:flutter/material.dart';
import 'package:collectors_center/View/recursos/colors.dart';


class Ingresar extends StatefulWidget {
  const Ingresar({super.key});

  @override
  State<Ingresar> createState() => _IngresarState();
}

class _IngresarState extends State<Ingresar> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  //Crea todos los textfields para recibir los datos
  Widget buildInputField(String hintText, TextEditingController controller,
      bool obscureText, TextInputType inputType, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: inputType,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white, width: 1.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: myColor),
              borderRadius: BorderRadius.circular(12.0),
            ),
            labelText: hintText,
            hintStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
            ),
            labelStyle: TextStyle(color: peach),
            filled: true,
            fillColor: Colors.grey.withOpacity(.8),
          ),
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
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
 
    ///Se comunica con el presentador para ingresar a la aplicación
    void ingresar() {
      ingresarUsuario(
          context, _emailController.text.trim(), _passwordController.text);
    }

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'lib/assets/images/library-bg.jpg',
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
                buildInputField('Correo Electrónico', _emailController, false,
                    TextInputType.emailAddress, screenWidth),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          color: _passwordVisible
                              ? peach
                              : const Color.fromARGB(255, 95, 95, 95),
                          icon: Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.white, width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: myColor),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        labelText: 'Contraseña',
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 24,
                        ),
                        labelStyle: TextStyle(color: peach),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(.8),
                      ),
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
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
                    onTap: (){
                       Navigator.pop(context);
                    },
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
