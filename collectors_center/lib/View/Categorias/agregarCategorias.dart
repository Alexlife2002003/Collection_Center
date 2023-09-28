import 'package:collectors_center/Presenter/Presenter.dart';
import 'package:collectors_center/View/recursos/AppWithDrawer.dart';
import 'package:collectors_center/View/recursos/colors.dart';
import 'package:flutter/material.dart';

class agregarCategorias extends StatefulWidget {
  const agregarCategorias({super.key});

  @override
  State<agregarCategorias> createState() => _agregarCategoriasState();
}

class _agregarCategoriasState extends State<agregarCategorias> {
  final _nombreCategoriaController = TextEditingController();
  void agregar() {
    agregarCategoriaBase(context, _nombreCategoriaController.text);
  }

  void cancelar() {
    regresarAnterior(context);
  }

  @override
  void dispose() {
    _nombreCategoriaController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return AppWithDrawer(
      content: Scaffold(
        body: Container(
          height: screenheight,
          width: screenWidth,
          color: peach,
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Nueva\nCategoría',
                  style: TextStyle(
                      fontSize: 42, color: brown, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  width: screenWidth - 150,
                  height: 50,
                  decoration: BoxDecoration(
                    color: myColor,
                    border: Border.all(color: Colors.white, width: .2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _nombreCategoriaController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Nombre',
                        hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF503A27),
                            fontSize: 20),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 2 * (screenheight / 3.6),
              ),
              Container(
                width: screenWidth - 200,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.blue)),
                  onPressed: agregar,
                  child: Text('Guardar'),
                ),
              ),
              Container(
                width: screenWidth - 200,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red)),
                  onPressed: cancelar,
                  child: Text('Cancelar'),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
