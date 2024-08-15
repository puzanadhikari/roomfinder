import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:meroapp/Auth/loginPage.dart';

import '../Constants/styleConsts.dart';
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
  String selectedUserType = "Seller";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: kMTextColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: kMTextColor),
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
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Dera Account",
                style: TextStyle(
                  color: kThemeColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Sign up to post and view properties",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 30),
              _buildTextField(
                controller: nameController,
                label: "Full Name",
                prefixIcon: Icons.person_2_outlined,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: emailController,
                label: "Email Address",
                prefixIcon: Icons.mail_outline_outlined,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: passwordController,
                label: "Password",
                obscureText: _obscureText,
                prefixIcon: Icons.lock_outline,
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Icon(
                    _obscureText
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: confirmPasswordController,
                label: "Confirm Password",
                obscureText: _obscureText1,
                prefixIcon: Icons.lock_outline,
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText1 = !_obscureText1;
                    });
                  },
                  child: Icon(
                    _obscureText1
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildDropdown(),
              SizedBox(height: 30),
              _buildRegisterButton(),
              SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    Text(
                      "By creating an account, you agree with our",
                      style: TextStyle(fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Terms & Conditions",
                        style: TextStyle(
                          color: kThemeColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kThemeColor),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedUserType,
      items: ["Seller", "Buyer"].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedUserType = newValue!;
        });
      },
      decoration: InputDecoration(
        labelText: "Select User Type",
        labelStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kThemeColor),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          if (passwordController.text !=
              confirmPasswordController.text) {
            Fluttertoast.showToast(
              msg: "Password and Confirm Password do not match",
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
              selectedUserType,
            );
            setState(() {
              isLoading = false;
            });
          }
        },
        child: Text(
          "Create",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          primary: kThemeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}