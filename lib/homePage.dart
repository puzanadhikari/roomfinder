import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/dashBoard.dart';
import 'package:meroapp/profilePage.dart';
import 'package:meroapp/wishlistPage.dart';

import 'cartPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;

  final List<Widget> _pages = [
    DashBoard(),
    CartPage(),
    WishlistPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: appBarColor,
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
        body: _pages[_page],
      ),
    );
  }
}



