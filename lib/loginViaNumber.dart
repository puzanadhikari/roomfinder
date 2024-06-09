import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Constants/styleConsts.dart';
import 'otpPage.dart';
class LoginVIaNumber extends StatefulWidget {
  const LoginVIaNumber({super.key});

  @override
  State<LoginVIaNumber> createState() => _LoginVIaNumberState();
}

class _LoginVIaNumberState extends State<LoginVIaNumber> {
  final TextEditingController _phoneController = TextEditingController();
  String _verificationId = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Via Number"),
        centerTitle: true,
        backgroundColor: kThemeColor,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 30.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: _phoneController,
              decoration: KFormFieldDecoration.copyWith(
                  labelText: "Phone Number"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 25.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: _sendOTP,
                child: Text("Send OTP",
                    style:
                    TextStyle(color: Colors.black, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  primary: appBarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _sendOTP() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String phoneNumber = '+977' + _phoneController.text.trim();
    print('Sending OTP to $phoneNumber');

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          print('Phone number automatically verified and user signed in: ${auth.currentUser}');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed with error code: ${e.code}, message: ${e.message}');
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          } else if (e.code == 'quota-exceeded') {
            print('SMS quota for the project has been exceeded.');
          } else if (e.code == 'missing-client-identifier') {
            print('This request is missing a valid app identifier.');
          } else if (e.code == 'invalid-play-integrity-token') {
            print('Invalid Play Integrity token; app not recognized by Play Store.');
          } else if (e.code == 'internal-error') {
            print('An internal error occurred.');
          } else {
            print('Unknown error: ${e.code}');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          print('Code sent to $phoneNumber');
          setState(() {
            _verificationId = verificationId;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPPage(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto retrieval timeout with verification ID: $verificationId');
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      print('Error during phone number verification: $e');
    }
  }
}
