import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/provider/pageProvider.dart';
import 'package:meroapp/roomdetail.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'calculation.dart';
import 'model/onSaleModel.dart';

class DashBoard extends StatefulWidget {
  double lat, lng;

  DashBoard(this.lat, this.lng, {super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  bool showAllMostSearch = false;
  bool showAllNearYou = false;
  TextEditingController searchController = TextEditingController();

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
        length: data['length'],
        breadth: data['breadth'],
        photo: List<String>.from(data['photo']),
        statusByAdmin: data["statusByAdmin"],
        panoramaImg: data['panoramaImg'],
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

  Future<void> recordSearch(String searchTerm, String productId) async {
    final docRef =
        FirebaseFirestore.instance.collection('searchHistory').doc(searchTerm);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        int newCount = (snapshot.data()?['count'] ?? 0) + 1;
        transaction.update(docRef, {'count': newCount});
      } else {
        transaction.set(docRef, {
          'searchTerm': searchTerm,
          'productId': productId,
          'count': 1,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
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
          capacity: productData['capacity'],
          details: Map<String, String>.from(productData["detail"]),
          description: productData['description'],
          water: productSnapshot['water'],
          length: productData['length'],
          breadth: productData['breadth'],
          photo: List<String>.from(productData['photo']),
          panoramaImg: productData['panoramaImg'],
          electricity: productData['electricity'],
          fohor: productData['fohor'],
          lat: productData['lat'],
          lng: productData['lng'],
          statusByAdmin: productData["statusByAdmin"],
          active: productData['active'],
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

  late Future<List<Room>> rooms;
  List<Room> filteredRooms = [];
  String searchQuery = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rooms = fetchRooms();
  }

  void updateFilteredRooms(String query) {
    setState(() {
      searchQuery = query;
    });
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

  @override
  Widget build(BuildContext context) {
    final pageProvider = Provider.of<PageProvider>(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 50.0, bottom: 18.0, left: 18.0, right: 18.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: kThemeColor,
                        backgroundImage: const NetworkImage(
                            "https://media.licdn.com/dms/image/D5603AQFD6ld3NWc2HQ/profile-displayphoto-shrink_200_200/0/1684164054868?e=2147483647&v=beta&t=cwQoyfhgAl_91URX5FTEXLwLDEHWe1H337EMebpgntQ"),
                      ),
                      Text("Home",
                          style: TextStyle(
                              color: kThemeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      IconButton(
                        icon: Badge.count(
                          count: 5,
                          child: Icon(
                            Icons.notifications_none_outlined,
                            color: kThemeColor,
                            size: 30,
                          ),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Find a property anywhere.",
                                style: TextStyle(
                                    color: Color(0xAA616161),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            IconButton(
                              icon: Icon(Icons.filter_list, color: Color(0xAA616161)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PriceRangeScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: searchController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_on_rounded,
                              color: kThemeColor,
                            ),
                            hintText: "Enter an address or room",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade600, fontSize: 16),
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                            labelStyle: const TextStyle(
                                color: Colors.grey, fontSize: 20),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                          onChanged: updateFilteredRooms,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kThemeColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            child: const Text(
                              "Search Now",
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: searchQuery.isNotEmpty,
                    child: SizedBox(
                      child: FutureBuilder<List<Room>>(
                        future: fetchRooms(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 3,
                                itemBuilder: (context, index) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                  ),
                                ),
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

                          List<Room> filteredRooms = snapshot.data!
                              .where((room) => room.name
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()))
                              .toList();
                          List<Room> sortedRooms = sortedRoomsByDistance(
                              filteredRooms, widget.lat, widget.lng);

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sortedRooms.length,
                            itemBuilder: (context, index) {
                              final room = sortedRooms[index];
                              return GestureDetector(
                                onTap: () {
                                  recordSearch(searchQuery, room.uid);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
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
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
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
                                              padding:
                                                  const EdgeInsets.all(16.0),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    room.locationName,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "${room.price}/ per month",
                                                    style: TextStyle(
                                                      color: kThemeColor,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .location_on_rounded,
                                                          size: 16,
                                                          color:
                                                              kThemeColor),
                                                      Text(
                                                        "${(sortedRooms[index].lat - widget.lat).abs().toStringAsFixed(1)} km from you.",
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .black45),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
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
                                                        '${room.status['statusDisplay'] ?? "To Buy"}',
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
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Most searched",
                        style: TextStyle(
                          color: Color(0xFF072A2E),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FutureBuilder<List<Room>>(
                        future: fetchMostSearchedProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              "Loading...",
                              style: TextStyle(
                                color: Color(0xFF072A2E),
                                fontSize: 16,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Text(
                              "Error",
                              style: TextStyle(
                                color: Color(0xFF072A2E),
                                fontSize: 16,
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Text(
                              "0 items",
                              style: TextStyle(
                                color: Color(0xFF072A2E),
                                fontSize: 16,
                              ),
                            );
                          }
                          // Display the count of items
                          final itemCount = snapshot.data!.length;
                          return Text(
                            "$itemCount items",
                            style: const TextStyle(
                              color: Color(0xFF072A2E),
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  FutureBuilder<List<Room>>(
                    future: fetchMostSearchedProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: SizedBox(
                            height: 500,
                            child: ListView.builder(
                              itemCount: 3,
                              itemBuilder: (context, index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No products found.'));
                      }
                      final displayedProducts = showAllMostSearch
                          ? snapshot.data!
                          : snapshot.data!.take(3).toList();
                      return Column(
                        children: [
                          ListView.builder(
                            itemCount: displayedProducts.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final product = displayedProducts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RoomDetailPage(room: product),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
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
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.horizontal(
                                              left: Radius.circular(16.0),
                                              right: Radius.circular(16.0),
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
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    product.name.toUpperCase(),
                                                    style: TextStyle(
                                                      color: kThemeColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    product.locationName,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "${product.price}/ per month",
                                                    style: TextStyle(
                                                      color: kThemeColor,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .location_on_rounded,
                                                        size: 16,
                                                        color: kThemeColor,
                                                      ),
                                                      Text(
                                                        "${(displayedProducts[index].lat - widget.lat).abs().toStringAsFixed(1)} km from you.",
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .black45),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          displayedProducts[index]
                                                              .status[
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
                                                        '${displayedProducts[index].status['statusDisplay'] ?? "To Buy"}',
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
                              );
                            },
                          ),
                          if (!showAllMostSearch && snapshot.data!.length > 3)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  pageProvider.setPage(1);
                                  pageProvider.setChoice("From homepage");
                                });
                              },
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  color: kThemeColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Suggested Near You",
                        style: TextStyle(
                          color: Color(0xFF072A2E),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FutureBuilder<List<Room>>(
                        future: fetchRooms(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              "Loading...",
                              style: TextStyle(
                                color: Color(0xFF072A2E),
                                fontSize: 14,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Text(
                              "Error",
                              style: TextStyle(
                                color: Color(0xFF072A2E),
                                fontSize: 14,
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Text(
                              "0 items",
                              style: TextStyle(
                                color: Color(0xFF072A2E),
                                fontSize: 14,
                              ),
                            );
                          }
                          final itemCount = snapshot.data!.length;
                          return Text(
                            "$itemCount items",
                            style: const TextStyle(
                              color: Color(0xFF072A2E),
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  FutureBuilder<List<Room>>(
                    future: fetchRooms(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: SizedBox(
                            height: 500,
                            child: ListView.builder(
                              itemCount: 3,
                              itemBuilder: (context, index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No rooms available.'));
                      }

                      // Filter the rooms based on statusDisplay
                      final filteredRooms1 = snapshot.data!.where((room) {
                        return room.status['statusDisplay'] == "Sold" ||
                            room.status['statusDisplay'] == "To Buy";
                      }).toList();

                      // Sort the filtered rooms by distance
                      List<Room> sortedRooms = sortedRoomsByDistance(
                          filteredRooms1, widget.lat, widget.lng);

                      // Show all or limit to first 3 based on a condition
                      sortedRooms = showAllNearYou
                          ? sortedRooms
                          : sortedRooms.take(3).toList();

                      log(sortedRooms.length.toString());

                      return Column(
                        children: [
                          ListView.builder(
                            itemCount: sortedRooms.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final room = sortedRooms[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RoomDetailPage(room: room),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
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
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
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
                                              padding:
                                                  const EdgeInsets.all(16.0),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    room.locationName,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "${room.price}/ per month",
                                                    style: TextStyle(
                                                      color: kThemeColor,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .location_on_rounded,
                                                          size: 16,
                                                          color:
                                                              kThemeColor),
                                                      Text(
                                                        "${(room.lat - widget.lat).abs().toStringAsFixed(1)} km from you.",
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .black45),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
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
                                                        color: kThemeColor,
                                                      ),
                                                      Text(
                                                        '${room.status['statusDisplay'] ?? "To Buy"}',
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
                              );
                            },
                          ),
                          if (!showAllNearYou && snapshot.data!.length > 3)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  pageProvider.setPage(1);
                                  pageProvider.setChoice("Suggested");
                                });
                              },
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  color: kThemeColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Popular",
                      style: TextStyle(
                        color: Color(0xFF072A2E),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FutureBuilder<List<Room>>(
                    future: fetchRooms(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 350,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3, // Number of shimmer items to show
                              itemBuilder: (context, index) => Container(
                                width: 200,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No rooms available'));
                      }

                      // Filter out rooms that have the 'status' key
                      final filteredRooms = snapshot.data!
                          .where((room) =>
                              !room.status.containsKey('statusDisplay'))
                          .toList();

                      if (filteredRooms.isEmpty) {
                        return const Center(child: Text('No rooms available'));
                      }

                      return Container(
                        height: 350,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredRooms.length,
                          itemBuilder: (context, index) {
                            final room = filteredRooms[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RoomDetailPage(room: room),
                                  ),
                                );
                              },
                              child: Container(
                                width: 200,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        room.photo.isNotEmpty
                                            ? room.photo[0]
                                            : '',
                                        width: 200,
                                        height: 350,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                        right: 10,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: kThemeColor),
                                          child: const Text("For Rent"),
                                          onPressed: () {},
                                        )),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              room.name.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_rounded,
                                                  color: Colors.white,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    room.locationName,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
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
                            );
                          },
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class PriceRangeScreen extends StatefulWidget {
  @override
  _PriceRangeScreenState createState() => _PriceRangeScreenState();
}

class _PriceRangeScreenState extends State<PriceRangeScreen> {
  RangeValues _currentRangeValues = RangeValues(0, 1000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Price Range'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Select Price Range',
              style: TextStyle(
                  color: Color(0xAA616161),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: 1000,
              divisions: 100, // Divides the slider into intervals
              labels: RangeLabels(
                _currentRangeValues.start.round().toString(),
                _currentRangeValues.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
            Text(
              'Price: \Rs.${_currentRangeValues.start.round()} - \Rs.${_currentRangeValues.end.round()}',
              style: TextStyle(
                  color: Color(0xAA616161),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              child: Text('Confirm'),
              onPressed: () {
                // Handle the confirmation of the selected price range
                print('Selected Price Range: ${_currentRangeValues.start} - ${_currentRangeValues.end}');
                Navigator.pop(context); // Go back to the previous screen
              },
            ),
          ],
        ),
      ),
    );
  }
}