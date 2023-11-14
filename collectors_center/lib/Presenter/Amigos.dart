import 'package:collectors_center/View/Amigos/verSolicitudes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> obtenerUsuarioActual() async {
  // Get the current user
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Use the UID to retrieve the user data from Firestore
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

    if (documentSnapshot.exists) {
      // Access user data
      Map<String, dynamic> userData = documentSnapshot.data()!;
      String username = userData[
          'User']; // Change 'username' to the actual field in your user document
      return username;
    } else {
      return "";
    }
  } else {
    return "";
  }
}

Future<bool> sendSolicitud(String usuario) async {
  bool solicitudEnviada = false;

  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Get reference to the "Users" collection
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

      // Query the "Users" collection to find the document ID of the current user
      QuerySnapshot userQuerySnapshot = await usersCollection
          .where('User', isEqualTo: usuario)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        // Get the document reference for the current user
        DocumentReference currentUserDoc =
            userQuerySnapshot.docs.first.reference;

        // Get reference to the "Requests" subcollection under the current user's document
        CollectionReference requestsCollection =
            currentUserDoc.collection('Requests');

        String actual = await obtenerUsuarioActual();
        QuerySnapshot querySnapshotrequest = await requestsCollection
            .where('user_request', isEqualTo: actual)
            .get();

        if (querySnapshotrequest.docs.isNotEmpty) {
          return false;
        }
        if (actual == usuario) {
          return false;
        }
        // Add a document with the username to the "Requests" subcollection
        await requestsCollection.add({
          'user_request': actual,
          'timestamp': FieldValue.serverTimestamp(),
          // Add any other relevant data you want to store in the request document
        });

        // Set solicitudEnviada to true if the request is successfully added
        solicitudEnviada = true;
      }
    }
  } catch (e) {
    print('Error sending request: $e');
  }

  return solicitudEnviada;
}

Future<List<String>> obtenerSolicitudes() async {
  List<String> solicitudes = [];
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Requests')
          .orderBy('timestamp', descending: false)
          .get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        String userRequest = document['user_request'] as String;

        solicitudes.add(userRequest);
      }
    }
  } catch (e) {
    print('Error fetching requests: $e');
  }
  return solicitudes;
}
