import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Constants/styleConsts.dart';
import 'Auth/loginPage.dart';
import 'homePage.dart';  // Import the home page

class SplashScreen extends StatefulWidget {
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
    User? user = FirebaseAuth.instance.currentUser;
    await Future.delayed(Duration(seconds: 2));

    if (user != null && user.emailVerified) {
      log("User is verified");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      log("User is not verified");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Color(0xFF283E50),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/room.png'),
              SizedBox(height: 20.0),
              LoadingAnimationWidget.discreteCircle(
                color: kThemeColor,
                size: 60,
                secondRingColor: appBarColor,
                thirdRingColor: Color(0xFFD9D9D9),
              ),
              SizedBox(height: 20.0),
              Text("Loading...", style: TextStyle(color: Color(0xFFFEEAD4), fontFamily: "font"))
            ],
          ),
        ],
      ),
    );
  }
}