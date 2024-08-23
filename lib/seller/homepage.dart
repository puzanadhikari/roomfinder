import 'package:flutter/material.dart';
import 'package:meroapp/seller/createRoom.dart';
import 'package:meroapp/seller/enquiries.dart';
import 'package:meroapp/seller/myOpenings.dart';
import 'package:meroapp/seller/seller_profile_page.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    CreateRoom(),         // Page for creating rooms
    MyListingsPage(),     // Page for viewing listings
    EnquiriesPage(),      // Page for enquiries
    SellerProfile(),      // Page for seller's profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],  // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined,weight: 20),
            label: 'Listing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Enquiries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures the label is always shown
      ),
    );
  }
}