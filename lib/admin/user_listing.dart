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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey.shade200,
        title: Text(
          "Users",
          style: TextStyle(
            color: kThemeColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
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
              return const Center(child: Text('No users found.', style: TextStyle(fontSize: 18)));
            }

            final users = snapshot.data!.docs;

            final adminUsers = users.where((user) => user['userType'] == 'admin').toList();
            final sellerUsers = users.where((user) => user['userType'] == 'Seller').toList();
            final buyerUsers = users.where((user) => user['userType'] == 'Buyer').toList();

            return ListView(
              children: [
                _buildUserSection('Admin', adminUsers),
                _buildUserSection('Seller', sellerUsers),
                _buildUserSection('Buyer', buyerUsers),
              ],
            );
          },
        ),
      ),
    );
  }

  // Build user sections for Admin, Seller, Buyer with better design
  Widget _buildUserSection(String title, List<QueryDocumentSnapshot> users) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with styled text
          Row(
            children: [
              Icon(Icons.group, color: kThemeColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kThemeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...users.map((user) {
            return _buildUserCard(user);
          }).toList(),
        ],
      ),
    );
  }

  // Create a card for each user with proper styling
  Widget _buildUserCard(QueryDocumentSnapshot user) {
    final email = user['email'] ?? 'No email';
    final username = user['username'] ?? 'No username';
    final phoneNumber = user['contactNumber'] ?? 'No phone number';
    final photoUrl = user['photoUrl'] ?? "https://example.com/dummy_photo.png"; // Replace with a dummy photo URL

    // Determine card color based on userType
    Color cardColor;
    if (user['userType'] == 'admin') {
      cardColor = Colors.blue.shade100; // Light blue for Admin
    } else if (user['userType'] == 'Seller') {
      cardColor = Colors.green.shade100; // Light green for Seller
    } else {
      cardColor = Colors.orange.shade100; // Light orange for Buyer
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      child: Container(
        color: cardColor,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // User Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 60, color: Colors.grey),
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
                          overflow: TextOverflow.ellipsis,
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
  }
}