import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/homePage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPPage extends StatefulWidget {
  final String verificationId;

  const OTPPage({super.key, required this.verificationId});

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  bool isLoading = false;
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: kThemeColor,
      ),
      body: isLoading
          ? Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          color: kThemeColor,
          size: 60,
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 30.0),
        child: Column(
          children: [
            PinCodeTextField(
              appContext: context,
              length: 6,
              keyboardType: TextInputType.number,
              controller: _otpController,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
              onChanged: (value) {
                log(value);
              },
              onCompleted: (value) {
                log("Completed: $value");
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  _verifyOTP();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyOTP() async {
    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text,
      );
      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      setState(() {
        isLoading = false;
      });
      // OTP verification successful, navigate to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Failed to verify OTP",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red, // Choose a color that fits your theme
        textColor: Colors.white,
        fontSize: 16.0,
      );
      log('Error verifying OTP: $e');
      // Handle error here
    }
  }
}