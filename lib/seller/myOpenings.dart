import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/seller/createRoom.dart';
import 'package:meroapp/seller/seller_room_details.dart';
import 'package:shimmer/shimmer.dart';

import '../Constants/styleConsts.dart';
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
      price: data["price"],
      description: data['description'],
      length: data['length'],
      breadth: data['breadth'],
      water: doc['water'],
      photo: List<String>.from(data['photo']),
      panoramaImg: data['panoramaImg'],
      electricity: data['electricity'],
      fohor: data['fohor'],
      lat: data['lat'],
      lng: data['lng'],
      active: data['active'],
      featured: data['featured'],
      statusByAdmin: data["statusByAdmin"],
      details: Map<String, String>.from(data["detail"]),
      locationName: data['locationName'],
      status: data['status'] != null
          ? Map<String, dynamic>.from(data['status'])
          : {},
      report: data['report'] != null ? Map<String, dynamic>.from(data['report']) : {},
      facilities: data['facilities'] != null ? List<String>.from(data['facilities']) : [],
    );
  }).toList();
}

class MyListingsPage extends StatefulWidget {
  final double lat, lng;

  const MyListingsPage(this.lat, this.lng, {super.key});

  @override
  _MyListingsPageState createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  late Future<List<Room>> myListings;
  final TextEditingController _electricityController = TextEditingController();
  @override
  void initState() {
    super.initState();
    myListings = fetchMyListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey.shade200,
        title: Text("Listings",
            style: TextStyle(
                color: kThemeColor, fontWeight: FontWeight.bold, fontSize: 25)),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recently added properties",
                style: TextStyle(
                    color: Color(0xFF072A2E),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CreateRoom()));
                  },
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF072A2E),
                  ))
            ],
          ),
          Flexible(
            child: FutureBuilder<List<Room>>(
              future: myListings,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerEffect();
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {

                  return const Center(child: Text("No listings found."));
                } else {
                  final rooms = snapshot.data!;
                  final roomStatus = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: ListView.builder(
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];

                          return GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SellerRoomDetails(room: room)));
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
                                        borderRadius:
                                            const BorderRadius.horizontal(
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
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Visibility(
                                                    visible:roomStatus[index].status['statusDisplay']=="Owned"?true:false,
                                                    child: GestureDetector(
                                                          onTap: (){
                                                            showModalBottomSheet(
                                                              context: context,
                                                              enableDrag: true,
                                                              isScrollControlled: true,
                                                              builder: (BuildContext context) {
                                                                return FractionallySizedBox(
                                                                  heightFactor: 0.5,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(16.0),
                                                                    child: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [

                                                                        TextField(
                                                                          controller: _electricityController,
                                                                          keyboardType: TextInputType.number,
                                                                          decoration: InputDecoration(
                                                                            labelText: 'Electricity (Number)',
                                                                            border: OutlineInputBorder(),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(height: 20),
                                                                        ElevatedButton(
                                                                          onPressed: () {
                                                                            double electricity =double.parse( _electricityController.text);
                                                                            print('Electricity: $electricity');
                                                                            _generateReport(room.uid,room,electricity);
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child: const Text('Submit'),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        child: Icon(Icons.picture_as_pdf)),
                                                  ),
                                                  Visibility(
                                                    visible:roomStatus[index].status['statusDisplay']=="Owned"?true:false,
                                                    child: GestureDetector(
                                                          onTap: (){
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return AlertDialog(
                                                                  title: Text('Room Report'),
                                                                  content: SingleChildScrollView(
                                                                    child: Table(
                                                                      border: TableBorder.all(),
                                                                      columnWidths: {
                                                                        0: FlexColumnWidth(1),
                                                                        1: FlexColumnWidth(2),
                                                                      },
                                                                      children: [
                                                                        TableRow(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text('Electricity'),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text(roomStatus[index].report['electricity'].toString()),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        TableRow(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text('Fohor'),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text(roomStatus[index].report['fohor'].toString()),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        TableRow(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text('Generated Date'),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text(roomStatus[index].report['generatedDate'].toString()),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        TableRow(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text('Room Cost'),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text(roomStatus[index].report['roomCost'].toString()),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        TableRow(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text('Water'),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text(roomStatus[index].report['water'].toString()),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        TableRow(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text('Total'),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text(roomStatus[index].report['total'].toString()),
                                                                            ),
                                                                          ],
                                                                        ),

                                                                      ],
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                      child: Text('Close'),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                        child: Icon(Icons.view_agenda)),
                                                  ),
                                                ],
                                              ),
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
                                              Text(
                                                "Capacity: ${room.capacity}",
                                                style: TextStyle(
                                                  color: kThemeColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .location_on_rounded,
                                                          size: 16,
                                                          color: kThemeColor),
                                                      Text(
                                                        "${(rooms[index].lat - widget.lat).abs().toStringAsFixed(1)} km from you.",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black45),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.check_circle,
                                                          size: 16,
                                                          color: kThemeColor),
                                                      const Text(
                                                        "Available",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black45),
                                                      )
                                                    ],
                                                  ),

                                                ],
                                              ),
                                              Row(
                                                children: [

                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Status: ${roomStatus[index].status['statusDisplay']}',
                                                    style:
                                                    const TextStyle(fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                'Owner: ${roomStatus[index].status['ownedBy']}',
                                                style:
                                                const TextStyle(fontSize: 14),
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
          ),
        ],
      ),
    );
  }
  String generateCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss'); // Adjust format as needed
    return formatter.format(now);
  }
  void _generateReport(String? roomUid,Room room,double electricityUnit) async {
log(electricityUnit.toString());
    try {
      User? user = FirebaseAuth.instance.currentUser;
      final generatedDate = generateCurrentDateTime();
    double total =room.price+(room.electricity*electricityUnit)+room.water+room.fohor;
      Map<String, dynamic> report = {
        'roomCost': room.price,
        'electricity': room.electricity*electricityUnit,
        'water': room.water,
        'fohor': room.fohor,
        "total":total,
        "generatedDate":generatedDate
      };

      await FirebaseFirestore.instance
          .collection('onSale')
          .doc(roomUid)
          .update({'report': report});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room status updated to Sold!')),
      );

      // setState(() {
      //   room!.status = newStatus;
      // });
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }
  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        );
      },
    );
  }
}
