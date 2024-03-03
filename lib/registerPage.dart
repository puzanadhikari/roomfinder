import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:meroapp/loginPage.dart';

import 'Constants/styleConsts.dart';
import 'firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isLoading = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _obscureText = true;
  bool _obscureText1 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.discreteCircle(
              color:kThemeColor,
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
                      padding: const EdgeInsets.only(left: 20.0, top: 50.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                            },
                            icon: Icon(Icons.arrow_back_ios),
                            iconSize: 30,
                            color: Colors.white,
                          ),
                          kHeightSmall,
                          Text("Register", style: kTextStyleWhite),
                          kHeightSmall,
                          Text("Create your account",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration:
                              KFormFieldDecoration.copyWith(labelText: "Name"),
                        ),
                        kHeightSmall,
                        kHeightSmall,
                        TextFormField(
                          controller: emailController,
                          decoration:
                              KFormFieldDecoration.copyWith(labelText: "Email"),
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
                        kHeightSmall,
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: _obscureText1,
                          decoration: KFormFieldDecoration.copyWith(
                              labelText: "Confirm Password",
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText1 = !_obscureText1;
                                  });
                                },
                                child: Icon(
                                  _obscureText1
                                      ? Icons.visibility
                                      : Icons.visibility_outlined,
                                  color: kThemeColor,
                                ),
                              )),
                        ),
                        kHeightMedium,
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              if (passwordController.text !=
                                  confirmPasswordController.text) {
                                Fluttertoast.showToast(
                                  msg:
                                      "Password and Confirm Password do not match",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                );
                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                await _auth.register(
                                  context,
                                  nameController.text,
                                  emailController.text,
                                  passwordController.text,
                                );
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            child: Text(
                              "Register",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: appBarColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ),
                        kHeightMedium,
                        kHeightMedium,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "I have an account?",
                              style: TextStyle(fontSize: 15),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()));
                                },
                                child: Text(
                                  "Login",
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
    );
  }
}
