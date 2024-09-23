import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meroapp/provider/wishlistProvider.dart';
import 'package:provider/provider.dart';

import 'Constants/styleConsts.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
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
            fontSize: 25,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Colors.redAccent,
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
                  Center(
                    child: Text(
                      'Your wishlist is empty.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
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
                      return GestureDetector(
                        onTap: () {},
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
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.location_on_rounded,
                                                      size: 16,
                                                      color: kThemeColor),
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
                                                        color: Colors.black45),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                              onTap: (){
                                                removeFromWishlist(room.uid);
                                              },
                                              child: Text("Remove"))
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
