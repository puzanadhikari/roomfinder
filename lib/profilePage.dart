import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/splashScreen.dart';

import 'informationDetail.dart';

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
        title: Text("Profile"),
        centerTitle: true,
        backgroundColor: kThemeColor,
        automaticallyImplyLeading: false,
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
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InformationDetails()));
                },
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
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>InformationPage()));
                },
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
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>InformationPage()));
                },
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              shadowColor: appBarColor.withOpacity(0.5),
              child: ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('Payment Methods'),
                trailing: Icon(Icons.chevron_right, color: appBarColor),
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>InformationPage()));
                },
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              shadowColor: appBarColor.withOpacity(0.5),
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                trailing: Icon(Icons.chevron_right, color: appBarColor),
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>InformationPage()));
                },
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
