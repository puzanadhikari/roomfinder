import 'package:flutter/material.dart';

import '../Constants/styleConsts.dart';
import 'firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  TextEditingController _forgotPassword = TextEditingController();

  void _sendPasswordResetEmail() async {
    String email = _forgotPassword.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }
    try {
      _auth.forgotPassword(context, email);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
        centerTitle: true,
        backgroundColor: kThemeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: MediaQuery.of(context).size.height / 4,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            shadowColor: Colors.black,
            elevation: 16.0,
            child: ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Forgot Password ?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _forgotPassword,
                    decoration: KFormFieldDecoration.copyWith(
                        labelText: "Recovery Email"),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _sendPasswordResetEmail,
                      child: Text("Send",
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        primary: appBarColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
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
