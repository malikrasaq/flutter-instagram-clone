import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
            print(cred.user!.uid);

           String photoUrl = await StorageMethods().uploadImageToStorage('displayPics', file, false);
        await _firestore.collection('user').doc(cred.user!.uid).set({
          'username': username,
          'uid': cred.user!.uid,
          'email': email,
          'bio': bio,
          'followers': [],
          'following': [],
          'photoUrl': photoUrl,
        });
        
        res = "sucess";
      }
    } on FirebaseAuthException catch(e) {
      if(e.code == 'invalid-email') {
        res = 'Enter a valid email';
      } else if(e.code == 'weak password') {
        res = 'Your password must be more than 8 characters';
      }
    }
     catch (e) {
      res = e.toString();
    }
    return res;
  }
}
