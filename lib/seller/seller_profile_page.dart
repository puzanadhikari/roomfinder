import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Constants/styleConsts.dart';
import '../splashScreen.dart';
class SellerProfile extends StatefulWidget {
  const SellerProfile({super.key});

  @override
  State<SellerProfile> createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile> {
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18.0, bottom: 10),
              child: Center(
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: kThemeColor,
                    backgroundImage: NetworkImage(
                        "https://media.licdn.com/dms/image/D5603AQFD6ld3NWc2HQ/profile-displayphoto-shrink_200_200/0/1684164054868?e=2147483647&v=beta&t=cwQoyfhgAl_91URX5FTEXLwLDEHWe1H337EMebpgntQ"),
                  )),
            ),
            Text(
              user?.displayName ?? "Guest",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Divider(
              color: Colors.grey,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              shadowColor: appBarColor.withOpacity(0.5),
              child: ListTile(
                leading: Icon(Icons.person_2_outlined),
                title: Text('Information'),
                trailing: Icon(Icons.chevron_right, color: appBarColor),
                onTap: () {},
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              shadowColor: appBarColor.withOpacity(0.5),
              child: ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('Orders'),
                trailing: Icon(Icons.chevron_right, color: appBarColor),
                onTap: () {},
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              shadowColor: appBarColor.withOpacity(0.5),
              child: ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Wishlist'),
                trailing: Icon(Icons.chevron_right, color: appBarColor),
                onTap: () {},
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              shadowColor: appBarColor.withOpacity(0.5),
              child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  trailing: Icon(Icons.chevron_right, color: appBarColor),
                  onTap: _signOut),
            ),
          ],
        ),
      ),
    );
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}