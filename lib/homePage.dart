import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/dashBoard.dart';
import 'package:meroapp/profilePage.dart';
import 'package:meroapp/splashScreen.dart';
import 'package:meroapp/wishlistPage.dart';

import 'cartPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;
  double? _latitude, _longitude;
  String?  _locationName;
  Future<void> _getLocation() async {
    Location location = Location();
    LocationData? currentLocation;

    try {
      currentLocation = await location.getLocation();
      setState(() {
        _latitude = currentLocation!.latitude;
        _longitude = currentLocation!.longitude;
        _locationName = "Current Location"; // You can also use reverse geocoding to get the location name
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocation();
  }
  List<Widget> _buildPages() {
    return [
      if (_latitude != null && _longitude != null)
        DashBoard(_latitude!, _longitude!),
      CartPage(),
      WishlistPage(),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: kThemeColor,
          color:kThemeColor,
          height: 50,
          animationDuration: const Duration(milliseconds: 300),
          items: const <Widget>[
            Icon(Icons.home, size: 26, color: Colors.white),
            Icon(Icons.shopping_cart, size: 26, color: Colors.white),
            Icon(Icons.favorite_outlined, size: 26, color: Colors.white),
            Icon(Icons.person, size: 26, color: Colors.white),
          ],
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
        ),
        body:_buildPages()[_page],
      ),
    );
  }
  Future<bool> _onBackPressed() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No',style: TextStyle(color: Colors.red),),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SplashScreen()),
              );
            },
            child: Text('Yes',style: TextStyle(color: Colors.green),),
          ),
        ],
      ),
    ) ??
        false;
  }
}



