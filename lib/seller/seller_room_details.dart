import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/provider/wishlistProvider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../model/onSaleModel.dart';

class SellerRoomDetails extends StatefulWidget {
  final Room room;

  const SellerRoomDetails({super.key, required this.room, List<Room>? status});

  @override
  State<SellerRoomDetails> createState() => _SellerRoomDetailsState();
}

class _SellerRoomDetailsState extends State<SellerRoomDetails> {
  final bool _isBooking = false;
  final String _mapApiKey = 'AIzaSyAGFdLuw0m2pCFxNxmFA5EzJia6IzUM3iU';

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    log(wishlistProvider.isInWishlist(widget.room).toString());
    List<String> allImages = widget.room.photo;
    final double carouselHeight = MediaQuery.of(context).size.height / 3;
    String mapImageUrl = 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=${widget.room.lat},${widget.room.lng}&'
        'zoom=15&size=800x300&markers=color:red%7C${widget.room.lat},${widget.room.lng}&'
        'key=$_mapApiKey';

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _isBooking,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              SizedBox(
                height: carouselHeight,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: carouselHeight,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: true,
                  ),
                  items: allImages.map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              Positioned(
                  top: 50,
                  left: 10,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 30,
                    ),
                  )),
              Positioned(
                top: carouselHeight - 30,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child:
                    NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.room.name.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text("${widget.room.price}/",
                                  style: TextStyle(
                                      color: kThemeColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  "per month",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "1.5 km from Gwarko",
                                        style: TextStyle(
                                            color: Color(0xFF4D4D4D),
                                            fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        widget.room.locationName,
                                        style: const TextStyle(
                                            color: Color(0xFF4D4D4D),
                                            fontSize: 16),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        "Dimension: ${widget.room.length} * ${widget.room.breadth}",
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                    MediaQuery.of(context).size.width *
                                        0.4, // Adjust as needed
                                  ),
                                  child: mapImageUrl.isNotEmpty
                                      ? Image.network(
                                    mapImageUrl,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                      : Image.network(
                                      "https://media.licdn.com/dms/image/D5603AQFD6ld3NWc2HQ/profile-displayphoto-shrink_200_200/0/1684164054868?e=2147483647&v=beta&t=cwQoyfhgAl_91URX5FTEXLwLDEHWe1H337EMebpgntQ"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            const Divider(
                                color: Colors.black54, height: 2, thickness: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "Electricity",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: kThemeColor,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "NPR.${widget.room.electricity}",
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "Water",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: kThemeColor,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "NPR.${widget.room.water}",
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "Wastes",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: kThemeColor,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "NPR.${widget.room.fohor}",
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(
                                color: Colors.black54, height: 2, thickness: 1),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Description",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                       widget.room
                                            .status[
                                        'statusDisplay'] ==
                                            "Owned"
                                            ? Icons
                                            .check_circle
                                            : Icons
                                            .flag_circle,
                                        size: 16,
                                        color: kThemeColor),
                                    Text(
                                      '${ widget.room.status['statusDisplay'] ?? "To Buy"}',
                                      style: const TextStyle(
                                          color:
                                          Colors.black45),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(widget.room.description),
                            const SizedBox(height: 30),
                            const Text(
                              "Facilities",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            if (widget.room.facilities.isNotEmpty) ...[
                              Center(
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: widget.room.facilities.map((facility) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check, color: kThemeColor),
                                        const SizedBox(width: 4),
                                        Text(facility),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ] else ...[
                              const Text("No facilities available"),
                            ],
                            const SizedBox(height: 20),
                            Visibility(
                              visible: widget.room.status["statusDisplay"] == "To Buy",
                              child: SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: (){
                                    _approveRoomStatus(widget.room.uid, widget.room);
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF072A2E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  child: const Text(
                                    "Approve",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  right: 40,
                  top: carouselHeight - 50,
                  child: GestureDetector(
                    onTap: () {
                      // wishlistProvider.isInWishlist(widget.room) == true
                      //     ? wishlistProvider.removeFromWishlist(widget.room)
                      //     : wishlistProvider.addToWishlist(widget.room);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.bookmark,
                          color: kThemeColor),
                    ),
                  ))
            ],
          ),
        ),
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

      Fluttertoast.showToast(
        msg: "Room status updated to Sold!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      setState(() {
        room.status = newStatus;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update status: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
