import 'package:flutter/material.dart';
import 'package:collectors_center/Presenter/Amigos.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/Bienvenido.dart';
import 'package:collectors_center/View/recursos/colors.dart';

class VerAmigos extends StatefulWidget {
  const VerAmigos({Key? key}) : super(key: key);

  @override
  State<VerAmigos> createState() => _VerAmigosState();
}

class _VerAmigosState extends State<VerAmigos> {
  String userInput = '';

  void enviarSolicitud() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: brown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            'Inserta el nombre del usuario que quieres añadir a amigos',
            style: TextStyle(color: myColor),
          ),
          content: TextField(
            onChanged: (value) {
              setState(() {
                userInput = value;
              });
            },
            decoration: InputDecoration(
              fillColor: peach,
              filled: true,
              hintText: 'Nombre de Usuario',
              hintStyle: const TextStyle(fontWeight: FontWeight.bold),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          actions: <Widget>[
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    sendSolicitud(userInput).then((bool cumplido) {
                      Navigator.of(context).pop(); // Close the dialog

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            icon: cumplido
                                ? Icon(
                                    Icons.check_circle_outline,
                                    color: green,
                                    size: 40,
                                  )
                                : Icon(
                                    Icons.error,
                                    color: red,
                                    size: 40,
                                  ),
                            backgroundColor: brown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            title: Text(
                              cumplido ? 'Solicitud enviada a' : '',
                              style: TextStyle(
                                color: cumplido ? myColor : red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              cumplido
                                  ? userInput
                                  : 'No se pudo enviar la solicitud',
                              style: TextStyle(color: peach),
                              textAlign: TextAlign.center,
                            ),
                            actions: <Widget>[
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    userInput = "";
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                  ),
                                  child: Text('OK'),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: Text('Enviar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => Bienvenido())));
        return true;
      },
      child: AppWithDrawer(
        currentPage: "verAmigos",
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
                      'Amigos',
                      style: TextStyle(
                        fontSize: 42,
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.delete,
                            size: 60,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth - 160,
                        ),
                        IconButton(
                          onPressed: () {
                            enviarSolicitud();
                          },
                          icon: Icon(
                            Icons.person_add_alt_1_outlined,
                            size: 60,
                          ),
                        )
                      ],
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
