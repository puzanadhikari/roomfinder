import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Constants/styleConsts.dart'; // Assuming constants are defined

class UserListing extends StatefulWidget {
  const UserListing({super.key});

  @override
  State<UserListing> createState() => _UserListingState();
}

class _UserListingState extends State<UserListing> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Avatar, Title, and Notification Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: kThemeColor,
                  backgroundImage: const NetworkImage(
                      "https://media.licdn.com/dms/image/D5603AQFD6ld3NWc2HQ/profile-displayphoto-shrink_200_200/0/1684164054868?e=2147483647&v=beta&t=cwQoyfhgAl_91URX5FTEXLwLDEHWe1H337EMebpgntQ"),
                ),
                Text("Users",
                    style: TextStyle(
                        color: kThemeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
                IconButton(
                  icon: Icon(
                    Icons.notifications_none_outlined,
                    color: kThemeColor,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFD9D6D6), height: 2, thickness: 1),

            // List of Users (Admins, Sellers, Buyers)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  final users = snapshot.data!.docs;

                  final adminUsers = users.where((user) => user['userType'] == 'admin').toList();
                  final sellerUsers = users.where((user) => user['userType'] == 'Seller').toList();
                  final buyerUsers = users.where((user) => user['userType'] == 'Buyer').toList();

                  return ListView(
                    children: [
                      _buildUserSection('Admin', adminUsers),
                      const SizedBox(height: 20),
                      _buildUserSection('Seller', sellerUsers),
                      const SizedBox(height: 20),
                      _buildUserSection('Buyer', buyerUsers),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build user sections for Admin, Seller, Buyer with better design
  Widget _buildUserSection(String title, List<QueryDocumentSnapshot> users) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kThemeColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with styled text
          Row(
            children: [
              Icon(Icons.person_outline, color: kThemeColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kThemeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...users.map((user) {
            final email = user['email'] ?? 'No email';
            final username = user['username'] ?? 'No username';
            final phoneNumber = user['contactNumber'] ?? 'No phone number';
            const photoUrl = "https://media.licdn.com/dms/image/D5603AQFD6ld3NWc2HQ/profile-displayphoto-shrink_200_200/0/1684164054868?e=2147483647&v=beta&t=cwQoyfhgAl_91URX5FTEXLwLDEHWe1H337EMebpgntQ";

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // User Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade200,
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.email_outlined, color: Colors.grey.shade600, size: 16),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  email,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, color: Colors.grey.shade600, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                phoneNumber,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}