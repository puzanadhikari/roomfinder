import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/loginViaNumber.dart';
import 'package:meroapp/registerPage.dart';

import 'firebase_auth.dart';
import 'homePage.dart';
import 'otpPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: isLoading
            ? Center(
                child: LoadingAnimationWidget.discreteCircle(
                color: kThemeColor,
                size: 60,
                secondRingColor: appBarColor,
                thirdRingColor: Color(0xFFD9D9D9),
              ))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 4,
                      color: kThemeColor,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sign in to your Account",
                                style: kTextStyleWhite),
                            Text("Sign in to your Account",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailController,
                            decoration: KFormFieldDecoration.copyWith(
                                labelText: "Email"),
                          ),
                          kHeightSmall,
                          kHeightSmall,
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            decoration: KFormFieldDecoration.copyWith(
                                labelText: "Password",
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  child: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_outlined,
                                    color: kThemeColor,
                                  ),
                                )),
                          ),
                          kHeightSmall,
                          Align(
                              alignment: Alignment.bottomRight,
                              child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Forgot Password ?",
                                    style: TextStyle(color: appBarColor),
                                  ))),
                          kHeightMedium,
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await _auth.signInWithEmailAndPassword(
                                    context,
                                    emailController.text,
                                    passwordController.text);
                                emailController.clear();
                                passwordController.clear();
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: Text("Login",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18)),
                              style: ElevatedButton.styleFrom(
                                primary: appBarColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                          ),
                          kHeightMedium,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.black,
                                  height: 1.5,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "or login with",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.black,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                          kHeightMedium,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 45,
                                width: 150,
                                child: ElevatedButton(
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/google.svg',
                                          height: 30,
                                        ),
                                        Text("Google",
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: BorderSide(
                                              color: Colors.grey.shade300)),
                                      primary: Colors.white,
                                      elevation: 0,
                                    )),
                              ),
                              SizedBox(
                                height: 45,
                                width: 150,
                                child: ElevatedButton(
                                    onPressed: signInWithFacebook,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/facebook.svg',
                                          height: 30,
                                        ),
                                        Text("Facebook",
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: BorderSide(
                                              color: Colors.grey.shade300)),
                                      primary: Colors.white,
                                      elevation: 0,
                                    )),
                              ),
                            ],
                          ),
                          kHeightSmall,
                          SizedBox(
                            height: 45,
                            width: 180,
                            child: ElevatedButton(
                                onPressed: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LoginVIaNumber()));
                                },
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(Icons.phone,color: Colors.green),
                                    Text("Phone Number",
                                        style:
                                        TextStyle(color: Colors.black)),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10.0),
                                      side: BorderSide(
                                          color: Colors.grey.shade300)),
                                  primary: Colors.white,
                                  elevation: 0,
                                )),
                          ),
                          kHeightMedium,
                          kHeightMedium,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(fontSize: 15),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RegisterPage()));
                                  },
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                        color: appBarColor, fontSize: 15),
                                  ))
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.token);
        final UserCredential firebaseResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = firebaseResult.user;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        // Proceed with your app logic after successful sign-in
        // For example, navigate to a new screen or update UI
      } else {}
    } catch (e) {
      print('Error signing in with Facebook: $e');
    }
  }
}
