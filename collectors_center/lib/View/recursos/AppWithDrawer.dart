import 'package:collectors_center/Presenter/CategoriasPresenter.dart';
import 'package:collectors_center/Presenter/Presenter.dart';
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
    double screenWidth = MediaQuery.of(context).size.width;
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
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 180,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: brown,
                ),
                child: InkWell(
                  onTap: () {
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
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Image.asset("lib/assets/images/home_icon.png"),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text('Inicio',
                      style: TextStyle(color: Colors.white, fontSize: 33)),
                ],
              ),
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
              title: Row(
                children: [
                  Image.asset("lib/assets/images/Articles_icon.png"),
                  const SizedBox(
                    width: 14,
                  ),
                  const Text('Artículos',
                      style: TextStyle(color: Colors.white, fontSize: 33)),
                ],
              ),
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
              title: Row(
                children: [
                  Image.asset("lib/assets/images/Categories_icon.png"),
                  const SizedBox(
                    width: 18,
                  ),
                  const Text(
                    'Categorías',
                    style: TextStyle(color: Colors.white, fontSize: 33),
                  ),
                ],
              ),
              onTap: () {
                categorias();
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: GestureDetector(
                onTap: () {
                  cerrarSesion(context);
                },
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: screenWidth - 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: myColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: Color(0xFF40342A),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: content,
    );
  }
}
