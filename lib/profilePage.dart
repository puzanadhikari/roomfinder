import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/splashScreen.dart';
import 'package:meroapp/wishlist.dart';

import 'informationDetail.dart';
import 'orders.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey.shade200,
        title: Text("Profile",
            style: TextStyle(
                color: kThemeColor, fontWeight: FontWeight.bold, fontSize: 25)),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18.0, bottom: 10),
                child: Center(
                    child: CircleAvatar(
                  radius: 70,
                  backgroundColor: kThemeColor,
                  backgroundImage: const NetworkImage(
                      "https://media.licdn.com/dms/image/D5603AQFD6ld3NWc2HQ/profile-displayphoto-shrink_200_200/0/1684164054868?e=2147483647&v=beta&t=cwQoyfhgAl_91URX5FTEXLwLDEHWe1H337EMebpgntQ"),
                )),
              ),
              Text(
                user?.displayName ?? "Guest",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Colors.grey,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                shadowColor: appBarColor.withOpacity(0.5),
                child: ListTile(
                  leading: const Icon(Icons.person_2_outlined),
                  title: const Text('Information'),
                  trailing: Icon(Icons.chevron_right, color: appBarColor),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const InformationDetails()));
                  },
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                shadowColor: appBarColor.withOpacity(0.5),
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text('Orders'),
                  trailing: Icon(Icons.chevron_right, color: appBarColor),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const OrderPage()));
                  },
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                shadowColor: appBarColor.withOpacity(0.5),
                child: ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Wishlist'),
                  trailing: Icon(Icons.chevron_right, color: appBarColor),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const WishlistPage()));
                  },
                ),
              ),
              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(10.0),
              //   ),
              //   shadowColor: appBarColor.withOpacity(0.5),
              //   child: ListTile(
              //     leading: Icon(Icons.credit_card),
              //     title: Text('Payment Methods'),
              //     trailing: Icon(Icons.chevron_right, color: appBarColor),
              //     onTap: () {
              //       // Navigator.push(context, MaterialPageRoute(builder: (context)=>InformationPage()));
              //     },
              //   ),
              // ),
              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(10.0),
              //   ),
              //   shadowColor: appBarColor.withOpacity(0.5),
              //   child: ListTile(
              //     leading: Icon(Icons.settings),
              //     title: Text('Settings'),
              //     trailing: Icon(Icons.chevron_right, color: appBarColor),
              //     onTap: () {
              //       // Navigator.push(context, MaterialPageRoute(builder: (context)=>InformationPage()));
              //     },
              //   ),
              // ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                shadowColor: appBarColor.withOpacity(0.5),
                child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    trailing: Icon(Icons.chevron_right, color: appBarColor),
                    onTap: _signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } catch (e) {
      log("Error signing out: $e");
    }
  }
}
