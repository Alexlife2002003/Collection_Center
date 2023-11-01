///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Tacos de Asada                                                                 //
//   Fecha:                           25/09/23                                                               //
//   Descripción:                     Pantalla donde puedes decidir entre registrarte o iniciar sesión       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    void navigateToAcceder() {
      goToIngresar(context);
    }

    void navigateToRegistrarse() {
      goToRegistrarse(context);
    }

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'lib/assets/images/library-bg.jpg',
            fit: BoxFit.cover,
            width: screenheight,
            height: screenheight,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenheight / 11),
              Image.asset(
                'lib/assets/images/logo.png',
                width: screenWidth - 20,
              ),
              Container(
                width: screenWidth - 50,
                height: 6,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: myColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(
                width: screenWidth - 10,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: GestureDetector(
                          onTap: navigateToAcceder,
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 146,
                              height: 50,
                              decoration: BoxDecoration(
                                color: myColor,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  'Acceder',
                                  style: TextStyle(
                                      color: brown,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: GestureDetector(
                          onTap: navigateToRegistrarse,
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 146,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: brown,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white, width: 2)),
                              child: Center(
                                  child: Text(
                                'Registrarse',
                                style: TextStyle(
                                  color: myColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenheight / 10,
              )
            ],
          )
        ],
      ),
    );
  }
}
