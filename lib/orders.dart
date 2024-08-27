import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'Constants/styleConsts.dart';
import 'aggreement.dart';
import 'model/onSaleModel.dart';

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
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 20,
                                      width: double.infinity,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 16,
                                      width: 150,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 16,
                                      width: 100,
                                      color: Colors.grey.shade300,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 20,
                                          width: double.infinity,
                                          color: Colors.grey.shade300,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          height: 16,
                                          width: 150,
                                          color: Colors.grey.shade300,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          height: 16,
                                          width: 100,
                                          color: Colors.grey.shade300,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
                        child: GestureDetector(
                          onTap: () {
                            log(roomId);
                            if (roomStatus['status']['statusDisplay'] ==
                                "Sold") {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AgreementPage(
                                          roomStatus['status']['SoldBy'],
                                          roomStatus['status']['SellerEmail'],
                                          roomId)));
                            } else {}
                          },
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    color: roomStatus['status'][
                                                                'statusDisplay'] ==
                                                            'Owned'
                                                        ? Colors.green
                                                        : roomStatus['status'][
                                                                    'statusDisplay'] ==
                                                                'Sold'
                                                            ? Colors.red
                                                            : Colors.orange,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Status: ${roomStatus['status']['statusDisplay']}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Visibility(
                                                visible: roomStatus['status']
                                                        ['statusDisplay'] ==
                                                    "Owned",
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (roomStatus['report']
                                                            ['electricity'] ==
                                                        null) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              "No Report Generated Yet."),
                                                        ),
                                                      );
                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.0),
                                                            ),
                                                            title: Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .picture_as_pdf,
                                                                    color:
                                                                        kThemeColor),
                                                                SizedBox(
                                                                    width: 10),
                                                                Text(
                                                                  'Room Report',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        kThemeColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            content:
                                                                SingleChildScrollView(
                                                              child: Table(
                                                                border:
                                                                    TableBorder(
                                                                  horizontalInside:
                                                                      BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300,
                                                                  ),
                                                                ),
                                                                columnWidths: const {
                                                                  0: FlexColumnWidth(
                                                                      1),
                                                                  1: FlexColumnWidth(
                                                                      2),
                                                                },
                                                                children: [
                                                                  _buildTableRow(
                                                                      'Electricity',
                                                                      roomStatus[
                                                                              'report']
                                                                          [
                                                                          'electricity']),
                                                                  _buildTableRow(
                                                                      'Fohor',
                                                                      roomStatus[
                                                                              'report']
                                                                          [
                                                                          'fohor']),
                                                                  _buildTableRow(
                                                                      'Generated Date',
                                                                      roomStatus[
                                                                              'report']
                                                                          [
                                                                          'generatedDate']),
                                                                  _buildTableRow(
                                                                      'Room Cost',
                                                                      roomStatus[
                                                                              'report']
                                                                          [
                                                                          'roomCost']),
                                                                  _buildTableRow(
                                                                      'Water',
                                                                      roomStatus[
                                                                              'report']
                                                                          [
                                                                          'water']),
                                                                  _buildTableRow(
                                                                      'Total',
                                                                      roomStatus[
                                                                              'report']
                                                                          [
                                                                          'total']),
                                                                ],
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  'Close',
                                                                  style: TextStyle(
                                                                      color:
                                                                          kThemeColor),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                  child: Icon(
                                                      Icons.picture_as_pdf,
                                                      color: kThemeColor),
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
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, dynamic value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            value.toString(),
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
