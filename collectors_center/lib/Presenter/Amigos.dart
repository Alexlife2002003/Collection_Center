import 'package:collectors_center/View/Amigos/verSolicitudes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> eliminarSolicitud(String usuario) async {
  bool eliminada = false;

  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDocument =
          FirebaseFirestore.instance.collection('Users').doc(user.uid);

      CollectionReference requestsCollection =
          userDocument.collection('Requests');

      QuerySnapshot querySnapshot = await requestsCollection
          .where('user_request', isEqualTo: usuario)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        await requestsCollection.doc(querySnapshot.docs.first.id).delete();
        eliminada = true;
      }
    } else {
      eliminada = false;
    }
    return eliminada;
  } catch (e) {
    return eliminada;
  }
}

Future<bool> aceptarSolicitud(String usuario) async {
  bool aceptado = false;

  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

      QuerySnapshot userQuerySnapshot = await usersCollection
          .where('User', isEqualTo: usuario)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentReference currentUserDoc =
            userQuerySnapshot.docs.first.reference;

        CollectionReference requestsCollection =
            currentUserDoc.collection('Accepted');

        String actual = await obtenerUsuarioActual();
        QuerySnapshot querySnapshotrequest = await requestsCollection
            .where('user_accepted', isEqualTo: actual)
            .get();

        if (querySnapshotrequest.docs.isNotEmpty) {
          return false;
        }
        if (actual == usuario) {
          return false;
        }

        await requestsCollection.add({
          'user_accepted': actual,
          'timestamp': FieldValue.serverTimestamp(),
        });

        aceptado = true;
        aceptado = await eliminarSolicitud(usuario);
      }
    }
  } catch (e) {
    print('Error sending request: $e');
  }

  return aceptado;
}

Future<bool> rechazarSolicitud(String usuario) async {
  bool rechazado = false;
  rechazado = await eliminarSolicitud(usuario);
  return rechazado;
}

Future<String> obtenerUsuarioActual() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> userData = documentSnapshot.data()!;
      String username = userData['User'];
      return username;
    } else {
      return "";
    }
  } else {
    return "";
  }
}

Future<int> sendSolicitud(String usuario) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');

      QuerySnapshot userQuerySnapshot = await usersCollection
          .where('User', isEqualTo: usuario)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentReference currentUserDoc =
            userQuerySnapshot.docs.first.reference;

        CollectionReference requestsCollection =
            currentUserDoc.collection('Requests');

        String actual = await obtenerUsuarioActual();
        QuerySnapshot querySnapshotrequest = await requestsCollection
            .where('user_request', isEqualTo: actual)
            .get();

        QuerySnapshot myuserQuerySnapshot = await usersCollection
            .where('User', isEqualTo: actual)
            .limit(1)
            .get();

        if (myuserQuerySnapshot.docs.isNotEmpty) {
          DocumentReference myUserDoc =
              myuserQuerySnapshot.docs.first.reference;

          CollectionReference myacceptedCollection =
              myUserDoc.collection("Accepted");

          QuerySnapshot querySnapshotaccepted = await myacceptedCollection
              .where("user_accepted", isEqualTo: usuario)
              .get();

          if (querySnapshotaccepted.docs.isNotEmpty) {
            //ya es tu amigo
            return 0;
          }
        }

        if (querySnapshotrequest.docs.isNotEmpty) {
          //ya enviaste solicitud
          return 1;
        }

        if (actual == usuario) {
          //no te puedes enviar solicitud tu mismo
          return 2;
        }

        await requestsCollection.add({
          'user_request': actual,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      //usuario no existe
      return 4;
    }
    //solicitud enviada
    return 10;
  } catch (e) {
    print('Error sending request: $e');
    //error al enviar la solicitud
    return 3;
  }
  //error al enviar la solicitud
  return 3;
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

Future<List<String>> obtenerAceptados() async {
  List<String> solicitudes = [];
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Accepted')
          .orderBy('timestamp', descending: false)
          .get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        String userRequest = document['user_accepted'] as String;

        solicitudes.add(userRequest);
        print("User $userRequest");
      }
    }
  } catch (e) {
    print('Error fetching requests: $e');
  }
  return solicitudes;
}
