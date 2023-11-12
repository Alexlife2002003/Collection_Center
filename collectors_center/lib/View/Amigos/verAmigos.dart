import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/Bienvenido.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';

class verAmigos extends StatefulWidget {
  const verAmigos({super.key});

  @override
  State<verAmigos> createState() => _verAmigosState();
}

class _verAmigosState extends State<verAmigos> {
  @override
  Widget build(BuildContext context) {
    void enviarSolicitud() {
      String userInput = '';
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
                userInput = value;
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
                      // Process the user input (you can add your logic here)
                      if (userInput.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: brown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              title: Text(
                                'Solicitud enviada a',
                                style: TextStyle(color: myColor),
                                textAlign: TextAlign.center,
                              ),
                              content: Text(
                                userInput,
                                style: TextStyle(color: peach),
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                ButtonBar(
                                  alignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.blue,
                                      ),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: brown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              title: Text(
                                'Error',
                                style: TextStyle(color: red),
                                textAlign: TextAlign.center,
                              ),
                              content: Text(
                                'El usuario no existe',
                                style: TextStyle(color: peach),
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                ButtonBar(
                                  alignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red,
                                      ),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    child: Text('Enviar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    child: Text('Cancelar'),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

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
                          fontWeight: FontWeight.bold),
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
                            )),
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
                            ))
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
