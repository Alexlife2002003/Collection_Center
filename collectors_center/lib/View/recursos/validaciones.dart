import 'package:collectors_center/View/recursos/colors.dart';
import 'package:collectors_center/View/recursos/utils.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

import 'package:http/http.dart' as http;

//Revisa si se cuenta con una conexión a intenret
Future<bool> conexionInternt(BuildContext context) async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    // No internet connection
    showSnackbar(context, "Sin conexión a Internet", Colors.red);
    return false;
  } else {
    // Check Wi-Fi speed
    double responseTime = await checkNetworkResponseTime();
    print('Network Response Time: $responseTime milliseconds');

    if (responseTime > 1500) {
      // Slow connection
      showSnackbar(context, "Slow Wi-Fi Connection", Colors.yellow);
      return false;
    } else {
      return true;
    }
  }
}

Future<double> checkNetworkResponseTime() async {
  final startTime = DateTime.now();

  try {
    final response = await http.get(Uri.parse('https://www.google.com'));
    if (response.statusCode == 200) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      return duration.inMilliseconds.toDouble();
    }
  } catch (e) {
    // Handle error
  }

  return double.infinity; // Return a large value for failed requests
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
