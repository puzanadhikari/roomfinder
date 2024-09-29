import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meroapp/provider/wishlistProvider.dart';
import 'package:meroapp/roomdetail.dart';
import 'package:provider/provider.dart';

import 'Constants/styleConsts.dart';

class WishlistPage extends StatefulWidget {
  double lat, lng;

  WishlistPage(this.lat, this.lng, {super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {

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

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    User? user = FirebaseAuth.instance.currentUser;
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
    String userId =user!.uid;
    await wishlistProvider.fetchWishlist(userId);
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey.shade200,
        title: Text(
          "Wishlist",
          style: TextStyle(
            color: kThemeColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.favorite,
                color: kThemeColor,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (wishlistProvider.wishlist.isEmpty)
                  const Center(
                    child: Text(
                      'Your wishlist is empty.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    itemCount: wishlistProvider.wishlist.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final room = wishlistProvider.wishlist[index];
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
                          visible: room.status.isEmpty||room.status['statusDisplay']=="Sold"?true:false,
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
                                                fontWeight:
                                                FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on_rounded,
                                                    size: 16,
                                                    color: kThemeColor),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
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
                                                      '${room.status['statusDisplay'] ?? "To Buy"}',
                                                      style: const TextStyle(
                                                          color:
                                                          Colors.black45),
                                                    ),
                                                  ],
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    removeFromWishlist(room.uid);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),  // Smooth, rounded corners
                                                      border: Border.all(color: Colors.grey),  // Simple border for a sleek look
                                                    ),
                                                    child: Text(
                                                      "Remove",
                                                      style: TextStyle(
                                                        color: Colors.grey[800],  // Neutral color for elegance
                                                        fontWeight: FontWeight.bold,  // Make the text bold for emphasis
                                                        fontSize: 12,  // Slightly larger text size for clarity
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
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
      ),
    );
  }
  Future<void> removeFromWishlist(String roomId) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference roomRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .doc(roomId);
      await roomRef.delete();
      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
      wishlistProvider.removeFromWishlistLocally(roomId);

      // Show success toast
      Fluttertoast.showToast(
        msg: "Room removed from wishlist successfully.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      // Show error toast
      Fluttertoast.showToast(
        msg: "Error removing room from wishlist: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

}
