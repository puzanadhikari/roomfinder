import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/onSaleModel.dart';

Future<List<Room>> fetchMyListings() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('onSale')
      .where('userId', isEqualTo: user.uid)
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      uid: doc.id,
      name: data['name'],
      capacity: data['capacity'],
      description: data['description'],
      length: data['length'],
      breadth: data['breadth'],
      photo: List<String>.from(data['photo']),
      panoramaImg: data['panoramaImg'],
      electricity: data['electricity'],
      fohor: data['fohor'],
      lat: data['lat'],
      lng: data['lng'],
      active: data['active'],
      featured: data['featured'],
      locationName: data['locationName'],
      status: data['status'] != null ? Map<String, dynamic>.from(data['status']) : {},
    );
  }).toList();
}
class MyListingsPage extends StatefulWidget {
  @override
  _MyListingsPageState createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  late Future<List<Room>> myListings;

  @override
  void initState() {
    super.initState();
    myListings = fetchMyListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Listings"),
      ),
      body: FutureBuilder<List<Room>>(
        future: myListings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No listings found."));
          } else {
            final rooms = snapshot.data!;
            return ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(room.name),
                      Text(room.status['statusDisplay']??""),
                    ],
                  ),
                  subtitle: Text(room.description),
                  onTap: () {
                    // Navigate to detail page or take other actions
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
