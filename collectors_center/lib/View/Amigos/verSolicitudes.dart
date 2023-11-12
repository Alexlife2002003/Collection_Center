import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/Bienvenido.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';

class verSolicitudes extends StatefulWidget {
  const verSolicitudes({super.key});

  @override
  State<verSolicitudes> createState() => _verSolicitudesState();
}

class _verSolicitudesState extends State<verSolicitudes> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => Bienvenido())));
        return true;
      },
      child: AppWithDrawer(
        currentPage: "verSolicitudes",
        content: Scaffold(
          backgroundColor: peach,
          body: Column(
            children: <Widget>[
              Container(
                color: peach,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Notificaciones',
                      style: TextStyle(
                          fontSize: 42,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
