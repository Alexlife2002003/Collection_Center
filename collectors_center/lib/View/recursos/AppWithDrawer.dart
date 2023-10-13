//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Alexia                         //
//   Fecha:                              25/09/23                                                               //
//   Descripción:                    Cajón de la iquierda de la pantalla y appbar                     //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/Presenter/CategoriasPresenter.dart';
import 'package:collectors_center/View/Bienvenido.dart';
import 'package:collectors_center/View/Objects/verObjetosGenerales.dart';
import 'package:collectors_center/View/Perfil/Perfil.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppWithDrawer extends StatelessWidget {
  final Widget content;

  const AppWithDrawer({required this.content});

  @override
  Widget build(BuildContext context) {
    void categorias() {
      goToVerCategorias(context);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: peach,
        elevation: 0,
        iconTheme: IconThemeData(color: brown),
        actions: [
          IconButton(
            onPressed: () {
              // Navegar a la página del usuario cuando se presiona el icono
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Perfil(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: brown,
        // Drawer content
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              // Aumenta la altura del DrawerHeader
              height: 180,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: brown,
                ),
                child: InkWell(
                  onTap: () {
                    // Navegar a la página 'Bienvenido' cuando se presiona 'Collectors Center'
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => Bienvenido(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Collectors\nCenter',
                        style: TextStyle(
                          color: Color(0xFFFFEDBD),
                          fontSize: 40,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Divider(
                        // Agrega una línea separadora debajo de 'Collectors Center'
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('Inicio',
                  style: TextStyle(color: Colors.white, fontSize: 33)),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => Bienvenido(),
                  ),
                  (route) => false,
                );
              },
            ),
            ListTile(
              title: const Text('Ver artículos',
                  style: TextStyle(color: Colors.white, fontSize: 33)),
              onTap: () {
                if (fetchCategories() == []) {
                  Fluttertoast.showToast(
                    msg: "No se han creado categorías",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const verObjetosGenerales(),
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: const Text(
                'Agregar artículos',
                style: TextStyle(color: Colors.white, fontSize: 33),
              ),
              onTap: () {
                categorias();
              },
            ),
            // Add more ListTile widgets for additional items
          ],
        ),
      ),
      body: content, // Set the content here
    );
  }
}
