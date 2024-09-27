import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/provider/wishlistProvider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:panorama/panorama.dart';
import 'package:provider/provider.dart';
import 'PanoramaFull.dart';
import 'model/onSaleModel.dart';

class RoomDetailPage extends StatefulWidget {
  final Room room;

  const RoomDetailPage({super.key, required this.room});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  bool _isBooking = false;
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
                  child:  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
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
                            //       GestureDetector(
                            //         onTap:(){
                            // Navigator.push(context,
                            // MaterialPageRoute(builder: (context) =>  PanoramaFullPage(room: widget.room)));
                            // },
                            //         child: Container(
                            //           height: 300, // Adjust height as necessary
                            //           decoration: BoxDecoration(
                            //             borderRadius: BorderRadius.circular(16.0), // Rounded corners
                            //             boxShadow: [
                            //               BoxShadow(
                            //                 color: Colors.black.withOpacity(0.2), // Shadow color
                            //                 spreadRadius: 2, // Spread radius
                            //                 blurRadius: 10, // Blur radius
                            //                 offset: Offset(0, 3), // Offset for the shadow
                            //               ),
                            //             ],
                            //             color: Colors.white, // Background color
                            //           ),
                            //           clipBehavior: Clip.hardEdge, // Clip child widgets to the rounded corners
                            //           child: Panorama(
                            //             animSpeed: 1.0,
                            //             sensorControl: SensorControl.Orientation,
                            //             child: Image.network(
                            //               widget.room.panoramaImg, // Use network image for panorama
                            //               fit: BoxFit.cover,
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            Text(
                              widget.room.name.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "${widget.room.price}/",
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
                            const SizedBox(height: 8),
                            Text(
                              widget.room.locationName,
                              style: const TextStyle(
                                  color: Color(0xFF4D4D4D),
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "1.5 km from Gwarko",
                              style: TextStyle(
                                  color: Color(0xFF4D4D4D),
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.grey),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.king_bed, color: Colors.black), // Icon for room
                                          const SizedBox(width: 8), // Space between icon and text
                                          Text(
                                            "Room: ${widget.room.roomLength}m x ${widget.room.roomBreath}m",
                                            style: const TextStyle(
                                              color: Color(0xFF4D4D4D),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.kitchen, color: Colors.black),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Kitchen: ${widget.room.kitchenLength}m x ${widget.room.kitchenbreadth}m",
                                            style: const TextStyle(
                                              color: Color(0xFF4D4D4D),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Hall dimensions
                                      Row(
                                        children: [
                                          const Icon(Icons.tv, color: Colors.black), // Icon for hall
                                          const SizedBox(width: 8),
                                          Text(
                                            "Hall: ${widget.room.hallLength}m x ${widget.room.hallBreadth}m",
                                            style: const TextStyle(
                                              color: Color(0xFF4D4D4D),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PanoramaFullPage(room: widget.room),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(15), // Adjust padding for a circular button
                                    decoration: BoxDecoration(
                                      color: kThemeColor, // Use your theme color
                                      shape: BoxShape.circle, // Circular shape
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2), // Shadow color
                                          blurRadius: 8, // Blur radius for the shadow
                                          offset: const Offset(0, 3), // Shadow offset
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min, // To wrap content within the circle
                                      mainAxisAlignment: MainAxisAlignment.center, // Center items in the circle
                                      children: const [
                                        Icon(
                                          Icons.threed_rotation, // 360 view icon
                                          color: Colors.white, // Icon color
                                          size: 30, // Increase icon size
                                        ),
                                      ],
                                    ),
                                  ),
                                )

                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.9, // Use 90% of screen width
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0), // Rounded corners for the image
                                  ),
                                  clipBehavior: Clip.hardEdge, // Clip the image to rounded corners
                                  child: mapImageUrl.isNotEmpty
                                      ? Image.network(
                                    mapImageUrl,
                                    width: MediaQuery.of(context).size.width, // Make the image full width
                                    height: 200, // Adjust the height to maintain the aspect ratio
                                    fit: BoxFit.cover, // Cover to ensure the image fills the container
                                  )
                                      : Image.network(
                                    "https://media.licdn.com/dms/image/D5603AQFD6ld3NWc2HQ/profile-displayphoto-shrink_200_200/0/1684164054868?e=2147483647&v=beta&t=cwQoyfhgAl_91URX5FTEXLwLDEHWe1H337EMebpgntQ",
                                    width: MediaQuery.of(context).size.width,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
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
                                        widget.room.status['statusDisplay'] ==
                                                "Owned"
                                            ? Icons.check_circle
                                            : Icons.flag_circle,
                                        size: 16,
                                        color: kThemeColor),
                                    Text(
                                      '${widget.room.status['statusDisplay'] ?? "To Buy"}',
                                      style: const TextStyle(
                                          color: Colors.black45),
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
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            if (widget.room.facilities.isNotEmpty) ...[
                              Center(
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children:
                                      widget.room.facilities.map((facility) {
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
                              visible:
                              !(widget.room.status["statusDisplay"] == "Sold" ||
                                  widget.room.status["statusDisplay"] == "Owned"),
                              child: SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: _bookRoom,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF072A2E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  child: const Text(
                                    "Book Now",
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
                      addToWishlist(widget.room);
                      // wishlistProvider.isInWishlist(widget.room) == true
                      //     ? wishlistProvider.removeFromWishlist(widget.room)
                      //     : wishlistProvider.addToWishlist(widget.room);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.bookmark,
                          color: wishlistProvider.isInWishlist(widget.room)
                              ? Colors.red
                              : kThemeColor),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addToWishlist(Room room) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      CollectionReference wishlistRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wishlist');

      await wishlistRef.doc(room.uid).set({
        'name': room.name,
        'capacity': room.capacity,
        'description': room.description,
        "price": room.price,
        "roomLength": room.roomLength,
        "roomBreadth": room.roomBreath,
        "hallLength": room.hallLength,
        "hallBreadth": room.hallBreadth,
        "kitchenLength": room.kitchenLength,
        "kitchenBreadth": room.kitchenbreadth,
        'photo': room.photo,
        'panoramaImg': room.panoramaImg,
        'electricity': room.electricity,
        'fohor': room.fohor,
        'lat': room.lat,
        'lng': room.lng,
        'active': room.active,
        'featured': room.featured,
        'locationName': room.locationName,
        'details': room.details,
        'status': room.status,
        'water': room.water,
        'isFavorite': room.isFavorite,
        "detail": room.details,
        "statusByAdmin": room.statusByAdmin,
        "facilities": room.facilities,
        "report": {},
      });
      Fluttertoast.showToast(
        msg: "Room added to wishlist successfully.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error adding room to wishlist: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _bookRoom() async {
    setState(() {
      _isBooking = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      Map<String, dynamic> newStatus = {
        'By': user?.displayName,
        'uId': user?.uid,
        'userEmail': user?.email,
        'statusDisplay': 'To Buy',
      };

      Map<String, dynamic> roomDetail = {
        "roomId": widget.room.uid,
        "name": widget.room.name,
        "capacity": widget.room.capacity,
        "description": widget.room.description,
        "roomLength": widget.room.roomLength,
        "roomBreadth": widget.room.roomBreath,
        "hallLength": widget.room.hallLength,
        "hallBreadth": widget.room.hallBreadth,
        "kitchenLength": widget.room.kitchenLength,
        "kitchenBreadth": widget.room.kitchenbreadth,
        "photo": List<String>.from(widget.room.photo),
        "panoramaImg": widget.room.panoramaImg,
        "electricity": widget.room.electricity,
        "fohor": widget.room.fohor,
        "lat": widget.room.lat,
        "lng": widget.room.lng,
        "locationName": widget.room.locationName,
        "status": 'To Buy'
      };

      await FirebaseFirestore.instance
          .collection('onSale')
          .doc(widget.room.uid)
          .update({'status': newStatus});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'rooms': FieldValue.arrayUnion([roomDetail]),
      });

      Fluttertoast.showToast(
        msg: 'Room Requested successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
      setState(() {
        _isBooking = false;
        widget.room.status = newStatus;
      });
    } catch (e) {
      // Fluttertoast.showToast(
      //   msg: 'Booking failed: $e',
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      //   backgroundColor: Colors.red,
      //   textColor: Colors.white,
      // );
      setState(() {
        _isBooking = false;
      });
    }
  }
}
