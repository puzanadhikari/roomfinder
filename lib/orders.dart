import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'model/onSaleModel.dart';

class Room {
  final String uid;
  final String name;
  final int capacity;
  final String description;
  final double length;
  final double breadth;
  final List<String> photo;
  final String panoramaImg;
  final int electricity;
  final int fohor;
  final double lat;
  final double lng;
  final bool active;
  final bool featured;
  final String locationName;
  final Map<String, dynamic> status;

  Room({
    required this.uid,
    required this.name,
    required this.capacity,
    required this.description,
    required this.length,
    required this.breadth,
    required this.photo,
    required this.panoramaImg,
    required this.electricity,
    required this.fohor,
    required this.lat,
    required this.lng,
    required this.active,
    required this.featured,
    required this.locationName,
    required this.status,
  });

  // Add this method to convert a map to a Room object
  factory Room.fromMap(Map<String, dynamic> data, String documentId) {
    return Room(
      uid: documentId,
      name: data['name'] ?? '',
      capacity: data['capacity'] ?? 0,
      description: data['description'] ?? '',
      length: data['length'] ?? 0.0,
      breadth: data['breadth'] ?? 0.0,
      photo: List<String>.from(data['photo'] ?? []),
      panoramaImg: data['panoramaImg'] ?? '',
      electricity: data['electricity'] ?? 0,
      fohor: data['fohor'] ?? 0,
      lat: data['lat'] ?? 0.0,
      lng: data['lng'] ?? 0.0,
      active: data['active'] ?? false,
      featured: data['featured'] ?? false,
      locationName: data['locationName'] ?? '',
      status: data['status'] ?? {},
    );
  }
}
Future<Map<String, dynamic>?> fetchUserData() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid) // Access the current user's document
        .get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>; // Return the data as a map
    } else {
      return null; // Document does not exist
    }
  } catch (e) {
    print("Error fetching user data: $e");
    return null; // Handle the error as needed
  }
}


class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Future<Map<String, dynamic>?> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>; // Return the data as a map
      } else {
        return null; // Document does not exist
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null; // Handle the error as needed
    }
  }

  Future<Map<String, dynamic>> fetchRoomStatus(String roomId) async {
    try {
      DocumentSnapshot roomDoc = await FirebaseFirestore.instance
          .collection('onSale')
          .doc(roomId)
          .get();

      if (roomDoc.exists) {
        return roomDoc.data() as Map<String, dynamic>;
      } else {
        return {'status': 'Unknown'}; // Handle case where room does not exist
      }
    } catch (e) {
      print("Error fetching room status: $e");
      return {'status': 'Error'}; // Handle the error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Orders")),
      body: FutureBuilder(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!['rooms'].isEmpty) {
            return Center(child: Text('No rooms found.'));
          }

          final rooms = snapshot.data!['rooms'];
          final userEmail = snapshot.data!['email'];

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final roomId = room['roomId'];

              return FutureBuilder(
                future: fetchRoomStatus(roomId),
                builder: (context, roomSnapshot) {
                  if (roomSnapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  } else if (roomSnapshot.hasError) {
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(child: Text('Error fetching status')),
                      ),
                    );
                  } else if (!roomSnapshot.hasData) {
                    return Container(); // Handle case where no data
                  }

                  final roomStatus = roomSnapshot.data!;

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            room['photo'][0] ?? '',
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            room['name'] ?? '',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            room['locationName'] ?? '',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Email: $userEmail',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Status: ${roomStatus['status']['statusDisplay'] ?? 'Unknown'}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            room['description'] ?? '',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


