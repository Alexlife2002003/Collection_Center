//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Tacos de Asada                                                        //
//   Fecha:                           19/11/23                                                              //
//   Descripción:                     View de los objetos de amigos dentro de la aplicación                 //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/Inicio.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class verObjetosIndividuales extends StatefulWidget {
  final String url;
  final String name;
  final String category;
  final String description;

  verObjetosIndividuales(
      {super.key,
      required this.url,
      required this.name,
      required this.category,
      required this.description});

  @override
  State<verObjetosIndividuales> createState() => _verObjetosIndividualesState();
}

@override
void dispose() {}

class _verObjetosIndividualesState extends State<verObjetosIndividuales> {
  String name = "";
  String descripcion = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Si el usuario no está autenticado, redirigirlo a la pantalla de inicio de sesión
      return const Inicio();
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: AppWithDrawer(
        currentPage: "objetosIndividuales",
        content: Scaffold(
          body: Container(
            height: screenHeight,
            width: screenWidth,
            color: peach,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Artículo',
                      style: TextStyle(
                        fontSize: 42,
                        color: brown,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 75,
                  ),
                  Center(
                    child: Column(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.url,
                          width: 200,
                          height: 200,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "       Nombre:",
                    style: TextStyle(color: brown, fontSize: 22),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      width: screenWidth - 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: myColor,
                        border: Border.all(color: Colors.white, width: .2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          widget.name,
                          style: TextStyle(
                            color: brown,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "       Descripción:",
                    style: TextStyle(color: brown, fontSize: 22),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: screenWidth - 50,
                            decoration: BoxDecoration(
                              color: myColor,
                              border:
                                  Border.all(color: Colors.white, width: .2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                widget.description,
                                style: TextStyle(color: brown, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "       Categoría:",
                    style: TextStyle(color: brown, fontSize: 22),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: screenWidth - 50,
                            decoration: BoxDecoration(
                              color: myColor,
                              border:
                                  Border.all(color: Colors.white, width: .2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                widget.category,
                                style: TextStyle(color: brown, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: (screenHeight / 33),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
