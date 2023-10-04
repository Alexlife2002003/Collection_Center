//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Alexia                         //
//   Fecha:                              25/09/23                                                               //
//   Descripción:                    Cajón de la iquierda de la pantalla y appbar                     //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/Presenter/CategoriasPresenter.dart';
import 'package:collectors_center/View/Objects/verObjetosGenerales.dart';
import 'package:collectors_center/View/Perfil/Perfil.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';

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
              icon: const Icon(Icons.person))
        ],
      ),
      drawer: Drawer(
        backgroundColor: brown,
        // Drawer content goes here
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: brown,
                ),
                child: const Text(
                  'Collectors Center',
                  style: TextStyle(
                    color: Color(0xFFFFEDBD),
                    fontSize: 33,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              title: const Text('Articulos',
                  style: TextStyle(color: Colors.white, fontSize: 33)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const verObjetosGenerales(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Categorias',
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
