import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginPage.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendVerificationEmail(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email sent!'),
          ),
        );
      } else {
        print('User not signed in.');
      }
    } catch (e) {
      print('Error sending verification email: $e');
    }
  }

  Future<User?> register(
      BuildContext context, String name, String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      await addUserData(email, name, password);
      Fluttertoast.showToast(
          msg: 'Register successfully',
          backgroundColor: appBarColor,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          textColor: Colors.white,
          fontSize: 16.0);
      sendVerificationEmail(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  Future addUserData(String email,String name,String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;

        Map<String, dynamic> userData = {
          "email": email,
          "username": name,
          "password": password,
        };

        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        await userRef.set(userData);
      }} catch (e) {
      log('Error storing user data: $e'); // Add this line to print the error
    }
  }

  Future<User?> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null && credential.user!.emailVerified) {
        Fluttertoast.showToast(
            msg: 'Logged in Successful',
            backgroundColor: appBarColor,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_RIGHT,
            textColor: Colors.white,
            fontSize: 16.0);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        return credential.user;
      } else {
        print('Email not verified. Please check your email for verification.');
        FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Email not verified. Please check your email for verification.'),
          ),
        );
      }
    } catch (e) {
      log("Error during login: $e");
      Fluttertoast.showToast(
          msg: 'Login Failed',
          backgroundColor: Color(0xff283E50),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    return null;
  }
}
