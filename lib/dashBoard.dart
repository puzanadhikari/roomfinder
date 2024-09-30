import 'dart:developer';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/provider/pageProvider.dart';
import 'package:meroapp/roomdetail.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'calculation.dart';
import 'model/onSaleModel.dart';
RangeValues _currentRangeValues = RangeValues(0, 100000);
double? startPrice=0.0;
double? endPrice=1000.0;
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371;
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final distance = R * c;
  return distance;
}

double _deg2rad(double deg) {
  return deg * (pi / 180);
}
class DashBoard extends StatefulWidget {
  double lat, lng;

  DashBoard(this.lat, this.lng, {super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {

  String? profilePhotoUrl;
  Future<void> _loadProfilePhoto() async {
    String? url = await getProfilePhotoUrl();
    setState(() {
      profilePhotoUrl = url;
    });
  }
  Future<String?> getProfilePhotoUrl() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userSnapshot['photoUrl'];
  }

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
        roomLength: data['roomLength'],
        roomBreath: data['roomBreadth'],
        hallBreadth: data['hallBreadth'],
        hallLength: data['hallLength'],
        kitchenbreadth: data['kitchenBreadth'],
        kitchenLength: data['kitchenLength'],
        photo: List<String>.from(data['photo']),
        statusByAdmin: data["statusByAdmin"],
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
          roomLength: productSnapshot['roomLength'],
          roomBreath: productSnapshot['roomBreadth'],
          hallBreadth: productSnapshot['hallBreadth'],
          hallLength: productSnapshot['hallLength'],
          kitchenbreadth: productSnapshot['kitchenBreadth'],
          kitchenLength: productSnapshot['kitchenLength'],
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
    _loadProfilePhoto();
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

  void _refreshPage() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageProvider = Provider.of<PageProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        _refreshPage();
        return false;
      },
      child: GestureDetector(
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
                          backgroundImage: profilePhotoUrl != null
                              ? NetworkImage(profilePhotoUrl!)
                              : const AssetImage('assets/pic1.jpg') as ImageProvider,
                        ),
                        Text("Home",
                            style: TextStyle(
                                color: kThemeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: kThemeColor,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.filter_list, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PriceRangeScreen(widget.lat, widget.lng),
                                ),
                              );
                            },
                            iconSize: 20,
                          ),
                        )
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
                          Text("Find a property anywhere.",
                              style: TextStyle(
                                  color: Color(0xAA616161),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
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
                            if (startPrice != null && endPrice != null) {
                              filteredRooms = filteredRooms
                                  .where((room) => room.price >= startPrice! && room.price <= endPrice!)
                                  .toList();
                            }
                            List<Room> sortedRooms = sortedRoomsByDistance(
                                filteredRooms, widget.lat, widget.lng);

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: sortedRooms.length,
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
                                                          "$distance km from you.",
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
                                                          room.status['statusDisplay'] == "To Buy" ? "Booked" : room.status['statusDisplay'] == "Sold" ? "Sold" : room.status['statusDisplay'] == "Owned" ? "Owned" : "To Buy",
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
                                          RoomDetailPage(room: room,distance: distance),
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
                    ),
                    FutureBuilder<List<Room>>(
                      future: fetchMostSearchedProducts(),  // Assuming this fetches the room data
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
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
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

                                // Calculate distance using Haversine formula
                                final distance = calculateDistance(
                                  widget.lat,
                                  widget.lng,
                                  product.lat,
                                  product.lng,
                                ).toStringAsFixed(1);  // Convert to a string with 1 decimal precision

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RoomDetailPage(room: product, distance: distance),
                                      ),
                                    );
                                  },
                                  child: Visibility(
                                    visible: product.status.isEmpty ||
                                        product.status['statusDisplay'] == "To Buy",
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
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius.horizontal(
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
                                                  padding: const EdgeInsets.all(16.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        product.name.toUpperCase(),
                                                        style: TextStyle(
                                                          color: kThemeColor,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        product.locationName,
                                                        style: TextStyle(
                                                          color: Colors.grey.shade700,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        "${product.price}/ per month",
                                                        style: TextStyle(
                                                          color: kThemeColor,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.location_on_rounded,
                                                            size: 16,
                                                            color: kThemeColor,
                                                          ),
                                                          Text(
                                                            "$distance km from you.",
                                                            style: const TextStyle(
                                                              color: Colors.black45,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            product.status['statusDisplay'] == "Owned"
                                                                ? Icons.check_circle
                                                                : Icons.flag_circle,
                                                            size: 16,
                                                            color: kThemeColor,
                                                          ),
                                                          Text(
                                                            product.status['statusDisplay'] == "To Buy" ? "Booked" : product.status['statusDisplay'] == "Sold" ? "Sold" : product.status['statusDisplay'] == "Owned" ? "Owned" : "To Buy",
                                                            style: const TextStyle(
                                                              color: Colors.black45,
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
                                  ),
                                );
                              },
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
                        TextButton(
                          onPressed: () {
                            setState(() {
                              // Implement your logic to view all rooms here
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
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                        List<Room> filteredRooms = snapshot.data!
                            .where((room) => room.name
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                            .toList();

                        // Sort the filtered rooms by distance
                        List<Room> sortedRooms = sortedRoomsByDistance(
                            filteredRooms, widget.lat, widget.lng);

                        // Show all or limit to first 3 based on a condition
                        sortedRooms = showAllNearYou
                            ? sortedRooms
                            : sortedRooms.take(3).toList();

                        return Column(
                          children: [
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
                                        builder: (context) => RoomDetailPage(room: room, distance: distance),
                                      ),
                                    );
                                  },
                                  child: Visibility(
                                    visible: room.status.isEmpty || room.status['statusDisplay'] == "To Buy",
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
                                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                                        "${room.price}/ per month",
                                                        style: TextStyle(
                                                          color: kThemeColor,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.location_on_rounded,
                                                              size: 16, color: kThemeColor),
                                                          Text(
                                                            "$distance km from you.",
                                                            style: const TextStyle(color: Colors.black45),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            room.status['statusDisplay'] == "Owned"
                                                                ? Icons.check_circle
                                                                : Icons.flag_circle,
                                                            size: 16,
                                                            color: kThemeColor,
                                                          ),
                                                          Text(
                                                            room.status['statusDisplay'] == "To Buy" ? "Booked" : room.status['statusDisplay'] == "Sold" ? "Sold" : room.status['statusDisplay'] == "Owned" ? "Owned" : "To Buy",
                                                            style: const TextStyle(color: Colors.black45),
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class PriceRangeScreen extends StatefulWidget {
  double lat, lng;

  PriceRangeScreen(this.lat, this.lng, {super.key});
  @override
  _PriceRangeScreenState createState() => _PriceRangeScreenState();
}

class _PriceRangeScreenState extends State<PriceRangeScreen> {


  Future<List<Room>> fetchRoomsForFilter() async {
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
        photo: List<String>.from(data['photo']),
        statusByAdmin: data["statusByAdmin"],
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        actionsIconTheme: IconThemeData(
          color: kThemeColor, // Color for the action icons
        ),
        backgroundColor: Colors.grey.shade200,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kThemeColor),
          onPressed: () {
            Navigator.pop(context); // Action to go back
          },
        ),
        title: Text(
          "Select Price Range",
          style: TextStyle(
            color: kThemeColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
              max: 100000,
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
                startPrice = _currentRangeValues.start;
                endPrice = _currentRangeValues.end;
                fetchRoomsForFilter();
                print('Selected Price Range: ${_currentRangeValues.start} - ${_currentRangeValues.end}');
                setState(() {

                });
                // Navigator.pop(context); // Go back to the previous screen
              },
            ),
            SizedBox(
              child: FutureBuilder<List<Room>>(
                future: fetchRoomsForFilter(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {

                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.isEmpty ||snapshot.data=="null") {
                    return const Center(
                        child: Text('No rooms available.'));
                  }
                  print("data:"+snapshot.data.toString());
                  List<Room> filteredRooms1 = [];

                 snapshot.data == null?"":  filteredRooms1  = snapshot.data!
                        .where((room) => room.price >= (startPrice??100.0)! && room.price <= (endPrice??1000.0)!)
                        .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredRooms1.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms1[index];
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
                                  RoomDetailPage(room: room,distance: distance),
                            ),
                          );
                        },
                        child: Visibility(
                          visible: room.status.isEmpty || room.status['statusDisplay']=="To Buy"?true:false,
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
                                                  "$distance km from you.",
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}