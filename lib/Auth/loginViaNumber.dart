import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../Constants/styleConsts.dart';
import 'otpPage.dart';
class LoginVIaNumber extends StatefulWidget {
  const LoginVIaNumber({super.key});

  @override
  State<LoginVIaNumber> createState() => _LoginVIaNumberState();
}

class _LoginVIaNumberState extends State<LoginVIaNumber> {
  bool isLoading = false;
  final TextEditingController _phoneController = TextEditingController();
  String _verificationId = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Via Number"),
        centerTitle: true,
        backgroundColor: kThemeColor,
      ),
      body: isLoading == true ? Center(
          child: LoadingAnimationWidget.discreteCircle(
            color:kThemeColor,
            size: 60,
            secondRingColor: appBarColor,
            thirdRingColor: const Color(0xFFD9D9D9),
          )) : ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 30.0),
            child:Row(
              children: [
                SizedBox(
                  width: 70,
                  child: TextFormField(
                    initialValue: '+977',
                    enabled: false,
                    decoration: kFormFieldDecoration.copyWith(
                      labelText: '',
                      hintText: '+977',
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Add some space between the fields
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _phoneController,
                    decoration: kFormFieldDecoration.copyWith(
                        labelText: "Phone Number"),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 25.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  setState(() {
                    isLoading = true;
                  });
                  _sendOTP();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text("Send OTP",
                    style:
                    TextStyle(color: Colors.black, fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _sendOTP() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String phoneNumber = '+977${_phoneController.text.trim()}';
    log('Sending OTP to $phoneNumber');

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          log('Phone number automatically verified and user signed in: ${auth.currentUser}');
          setState(() {
            isLoading = false;
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          log('Verification failed with error code: ${e.code}, message: ${e.message}');
          setState(() {
            isLoading = false;
          });
          if (e.code == 'invalid-phone-number') {
            log('The provided phone number is not valid.');
          } else if (e.code == 'quota-exceeded') {
            log('SMS quota for the project has been exceeded.');
          } else if (e.code == 'missing-client-identifier') {
            log('This request is missing a valid app identifier.');
          } else if (e.code == 'invalid-play-integrity-token') {
            log('Invalid Play Integrity token; app not recognized by Play Store.');
          } else if (e.code == 'internal-error') {
            log('An internal error occurred.');
          } else {
            log('Unknown error: ${e.code}');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          log('Code sent to $phoneNumber');
          setState(() {
            isLoading=false;
            _verificationId = verificationId;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OTPPage(verificationId: verificationId),
            ),
          );
          Fluttertoast.showToast(
              msg: 'OTP sent to the phone number: ${_phoneController.text.trim()}',
              backgroundColor: appBarColor,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP_RIGHT,
              textColor: Colors.white,
              fontSize: 16.0);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log('Auto retrieval timeout with verification ID: $verificationId');
          setState(() {
            isLoading = false;
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      log('Error during phone number verification: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
}
