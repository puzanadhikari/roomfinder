import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/seller/seller_room_details.dart';

import '../Constants/styleConsts.dart';
import '../model/onSaleModel.dart';

Future<List<Room>> fetchEnquiries() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  // Create a reference to the collection
  CollectionReference roomsCollection =
      FirebaseFirestore.instance.collection('onSale');

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
      price: data["price"],
      capacity: data['capacity'],
      description: data['description'],
      length: data['length'],
      breadth: data['breadth'],
      photo: List<String>.from(data['photo']),
      panoramaImg: data['panoramaImg'],
      water: doc['water'],
      electricity: data['electricity'],
      fohor: data['fohor'],
      lat: data['lat'],
      lng: data['lng'],
      active: data['active'],
      featured: data['featured'],
      locationName: data['locationName'],
      statusByAdmin: data["statusByAdmin"],
      details: Map<String, String>.from(data["detail"]),
      status: data['status'] != null
          ? Map<String, dynamic>.from(data['status'])
          : {},
      report: data['report'] != null ? Map<String, dynamic>.from(data['report']) : {},
      facilities: data['facilities'] != null ? List<String>.from(data['facilities']) : [],
    );
  }).toList();

  rooms = rooms.where((room) => room.status.isNotEmpty).toList();
  rooms =
      rooms.where((room) => room.status['statusDisplay'] == "To Buy").toList();
  return rooms;
}

class EnquiriesPage extends StatefulWidget {
  final double lat, lng;

  const EnquiriesPage(this.lat, this.lng, {super.key});

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
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey.shade200,
        title: Text("Enquiries",
            style: TextStyle(
                color: kThemeColor, fontWeight: FontWeight.bold, fontSize: 25)),
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
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SellerRoomDetails(room: room)));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
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
                                    right: Radius.circular(16.0),
                                  ),
                                  child: Image.network(
                                    room.photo.isNotEmpty
                                        ? room.photo[0]
                                        : 'https://via.placeholder.com/150',
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
                                          room.name.toUpperCase(),
                                          style: TextStyle(
                                            color: kThemeColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          room.locationName,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "NPR: ${room.price}/month",
                                              style: TextStyle(
                                                color: kThemeColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(room.status[
                                                'statusDisplay'] ==
                                                    "Owned"
                                                    ? Icons
                                                    .check_circle
                                                    : Icons
                                                    .flag_circle,
                                                    size: 16,
                                                    color: kThemeColor),
                                                Text(
                                                  '${room.status['statusDisplay']}',
                                                  style: TextStyle(
                                                      color:
                                                      Colors.black45),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.location_on_rounded,
                                                    size: 16,
                                                    color: kThemeColor),
                                                Text(
                                                  "${(rooms[index].lat - widget.lat).abs().toStringAsFixed(1)} km from you.",
                                                  style: TextStyle(
                                                      color: Colors.black45),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 30,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(20.0),
                                                        ),
                                                        contentPadding: const EdgeInsets.all(20.0),
                                                        title: Row(
                                                          children: [
                                                            Icon(Icons.info, color: kThemeColor),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              "Approve Room Status",
                                                              style: TextStyle(
                                                                color: kThemeColor,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        content: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            SizedBox(height: 10),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.person, color: kThemeColor),
                                                                SizedBox(width: 8),
                                                                Text(
                                                                  "Buyer Name:",
                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                ),
                                                                SizedBox(width: 8),
                                                                Text(room.status["By"] ?? ""),
                                                              ],
                                                            ),
                                                            SizedBox(height: 10),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.email, color: kThemeColor),
                                                                SizedBox(width: 8),
                                                                Text(
                                                                  "Buyer Email:",
                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                ),
                                                                SizedBox(width: 8),
                                                                Text(room.status["userEmail"] ?? ""),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        actionsPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                                        actions: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              _approveRoomStatus(room.uid, room);
                                                              Navigator.of(context).pop(); // Close the dialog
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: kThemeColor,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10.0),
                                                              ),
                                                            ),
                                                            child: Text("Approve"),
                                                          ),
                                                          OutlinedButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            style: OutlinedButton.styleFrom(
                                                              side: BorderSide(color: kThemeColor),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10.0),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              "Cancel",
                                                              style: TextStyle(color: kThemeColor),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(backgroundColor: kThemeColor),
                                                child: Text("Approve"),
                                              ),
                                            )
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
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _approveRoomStatus(String roomUid, Room room) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      Map<String, dynamic> newStatus = {
        'SoldBy': user?.displayName,
        'sellerId': user?.uid,
        'SellerEmail': user?.email,
        'statusDisplay': 'Sold',
      };

      await FirebaseFirestore.instance
          .collection('onSale')
          .doc(roomUid)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room status updated to Sold!')),
      );

      setState(() {
        room.status = newStatus;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }
}
