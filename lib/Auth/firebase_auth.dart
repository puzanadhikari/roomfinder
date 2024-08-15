import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/dashBoard.dart';
import 'package:meroapp/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin/homePage.dart';
import '../model/onSaleModel.dart';
import '../seller/homepage.dart';
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

  Future<User?> register(BuildContext context, String name, String email,
      String password, String userType) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      await addUserData(email, name, password, userType);
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

  Future addUserData(String email, String name, String password,
      String userType) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;

        Map<String, dynamic> userData = {
          "email": email,
          "username": name,
          "password": password,
          "userType": userType,
        };

        DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
        await userRef.set(userData);
      }
    } catch (e) {
      log('Error storing user data: $e'); // Add this line to print the error
    }
  }

  Future<User?> signInWithEmailAndPassword(BuildContext context, String email,
      String password) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);


      if (credential.user != null && credential.user!.emailVerified) {
        String uid = credential.user!.uid; // Get the UID of the logged-in user
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users') // Replace 'users' with your collection name
            .doc(uid)
            .get();
        if (userDoc.exists) {
          String userType = userDoc['userType'];
          if (userType == "Seller") {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SellerHomePage()));
          } else if (userType == "Buyer") {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => AdminHomePage()));
          }
        }
        Fluttertoast.showToast(
            msg: 'Logged in Successful',
            backgroundColor: appBarColor,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_RIGHT,
            textColor: Colors.white,
            fontSize: 16.0);

        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => HomePage()));
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

  Future<void> forgotPassword(BuildContext context, String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Password reset email sent',
          backgroundColor: appBarColor,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      log("Error during password reset: $e");
      Fluttertoast.showToast(
          msg: 'Error sending password reset email',
          backgroundColor: Color(0xff283E50),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> addSellerRoomDetail(
      String name,
      double capacity,
      String description,
      double length,
      double breadth,
      List<String> photo,
      String? panorama,
      double electricity,
      double fohor,
      double lat,
      String locName,
      double lng,
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        Map<String, dynamic> userData = {
          "name": name,
          "capacity": capacity,
          "description": description,
          "length": length,
          "breadth": breadth,
          "photo": photo,
          "panoramaImg": panorama, // Store panorama URL
          "electricity": electricity,
          "active": false,
          "fohor": fohor,
          "lat": lat,
          "lng": lng,
          "locationName": locName,
          "featured": false,
          "userId": uid,
        };

        // Use collection('onSale') to add a new document with a generated ID
        CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('onSale');

        await collectionRef.add(userData); // Add a new document with a generated ID

        prefs.clear();
      }
    } catch (e) {
      log('Error storing user data: $e');
    }
  }

}



