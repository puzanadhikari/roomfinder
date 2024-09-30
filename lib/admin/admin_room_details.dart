import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/provider/wishlistProvider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../PanoramaFull.dart';
import '../model/onSaleModel.dart';

class AdminRoomDetails extends StatefulWidget {
  final Room room;

  const AdminRoomDetails({super.key, required this.room, List<Room>? status});

  @override
  State<AdminRoomDetails> createState() => _AdminRoomDetailsState();
}

class _AdminRoomDetailsState extends State<AdminRoomDetails> {
  final bool _isBooking = false;
  final String _mapApiKey = 'AIzaSyAGFdLuw0m2pCFxNxmFA5EzJia6IzUM3iU';

  Future<void> _openGoogleMap(String lat, String lng) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final Uri url = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

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
                                  color: Color(0xFF4D4D4D), fontSize: 16),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.king_bed,
                                              color: Colors.black),
                                          // Icon for room
                                          const SizedBox(width: 8),
                                          // Space between icon and text
                                          Text(
                                            "Room: ${widget.room.roomLength}ft x ${widget.room.roomBreath}ft",
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
                                          const Icon(Icons.kitchen,
                                              color: Colors.black),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Kitchen: ${widget.room.kitchenLength}ft x ${widget.room.kitchenbreadth}ft",
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
                                          const Icon(Icons.tv,
                                              color: Colors.black),
                                          // Icon for hall
                                          const SizedBox(width: 8),
                                          Text(
                                            "Hall: ${widget.room.hallLength}ft x ${widget.room.hallBreadth}ft",
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
                                        builder: (context) =>
                                            PanoramaFullPage(room: widget.room),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    // Adjust padding for a circular button
                                    decoration: BoxDecoration(
                                      color: kThemeColor,
                                      // Use your theme color
                                      shape: BoxShape.circle,
                                      // Circular shape
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          // Shadow color
                                          blurRadius: 8,
                                          // Blur radius for the shadow
                                          offset: const Offset(
                                              0, 3), // Shadow offset
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      // To wrap content within the circle
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      // Center items in the circle
                                      children: const [
                                        Icon(
                                          Icons.threed_rotation,
                                          // 360 view icon
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
                                  maxWidth: MediaQuery.of(context).size.width *
                                      0.9, // Use 90% of screen width
                                ),
                                child: GestureDetector(
                                  onTap: () => _openGoogleMap(
                                      widget.room.lat.toString(),
                                      widget.room.lng.toString()),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          16.0), // Rounded corners for the image
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    // Clip the image to rounded corners
                                    child: mapImageUrl.isNotEmpty
                                        ? Image.network(
                                            mapImageUrl,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            // Make the image full width
                                            height: 200,
                                            // Adjust the height to maintain the aspect ratio
                                            fit: BoxFit
                                                .cover, // Cover to ensure the image fills the container
                                          )
                                        : Image.network(
                                            "https://media.licdn.com/dms/image/D5603AQFD6ld3NWc2HQ/profile-displayphoto-shrink_200_200/0/1684164054868?e=2147483647&v=beta&t=cwQoyfhgAl_91URX5FTEXLwLDEHWe1H337EMebpgntQ",
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
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
                            const SizedBox(height: 30),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Seller Details",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color(0xFF072A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  buildDetailRow(Icons.person, "Name:",
                                      widget.room.details["sellerName"]),
                                  const SizedBox(height: 10),
                                  buildDetailRow(Icons.email, "Email:",
                                      widget.room.details["sellerEmail"]),
                                  const SizedBox(height: 10),
                                  buildDetailRow(Icons.phone, "Phone No:",
                                      widget.room.details["sellerPhone"]),
                                ],
                              ),
                            )
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
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.bookmark, color: kThemeColor),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(IconData icon, String title, String? value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Color(0xFF072A2E), // Themed color for icons
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "$title  ${value ?? 'N/A'}",
            style: TextStyle(
              color: Colors.grey.shade900,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
