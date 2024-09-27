import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/seller/createRoom.dart';
import 'package:meroapp/seller/enquiries.dart';

import '../Constants/styleConsts.dart';
import '../splashScreen.dart';
class SellerProfile extends StatefulWidget {
  final double lat, lng;
  const SellerProfile(this.lat, this.lng, {super.key});

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
        title: Text(
          "Profile",
          style: TextStyle(
              color: kThemeColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
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
              // Profile Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            user?.photoURL ??
                                "https://media.licdn.com/dms/image/D5603AQFD6ld3NWc2HQ/profile-displayphoto-shrink_200_200/0/1684164054868?e=2147483647&v=beta&t=cwQoyfhgAl_91URX5FTEXLwLDEHWe1H337EMebpgntQ",
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: kThemeColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName?.toUpperCase() ?? "Guest",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? "No email",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Colors.grey,
              ),
              // Information Card
              _buildProfileCard(
                icon: Icons.person_2_outlined,
                title: 'Information',
                iconColor: kThemeColor,
                textColor: kThemeColor,
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const InformationDetails(),
                  //   ),
                  // );
                },
              ),
              // Orders Card
              _buildProfileCard(
                icon: Icons.room_preferences_sharp,
                title: 'Add Property',
                iconColor: kThemeColor,
                textColor: kThemeColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateRoom(),
                    ),
                  );
                },
              ),
              // Wishlist Card
              _buildProfileCard(
                icon: Icons.query_stats,
                title: 'Enquiries',
                iconColor: kThemeColor,
                textColor: kThemeColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnquiriesPage(widget.lat, widget.lng),
                    ),
                  );
                },
              ),
              // Logout Card
              _buildProfileCard(
                icon: Icons.logout,
                title: 'Logout',
                onTap: _signOut,
                iconColor: kThemeColor,
                textColor: kThemeColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
    Color textColor = Colors.black87,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: iconColor),
        onTap: onTap,
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