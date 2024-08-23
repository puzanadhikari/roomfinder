import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/provider/pageProvider.dart';
import 'package:meroapp/seller/seller_profile_page.dart';
import 'package:meroapp/splashScreen.dart';
import 'package:provider/provider.dart';
import 'createRoom.dart';
import 'enquiries.dart';
import 'myOpenings.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({Key? key}) : super(key: key);

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  double _latitude = 0.0;
  double _longitude = 0.0;
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
      const CreateRoom(),
      MyListingsPage(_latitude, _longitude),
      EnquiriesPage(),
      const SellerProfile(),
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
              if (index == 1) {
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
              icon: Icon(Icons.list_alt_outlined, weight: 20),
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
                    MaterialPageRoute(
                        builder: (context) => const SplashScreen()),
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
