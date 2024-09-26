import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin/homePage.dart';
import '../seller/homepage.dart';
import 'loginPage.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendVerificationEmail(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.sendEmailVerification();

        Fluttertoast.showToast(
            msg: 'Verification email sent!!',
            backgroundColor: appBarColor,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_RIGHT,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        log('User not signed in.');
      }
    } catch (e) {
      log('Error sending verification email: $e');
    }
  }

  Future<User?> register(BuildContext context, String name, String email,
      String password,String contactNumber, String userType) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      await addUserData(email, name, password,contactNumber, userType);
      Fluttertoast.showToast(
          msg: 'Register successfully',
          backgroundColor: appBarColor,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          textColor: Colors.white,
          fontSize: 16.0);
      sendVerificationEmail(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  Future addUserData(
      String email, String name, String password, String contactNumber, String userType) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;

        Map<String, dynamic> userData = {
          "email": email,
          "username": name,
          "password": password,
          "contactNumber": contactNumber,
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

  Future<User?> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
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
          preferences.setString("user_role", userType);
          if (userType == "Seller") {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const SellerHomePage()));
          } else if (userType == "Buyer") {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const AdminHomePage()));
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
        log('Email not verified. Please check your email for verification.');
        FirebaseAuth.instance.signOut();
        Fluttertoast.showToast(
          msg: "Email not verified. Please check your email for verification.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 16.0,
        );

      }
    } catch (e) {
      log("Error during login: $e");
      Fluttertoast.showToast(
          msg: 'Login Failed',
          backgroundColor: const Color(0xff283E50),
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
          backgroundColor: const Color(0xff283E50),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> addSellerRoomDetail(
      String name,
      double price,
      double capacity,
      String description,
      double roomLength,
      double roomBreath,
      double hallLength,
      double hallBreadth,
      double kitchenLength,
      double kitchenbreadth,
      List<String> photo,
      String? panorama,
      double electricity,
      double fohor,
      double lat,
      String locName,
      double lng,
      String sellerName,
      String sellerEmail,
      String sellerPhone,
      double water,
      List<String> facilities
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        Map<String, dynamic> userData = {
          "name": name,
          "price":price,
          "capacity": capacity,
          "description": description,
          "roomLength": roomLength,
          "roomBreadth": roomBreath,
          "hallLength": hallLength,
          "hallBreadth": hallBreadth,
          "kitchenLength": kitchenLength,
          "kitchenBreadth": kitchenbreadth,
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
          "statusByAdmin":"Pending",
          "water":water,
          "facilities": facilities,
          "detail":{
            "sellerName":sellerName,
            "sellerEmail":sellerEmail,
            "sellerPhone":sellerPhone
          }
        };

        CollectionReference collectionRef = FirebaseFirestore.instance.collection('onSale');

        await collectionRef.add(userData);
        await prefs.clear();

        Fluttertoast.showToast(
          msg: "Room details added successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: "User is not authenticated. Please log in.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      log('Error storing user data: $e');
      Fluttertoast.showToast(
        msg: "Failed to add room details. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
