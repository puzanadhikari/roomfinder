import 'package:flutter/material.dart';
import 'package:meroapp/Constants/styleConsts.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: (
        Text("Login Page")
        ),
      ),
    );
  }
}
