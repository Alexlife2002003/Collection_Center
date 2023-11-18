import 'package:flutter/material.dart';

import 'dart:math';

void showSnackbar(BuildContext context, String message, Color backgroundColor) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: backgroundColor,
    duration: const Duration(milliseconds: 1500),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

//Crea un nombre random
String generateRandomFileName() {
  final random = Random.secure();
  return DateTime.now().millisecondsSinceEpoch.toString() +
      random.nextInt(999999).toString();
}
