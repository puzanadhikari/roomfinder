import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meroapp/seller/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Constants/styleConsts.dart';
import 'Auth/loginPage.dart';
import 'admin/homePage.dart';
import 'homePage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;
    await Future.delayed(const Duration(seconds: 2));

    if (user != null && user.emailVerified) {
      log("User is verified");
      String userRole = preferences.getString("user_role")??"";

      if (userRole=="Seller"){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SellerHomePage()),
        );
      }else if(userRole=="admin"){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );

      }else{
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }

    } else {
      log("User is not verified");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kThemeColor,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.7,
            height: MediaQuery.of(context).size.height / 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Room Finder",
                    style: TextStyle(
                      color: kTextColor,
                      fontFamily: "font",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Ultimate Property Finder",
                    style: TextStyle(
                      color: kTextColor,
                      fontFamily: "font",
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}