import 'package:collectors_center/Presenter/Cuentas.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
//Revisa si se cuenta con una conexión a intenret
Future<bool> conexionInternt() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    // No internet connection
    mostrarToast("Sin conexión a Internet");
   
    return false;
  }
  return true;
}

bool isStrongPassword(String password) {
  // Check if the password has at least one letter
  bool hasLetter = password.contains(RegExp(r'[a-zA-Z]'));

  // Check if the password has at least one uppercase letter
  bool hasUppercase = password.contains(RegExp(r'[A-Z]'));

  // Check if the password has at least one special symbol
  bool hasSpecialSymbol =
      password.contains(RegExp(r'[!@#\$%^&*()_+{}\[\]:;<>,.?~\\-]'));

  return hasLetter && hasUppercase && hasSpecialSymbol;
}

bool isValidEmail(String email) {
  // A more robust regular expression for validating email addresses.
  final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[a-z]{2,})$');

  // Additional check to exclude email addresses like "5@5.5".
  final validEmail = emailRegex.hasMatch(email);

  // Check if the email has the "@uaz.edu.mx" or "@cetis113.edu.mx" domain.
  final isUazEmail = email.endsWith("@uaz.edu.mx");
  final isCetisEmail = email.endsWith("@cetis113.edu.mx");

  return validEmail || isUazEmail || isCetisEmail;
}