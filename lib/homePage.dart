import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/dashBoard.dart';
import 'package:meroapp/profilePage.dart';
import 'package:meroapp/provider/pageProvider.dart';
import 'package:meroapp/splashScreen.dart';
import 'package:meroapp/wishlist.dart';
import 'package:provider/provider.dart';
import 'listing_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  double _latitude = 0.0;
  double _longitude=0.0;
  String? _locationName;

  Future<void> _getLocation() async {
    Location location = Location();
    LocationData? currentLocation;

    try {
      currentLocation = await location.getLocation();
      setState(() {
        _latitude = currentLocation!.latitude!;
        _longitude = currentLocation.longitude!;
        _locationName = "Current Location";
      });
    } catch (e) {
      log("Error getting location: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  List<Widget> _buildPages() {
    return [
      if (_latitude != null && _longitude != null)
        DashBoard(_latitude, _longitude),
       Listing(_latitude, _longitude),
      const WishlistPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pageProvider = Provider.of<PageProvider>(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageProvider.page,
          onTap: (index) {
            setState(() {
              if(index==1){
                pageProvider.setChoice("From Main");
              }
              pageProvider.setPage(index);
            });
          },
          selectedItemColor: kThemeColor,
          unselectedItemColor: Color(0xAA111111),
          showUnselectedLabels: true,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 10,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined,weight: 20),
              label: 'Listing',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildPages()[pageProvider.page],
        ),
      ),
    );
  }
  Future<bool> _onBackPressed() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Do you want to exit the app?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: const Icon(
          Icons.exit_to_app,
          size: 50,
          color: Colors.redAccent,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
              );
            },
            child: const Text(
              'Yes',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }
}
