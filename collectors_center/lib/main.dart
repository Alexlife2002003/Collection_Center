//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Nombre:                          Alexia                                                                //
//   Fecha:                              25/09/23                                                           //
//   Descripción:                    Este es el programa principal, inicializa firebase                     //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:collectors_center/View/AntesDeIngresar/Inicio.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  //Se inicializa firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //se llama mandar la primera pantalla
    return const MaterialApp(debugShowCheckedModeBanner: false, home: Inicio());
  }
}
