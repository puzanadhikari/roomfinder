import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
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
                icon: Icon(Icons.arrow_back_ios,color: Colors.white,size: 30,),
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
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Rs. 8000 /",
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "1.5 km from Gwarko",
                                        style: TextStyle(color: Color(0xFF4D4D4D), fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        widget.room.locationName,
                                        style: const TextStyle(color: Color(0xFF4D4D4D), fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.4, // Adjust as needed
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
                              children: [
                                Text(
                                  '${widget.room.capacity} BHK',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54),
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
                                      Icons.do_not_disturb_on_total_silence,
                                      size: 16,
                                      color: kThemeColor,
                                    ),
                                    const Text(
                                      "Available",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black45),
                                    )
                                  ],
                                )
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check, color: kThemeColor),
                                    Text("Attach Bathroom")
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.check, color: kThemeColor),
                                    Text("1 Big Hall")
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check, color: kThemeColor),
                                    Text("Bikes and Car Parking")
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.check, color: kThemeColor),
                                    Text("24/7 water Facilities")
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: _bookRoom,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF072A2E),
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
                  ))
            ],
          ),
        ),
      ),
    );
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
        'length': widget.room.length,
        "breadth": widget.room.breadth,
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

      setState(() {
        _isBooking = false;
        widget.room.status = newStatus;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Booking failed: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      setState(() {
        _isBooking = false;
      });
    }
  }
}
