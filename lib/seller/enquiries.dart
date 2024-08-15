import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/onSaleModel.dart';

Future<List<Room>> fetchEnquiries() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  // Create a reference to the collection
  CollectionReference roomsCollection = FirebaseFirestore.instance.collection('onSale');

  // Build a query to fetch all rooms for the current user
  final QuerySnapshot snapshot = await roomsCollection
      .where('userId', isEqualTo: user.uid) // Filter by current user
      .get();

  // Filter the results in memory based on the status
  List<Room> rooms = snapshot.docs.map((doc) {
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

  rooms = rooms.where((room) => room.status.isNotEmpty).toList();
  rooms = rooms.where((room) => room.status['statusDisplay']=="To Buy").toList();
  return rooms;
}


class EnquiriesPage extends StatefulWidget {
  @override
  _EnquiriesPageState createState() => _EnquiriesPageState();
}

class _EnquiriesPageState extends State<EnquiriesPage> {
  late Future<List<Room>> enquiries;

  @override
  void initState() {
    super.initState();
    enquiries = fetchEnquiries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Enquiries"),
      ),
      body: FutureBuilder<List<Room>>(
        future: enquiries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No enquiries found."));
          } else {
            final rooms = snapshot.data!;
            return ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return ListTile(
                  title: Text(room.name),
                  subtitle: Text(room.description),
                  trailing: Text(room.status['statusDisplay']??""), // Display the status
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(

                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Buyer name : ${room.status["By"]}"),
                              Text("Buyer Email : ${room.status["userEmail"]}"),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _approveRoomStatus(room.uid,room);
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text("Approve"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
  void _approveRoomStatus(String roomUid,Room room) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Prepare the new status data
      Map<String, dynamic> newStatus = {
        'SoldBy': user?.displayName,
        'sellerId': user?.uid,
        'SellerEmail': user?.email,
        'statusDisplay': 'Sold', // Change status to Sold
      };

      // Update the status in Firestore
      await FirebaseFirestore.instance
          .collection('onSale')
          .doc(roomUid) // Use the room ID
          .update({'status': newStatus}); // Update status

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room status updated to Sold!')),
      );

      setState(() {
      room.status = newStatus; // Update the UI with new status
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

}
