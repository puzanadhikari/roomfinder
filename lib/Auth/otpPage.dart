import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/homePage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../dashBoard.dart';

class OTPPage extends StatefulWidget {
  final String verificationId;

  OTPPage({required this.verificationId});

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
        title: Text('OTP Verification'),
        backgroundColor: kThemeColor,
      ),
      body: isLoading
          ? Center(
        child: LoadingAnimationWidget.discreteCircle(
          color: kThemeColor,
          size: 60,
          secondRingColor: appBarColor,
          thirdRingColor: Color(0xFFD9D9D9),
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
                print(value);
              },
              onCompleted: (value) {
                print("Completed: $value");
              },
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  _verifyOTP();
                },
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
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
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify OTP')));
      print('Error verifying OTP: $e');
      // Handle error here
    }
  }
}