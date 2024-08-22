import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Constants/styleConsts.dart';

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
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  } catch (e) {
    log("Error fetching user data: $e");
    return null;
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
        return userDoc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      log("Error fetching user data: $e");
      return null;
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
        return {'status': 'Unknown'};
      }
    } catch (e) {
      log("Error fetching room status: $e");
      return {'status': 'Error'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey.shade200,
        iconTheme: IconThemeData(
          color: kThemeColor,
        ),
        title: Text(
          "Orders",
          style: TextStyle(
            color: kThemeColor,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, left: 18.0, right: 18.0),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: kThemeColor),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!['rooms'].isEmpty) {
              return const Center(
                child: Text('No rooms found.'),
              );
            }

            final rooms = snapshot.data!['rooms'];
            final userEmail = snapshot.data!['email'];

            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final roomId = room['roomId'];

                  return FutureBuilder<Map<String, dynamic>>(
                    future: fetchRoomStatus(roomId),
                    builder: (context, roomSnapshot) {
                      if (roomSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child:
                                  CircularProgressIndicator(color: kThemeColor),
                            ),
                          ),
                        );
                      } else if (roomSnapshot.hasError) {
                        return const Card(
                          elevation: 4,
                          margin: EdgeInsets.all(8.0),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text('Error fetching status'),
                            ),
                          ),
                        );
                      } else if (!roomSnapshot.hasData) {
                        return Container();
                      }

                      final roomStatus = roomSnapshot.data!;

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade200],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(16.0),
                                  ),
                                  child: Image.network(
                                    room['photo'][0] ?? '',
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          (room['name'] ?? '').toUpperCase(),
                                          style: TextStyle(
                                            color: kThemeColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              color: Colors.grey,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                room['locationName'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.email,
                                              color: Colors.grey,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$userEmail',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: roomStatus['status']
                                                          ['statusDisplay'] ==
                                                      'Available'
                                                  ? Colors.green
                                                  : roomStatus['status'][
                                                              'statusDisplay'] ==
                                                          'Booked'
                                                      ? Colors.red
                                                      : Colors.orange,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Status: ${roomStatus['status']['statusDisplay']}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
