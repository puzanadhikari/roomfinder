import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/provider/pageProvider.dart';
import 'package:meroapp/roomdetail.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'Constants/styleConsts.dart';
import 'calculation.dart';
import 'model/onSaleModel.dart';

class Listing extends StatefulWidget {
  double lat, lng;

  Listing(this.lat, this.lng, {super.key});

  @override
  State<Listing> createState() => _ListingState();
}

class _ListingState extends State<Listing> {
  String searchQuery = '';
  bool showAllMostSearch = false;
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c;
    return distance;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }

  List<Room> sortedRoomsByDistance(
      List<Room> rooms, double userLat, double userLng) {
    rooms.sort((a, b) {
      double distanceA = haversineDistance(userLat, userLng, a.lat, a.lng);
      double distanceB = haversineDistance(userLat, userLng, b.lat, b.lng);
      return distanceA.compareTo(distanceB);
    });
    return rooms;
  }

  Future<List<Room>> fetchMostSearchedProducts() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('searchHistory')
        .orderBy('count', descending: true)
        .limit(10)
        .get();

    List<Room> mostSearchedProducts = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final productId = data['productId'];

      final productSnapshot = await FirebaseFirestore.instance
          .collection('onSale')
          .doc(productId)
          .get();
      if (productSnapshot.exists) {
        final productData = productSnapshot.data() as Map<String, dynamic>;
        mostSearchedProducts.add(Room(
          uid: productSnapshot.id,
          name: productData['name'],
          price: productData["price"],
          details: Map<String, String>.from(productData["detail"]),
          capacity: productData['capacity'],
          description: productData['description'],
          water: productData['water'],
          roomLength: productData['roomLength'],
          roomBreath: productData['roomBreadth'],
          hallBreadth: productData['hallBreadth'],
          hallLength: productData['hallLength'],
          kitchenbreadth: productData['kitchenBreadth'],
          kitchenLength: productData['kitchenLength'],
          photo: List<String>.from(productData['photo']),
          panoramaImg: List<String>.from(productData['panoramaImg']),
          electricity: productData['electricity'],
          fohor: productData['fohor'],
          lat: productData['lat'],
          lng: productData['lng'],
          active: productData['active'],
          statusByAdmin: productData["statusByAdmin"],
          featured: productData['featured'],
          locationName: productData["locationName"],
          status: productData['status'] != null
              ? Map<String, dynamic>.from(productData['status'])
              : {},
          report: productData['report'] != null
              ? Map<String, dynamic>.from(productData['report'])
              : {},
          facilities: productData['facilities'] != null
              ? List<String>.from(productData['facilities'])
              : [],
        ));
      }
    }
    return mostSearchedProducts;
  }

  Future<List<Room>> fetchRooms() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('onSale')
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Room(
        uid: doc.id,
        name: data['name'],
        price: data["price"],
        details: Map<String, String>.from(data["detail"]),
        capacity: data['capacity'],
        water: doc['water'],
        description: data['description'],
        roomLength: data['roomLength'],
        roomBreath: data['roomBreadth'],
        hallBreadth: data['hallBreadth'],
        hallLength: data['hallLength'],
        kitchenbreadth: data['kitchenBreadth'],
        kitchenLength: data['kitchenLength'],
        statusByAdmin: data["statusByAdmin"],
        photo: List<String>.from(data['photo']),
        panoramaImg: List<String>.from(data['panoramaImg']),
        electricity: data['electricity'],
        fohor: data['fohor'],
        lat: data['lat'],
        lng: data['lng'],
        active: data['active'],
        featured: data['featured'],
        locationName: data["locationName"],
        status: data['status'] != null
            ? Map<String, dynamic>.from(data['status'])
            : {},
        report: data['report'] != null
            ? Map<String, dynamic>.from(data['report'])
            : {},
        facilities: data['facilities'] != null
            ? List<String>.from(data['facilities'])
            : [],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pageProvider = Provider.of<PageProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        pageProvider.setChoice("From Main");
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.grey.shade200,
          title: Text(
              // pageProvider.choice,
              "Listing",
              style: TextStyle(
                  color: kThemeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
        ),
        body: pageProvider.choice == "From Main"
            ? NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FutureBuilder<List<Room>>(
                        future: fetchMostSearchedProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      width: 150,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ListView.builder(
                                    itemCount: 3,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius
                                                    .horizontal(
                                                  left: Radius.circular(16.0),
                                                  right: Radius.circular(16.0),
                                                ),
                                                child: Container(
                                                  height: 100,
                                                  width: 100,
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 16.0,
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Container(
                                                        width: 100,
                                                        height: 16.0,
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Container(
                                                        width: 80,
                                                        height: 16.0,
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: 60,
                                                            height: 16.0,
                                                            color: Colors
                                                                .grey.shade300,
                                                          ),
                                                          Container(
                                                            width: 80,
                                                            height: 16.0,
                                                            color: Colors
                                                                .grey.shade300,
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
                                  ),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No products found.'));
                          }
                          final uniqueProducts = snapshot.data!.toSet().toList();

                          final displayedProducts = uniqueProducts;
                              // ? uniqueProducts
                              // : uniqueProducts.take(3).toList();
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Most searched",
                                  style: TextStyle(
                                    color: Color(0xFF072A2E),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ListView.builder(
                                  itemCount: displayedProducts.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final product = displayedProducts[index];
                                    final distance = calculateDistance(
                                      widget.lat,
                                      widget.lng,
                                      product.lat,
                                      product.lng,
                                    ).toStringAsFixed(1);
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RoomDetailPage(
                                                    room: product,
                                                    distance: distance),
                                          ),
                                        );
                                      },
                                      child: Visibility(
                                        visible: displayedProducts[index]
                                                    .status
                                                    .isEmpty ||
                                                displayedProducts[index].status[
                                                        'statusDisplay'] ==
                                                    "To Buy"
                                            ? true
                                            : false,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                blurRadius: 5,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius
                                                            .horizontal(
                                                      left:
                                                          Radius.circular(16.0),
                                                      right:
                                                          Radius.circular(16.0),
                                                    ),
                                                    child: Image.network(
                                                      product.photo.isNotEmpty
                                                          ? product.photo[0]
                                                          : 'https://via.placeholder.com/150',
                                                      height: 100,
                                                      width: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            product.name
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              color:
                                                                  kThemeColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            product
                                                                .locationName,
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade700,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            "${product.price}/ per month",
                                                            style: TextStyle(
                                                              color:
                                                                  kThemeColor,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .location_on_rounded,
                                                                  size: 16,
                                                                  color:
                                                                      kThemeColor),
                                                              Text(
                                                                "$distance km from you.",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black45),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  displayedProducts[index].status[
                                                                              'statusDisplay'] ==
                                                                          "Owned"
                                                                      ? Icons
                                                                          .check_circle
                                                                      : Icons
                                                                          .flag_circle,
                                                                  size: 16,
                                                                  color:
                                                                      kThemeColor),
                                                              Text(
                                                                displayedProducts[index].status[
                                                                            'statusDisplay'] ==
                                                                        "To Buy"
                                                                    ? "Booked"
                                                                    : displayedProducts[index].status['statusDisplay'] ==
                                                                            "Sold"
                                                                        ? "Sold"
                                                                        : displayedProducts[index].status['statusDisplay'] ==
                                                                                "Owned"
                                                                            ? "Owned"
                                                                            : "To Buy",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black45),
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
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      FutureBuilder<List<Room>>(
                        future: fetchRooms(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      width: 150,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ListView.builder(
                                    itemCount: 3,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius
                                                    .horizontal(
                                                  left: Radius.circular(16.0),
                                                  right: Radius.circular(16.0),
                                                ),
                                                child: Container(
                                                  height: 100,
                                                  width: 100,
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 16.0,
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Container(
                                                        width: 100,
                                                        height: 16.0,
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Container(
                                                        width: 80,
                                                        height: 16.0,
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: 60,
                                                            height: 16.0,
                                                            color: Colors
                                                                .grey.shade300,
                                                          ),
                                                          Container(
                                                            width: 80,
                                                            height: 16.0,
                                                            color: Colors
                                                                .grey.shade300,
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
                                  ),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No rooms available.'));
                          }
                          // Filter and sort rooms based on search query
                          List<Room> filteredRooms = snapshot.data!
                              .where((room) => room.name
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()))
                              .toList();

                          // Sort the filtered rooms by distance
                          List<Room> sortedRooms = sortedRoomsByDistance(
                              filteredRooms, widget.lat, widget.lng);

                          // sortedRooms = snapshot.data!;

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Suggested Near You",
                                  style: TextStyle(
                                    color: Color(0xFF072A2E),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ListView.builder(
                                  itemCount: sortedRooms.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final room = sortedRooms[index];
                                    final distance = calculateDistance(
                                      widget.lat,
                                      widget.lng,
                                      room.lat,
                                      room.lng,
                                    ).toStringAsFixed(1);
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RoomDetailPage(
                                                    room: room,
                                                    distance: distance),
                                          ),
                                        );
                                      },
                                      child: Visibility(
                                        visible: room.status.isEmpty ||
                                                room.status['statusDisplay'] ==
                                                    "To Buy"
                                            ? true
                                            : false,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                blurRadius: 5,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius
                                                            .horizontal(
                                                      left:
                                                          Radius.circular(16.0),
                                                      right:
                                                          Radius.circular(16.0),
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
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            room.name
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              color:
                                                                  kThemeColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            room.locationName,
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade700,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            "${room.price}/ per month",
                                                            style: TextStyle(
                                                              color:
                                                                  kThemeColor,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .location_on_rounded,
                                                                  size: 16,
                                                                  color:
                                                                      kThemeColor),
                                                              Text(
                                                                "$distance km from you.",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black45),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  room.status['statusDisplay'] ==
                                                                          "Owned"
                                                                      ? Icons
                                                                          .check_circle
                                                                      : Icons
                                                                          .flag_circle,
                                                                  size: 16,
                                                                  color:
                                                                      kThemeColor),
                                                              Text(
                                                                room.status['statusDisplay'] ==
                                                                        "To Buy"
                                                                    ? "Booked"
                                                                    : room.status['statusDisplay'] ==
                                                                            "Sold"
                                                                        ? "Sold"
                                                                        : room.status['statusDisplay'] ==
                                                                                "Owned"
                                                                            ? "Owned"
                                                                            : "To Buy",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black45),
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
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            : pageProvider.choice == "Suggested"
                ? FutureBuilder<List<Room>>(
                    future: fetchRooms(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 150,
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListView.builder(
                                itemCount: 3,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.horizontal(
                                              left: Radius.circular(16.0),
                                              right: Radius.circular(16.0),
                                            ),
                                            child: Container(
                                              height: 100,
                                              width: 100,
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    height: 16.0,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    width: 100,
                                                    height: 16.0,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    width: 80,
                                                    height: 16.0,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: 60,
                                                        height: 16.0,
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      Container(
                                                        width: 80,
                                                        height: 16.0,
                                                        color: Colors
                                                            .grey.shade300,
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
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No rooms available.'));
                      }
                      // Filter and sort rooms based on search query
                      List<Room> filteredRooms = snapshot.data!
                          .where((room) => room.name
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()))
                          .toList();

                      // Sort the filtered rooms by distance
                      List<Room> sortedRooms = sortedRoomsByDistance(
                          filteredRooms, widget.lat, widget.lng);

                      return NotificationListener<
                          OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll.disallowIndicator();
                          return true;
                        },
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Suggested Near You",
                                  style: TextStyle(
                                    color: Color(0xFF072A2E),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ListView.builder(
                                  itemCount: sortedRooms.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final room = sortedRooms[index];
                                    final distance = calculateDistance(
                                      widget.lat,
                                      widget.lng,
                                      room.lat,
                                      room.lng,
                                    ).toStringAsFixed(1);
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RoomDetailPage(
                                                    room: room,
                                                    distance: distance),
                                          ),
                                        );
                                      },
                                      child: Visibility(
                                        visible: room.status.isEmpty ||
                                                room.status['statusDisplay'] ==
                                                    "To Buy"
                                            ? true
                                            : false,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                blurRadius: 5,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius
                                                            .horizontal(
                                                      left:
                                                          Radius.circular(16.0),
                                                      right:
                                                          Radius.circular(16.0),
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
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            room.name
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              color:
                                                                  kThemeColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            room.locationName,
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade700,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            "${room.price}/ per month",
                                                            style: TextStyle(
                                                              color:
                                                                  kThemeColor,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .location_on_rounded,
                                                                  size: 16,
                                                                  color:
                                                                      kThemeColor),
                                                              Text(
                                                                "$distance km from you.",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black45),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  room.status['statusDisplay'] ==
                                                                          "Owned"
                                                                      ? Icons
                                                                          .check_circle
                                                                      : Icons
                                                                          .flag_circle,
                                                                  size: 16,
                                                                  color:
                                                                      kThemeColor),
                                                              Text(
                                                                room.status['statusDisplay'] ==
                                                                        "To Buy"
                                                                    ? "Booked"
                                                                    : room.status['statusDisplay'] ==
                                                                            "Sold"
                                                                        ? "Sold"
                                                                        : room.status['statusDisplay'] ==
                                                                                "Owned"
                                                                            ? "Owned"
                                                                            : "To Buy",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black45),
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
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : FutureBuilder<List<Room>>(
                    future: fetchMostSearchedProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 150,
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListView.builder(
                                itemCount: 3,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.horizontal(
                                              left: Radius.circular(16.0),
                                              right: Radius.circular(16.0),
                                            ),
                                            child: Container(
                                              height: 100,
                                              width: 100,
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    height: 16.0,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    width: 100,
                                                    height: 16.0,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    width: 80,
                                                    height: 16.0,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: 60,
                                                        height: 16.0,
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      Container(
                                                        width: 80,
                                                        height: 16.0,
                                                        color: Colors
                                                            .grey.shade300,
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
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No products found.'));
                      }
                      final uniqueProducts = snapshot.data!.toSet().toList();

                      final displayedProducts = uniqueProducts;
                          // ? uniqueProducts
                          // : uniqueProducts.take(3).toList();
                      return NotificationListener<
                          OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll.disallowIndicator();
                          return true;
                        },
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Most Searched",
                                  style: TextStyle(
                                    color: Color(0xFF072A2E),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ListView.builder(
                                  itemCount: displayedProducts.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final product = displayedProducts[index];
                                    final distance = calculateDistance(
                                      widget.lat,
                                      widget.lng,
                                      product.lat,
                                      product.lng,
                                    ).toStringAsFixed(1);
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RoomDetailPage(
                                                room: product,
                                                distance: distance),
                                          ),
                                        );
                                      },
                                      child: Visibility(
                                        visible: displayedProducts[index]
                                                    .status
                                                    .isEmpty ||
                                                displayedProducts[index].status[
                                                        'statusDisplay'] ==
                                                    "To Buy"
                                            ? true
                                            : false,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                blurRadius: 5,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius
                                                            .horizontal(
                                                      left: Radius.circular(16.0),
                                                      right:
                                                          Radius.circular(16.0),
                                                    ),
                                                    child: Image.network(
                                                      product.photo.isNotEmpty
                                                          ? product.photo[0]
                                                          : 'https://via.placeholder.com/150',
                                                      height: 100,
                                                      width: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            product.name
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              color: kThemeColor,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            product.locationName,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey.shade700,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            "${product.price}/ per month",
                                                            style: TextStyle(
                                                              color: kThemeColor,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .location_on_rounded,
                                                                  size: 16,
                                                                  color:
                                                                      kThemeColor),
                                                              Text(
                                                                "$distance km from you.",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black45),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  displayedProducts[index].status[
                                                                              'statusDisplay'] ==
                                                                          "Owned"
                                                                      ? Icons
                                                                          .check_circle
                                                                      : Icons
                                                                          .flag_circle,
                                                                  size: 16,
                                                                  color:
                                                                      kThemeColor),
                                                              Text(
                                                                displayedProducts[index]
                                                                                .status[
                                                                            'statusDisplay'] ==
                                                                        "To Buy"
                                                                    ? "Booked"
                                                                    : displayedProducts[index].status[
                                                                                'statusDisplay'] ==
                                                                            "Sold"
                                                                        ? "Sold"
                                                                        : displayedProducts[index].status['statusDisplay'] ==
                                                                                "Owned"
                                                                            ? "Owned"
                                                                            : "To Buy",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black45),
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
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
