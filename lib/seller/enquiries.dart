import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meroapp/seller/seller_room_details.dart';

import '../Constants/styleConsts.dart';
import '../model/onSaleModel.dart';

Stream<List<Room>> fetchEnquiries() async* {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  CollectionReference roomsCollection = FirebaseFirestore.instance.collection('onSale');

  // Listen for updates on the collection
  await for (var snapshot in roomsCollection.where('userId', isEqualTo: user.uid).snapshots()) {
    List<Room> rooms = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Room(
        uid: doc.id,
        name: data['name'],
        price: data["price"],
        capacity: data['capacity'],
        description: data['description'],
        roomLength: data['roomLength'],
        roomBreath: data['roomBreadth'],
        hallBreadth: data['hallBreadth'],
        hallLength: data['hallLength'],
        kitchenbreadth: data['kitchenBreadth'],
        kitchenLength: data['kitchenLength'],
        photo: List<String>.from(data['photo']),
        panoramaImg: List<String>.from(data['panoramaImg']),
        water: data['water'],
        electricity: data['electricity'],
        fohor: data['fohor'],
        lat: data['lat'],
        lng: data['lng'],
        active: data['active'],
        featured: data['featured'],
        locationName: data['locationName'],
        statusByAdmin: data["statusByAdmin"],
        details: Map<String, String>.from(data["detail"]),
        status: data['status'] != null ? Map<String, dynamic>.from(data['status']) : {},
        report: data['report'] != null ? Map<String, dynamic>.from(data['report']) : {},
        facilities: data['facilities'] != null ? List<String>.from(data['facilities']) : [],
      );
    }).toList();

    rooms = rooms.where((room) => room.status.isNotEmpty && room.status['statusDisplay'] == "To Buy").toList();

    yield rooms;
  }
}

class EnquiriesPage extends StatefulWidget {
  final double lat, lng;

  const EnquiriesPage(this.lat, this.lng, {super.key});

  @override
  _EnquiriesPageState createState() => _EnquiriesPageState();
}

class _EnquiriesPageState extends State<EnquiriesPage> {
  late Stream<List<Room>> enquiries;

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
                color: kThemeColor, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: StreamBuilder<List<Room>>(
        stream: enquiries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No enquiries found."));
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
                                SellerRoomDetails(room: room),
                          ),
                        );
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
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          room.name.toUpperCase(),
                                          style: TextStyle(
                                            color: kThemeColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
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
                                        Text(
                                          "NPR: ${room.price}/month",
                                          style: TextStyle(
                                            color: kThemeColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  room.status['statusDisplay'] ==
                                                      "Owned"
                                                      ? Icons.check_circle
                                                      : Icons.flag_circle,
                                                  size: 16,
                                                  color: kThemeColor,
                                                ),
                                                Text(
                                                  '${room.status['statusDisplay']}',
                                                  style: const TextStyle(
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
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                        ),
                                                        contentPadding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                        title: Row(
                                                          children: [
                                                            Icon(Icons.info,
                                                                color:
                                                                kThemeColor),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                              "Approve or Reject Room",
                                                              style: TextStyle(
                                                                color:
                                                                kThemeColor,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        content: Column(
                                                          mainAxisSize:
                                                          MainAxisSize.min,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            const SizedBox(
                                                                height: 10),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.person,
                                                                    color:
                                                                    kThemeColor),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Flexible(
                                                                    child: Text(room
                                                                        .status[
                                                                    "By"] ??
                                                                        "")),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.email,
                                                                    color:
                                                                    kThemeColor),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Flexible(
                                                                    child: Text(room
                                                                        .status[
                                                                    "userEmail"] ??
                                                                        "")),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        actionsPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 5.0),
                                                        actions: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              _approveRoomStatus(
                                                                  room.uid,
                                                                  room);
                                                              Navigator.of(
                                                                  context)
                                                                  .pop();
                                                            },
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                              backgroundColor:
                                                              kThemeColor,
                                                              shape:
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10.0),
                                                              ),
                                                            ),
                                                            child:
                                                            const Text("Approve"),
                                                          ),
                                                          OutlinedButton(
                                                            onPressed: () {
                                                              _rejectRoomStatus(
                                                                  room.uid,
                                                                  room);
                                                              Navigator.of(
                                                                  context)
                                                                  .pop();
                                                            },
                                                            style: OutlinedButton
                                                                .styleFrom(
                                                              side: BorderSide(
                                                                  color:
                                                                  kThemeColor),
                                                              shape:
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10.0),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              "Reject",
                                                              style: TextStyle(
                                                                  color:
                                                                  kThemeColor),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                  kThemeColor.withOpacity(0.3),
                                                  foregroundColor: kThemeColor,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(8.0),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Action",
                                                  style:
                                                  TextStyle(fontSize: 10.0),
                                                ),
                                              ),
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

  Future<void> _approveRoomStatus(String roomUid, Room room) async {
    await FirebaseFirestore.instance.collection("onSale").doc(roomUid).update({
      "status.statusDisplay": "Owned",
      "status.statusApproved": true,
      "status.By": room.status["By"],
      "status.userEmail": room.status["userEmail"],
    });

    Fluttertoast.showToast(msg: "Room status approved.");
  }

  Future<void> _rejectRoomStatus(String roomUid, Room room) async {
    await FirebaseFirestore.instance.collection("onSale").doc(roomUid).update({
      "status": FieldValue.delete(),  // This deletes the entire 'status' field
    });

    Fluttertoast.showToast(msg: "Room request rejected, and status cleared.");
  }
}
