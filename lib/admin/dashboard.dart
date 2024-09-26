import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meroapp/admin/admin_room_details.dart';

import '../Constants/styleConsts.dart';
import '../model/onSaleModel.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  Future<void> approveRoom(String uid) async {
    try {
      DocumentReference roomRef = FirebaseFirestore.instance.collection('onSale').doc(uid);

      await roomRef.update({
        'active': true,
        'statusByAdmin': 'Approved',
      });

      Fluttertoast.showToast(
        msg: "Room approved successfully.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error approving room: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> rejectRoom(String uid) async {
    try {
      DocumentReference roomRef = FirebaseFirestore.instance.collection('onSale').doc(uid);

      await roomRef.update({
        'active': false,
        'statusByAdmin': 'Rejected',
      });
      Fluttertoast.showToast(
        msg: "Room rejected successfully.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error rejecting room: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Stream<List<Room>> fetchPendingRooms() {
    return FirebaseFirestore.instance
        .collection('onSale')
        .where('active', isEqualTo: false)
        .where("statusByAdmin", isEqualTo: "Pending")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Room(
          uid: doc.id,
          name: data['name'],
          price: data["price"],
          capacity: data['capacity'],
          description: data['description'],
          roomLength: data['roomLength'],
          roomBreath: data['roomBreadth'],
          hallBreadth: data['hallBreadth'],
          hallLength: data['hallLength'],
          kitchenbreadth: data['kitchenBreadth'],
          kitchenLength: data['kitchenLength'],
          water: doc['water'],
          photo: List<String>.from(data['photo']),
          panoramaImg: data['panoramaImg'],
          electricity: data['electricity'],
          fohor: data['fohor'],
          lat: data['lat'],
          lng: data['lng'],
          active: data['active'],
          featured: data['featured'],
          details: Map<String, String>.from(data["detail"]),
          locationName: data['locationName'],
          statusByAdmin: data["statusByAdmin"],
          status: data['status'] != null ? Map<String, dynamic>.from(data['status']) : {},
          report: data['report'] != null ? Map<String, dynamic>.from(data['report']) : {},
          facilities: data['facilities'] != null ? List<String>.from(data['facilities']) : [],
        );
      }).toList();
    });
  }

  Stream<List<Room>> fetchApprovedRooms() {
    return FirebaseFirestore.instance
        .collection('onSale')
        .where('statusByAdmin', isEqualTo: "Approved")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Room(
          uid: doc.id,
          name: data['name'],
          price: data["price"],
          capacity: data['capacity'],
          description: data['description'],
          roomLength: data['roomLength'],
          roomBreath: data['roomBreadth'],
          hallBreadth: data['hallBreadth'],
          hallLength: data['hallLength'],
          kitchenbreadth: data['kitchenBreadth'],
          kitchenLength: data['kitchenLength'],
          water: doc['water'],
          photo: List<String>.from(data['photo']),
          panoramaImg: data['panoramaImg'],
          electricity: data['electricity'],
          fohor: data['fohor'],
          lat: data['lat'],
          lng: data['lng'],
          active: data['active'],
          featured: data['featured'],
          details: Map<String, String>.from(data["detail"]),
          locationName: data['locationName'],
          statusByAdmin: data["statusByAdmin"],
          status: data['status'] != null ? Map<String, dynamic>.from(data['status']) : {},
          report: data['report'] != null ? Map<String, dynamic>.from(data['report']) : {},
          facilities: data['facilities'] != null ? List<String>.from(data['facilities']) : [],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 50.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFD9D6D6), height: 2, thickness: 1),
                  _buildRoomList(stream: fetchPendingRooms(), showApproveRejectButtons: true),
                  _buildRoomList(stream: fetchApprovedRooms(), showApproveRejectButtons: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
          icon: Icon(
            Icons.notifications_none_outlined,
            color: kThemeColor,
            size: 30,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildRoomList({
    required Stream<List<Room>> stream,
    required bool showApproveRejectButtons,
  }) {
    return StreamBuilder<List<Room>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: kThemeColor));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: kThemeColor)));
        }

        final rooms = snapshot.data ?? [];

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildRoomCard(room, showApproveRejectButtons),
            ); // Added bottom padding between cards
          },
        );
      },
    );
  }

  Widget _buildRoomCard(Room room, bool showApproveRejectButtons) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminRoomDetails(room: room),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 8, // Add more shadow for depth
        shadowColor: Colors.grey.shade200,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.grey.shade100, // Soft background color
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    room.photo.isNotEmpty ? room.photo[0] : '',
                    height: 150, // Adjust height as needed
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      height: 150,
                      width: double.infinity,
                      child: const Icon(Icons.image_not_supported,
                          size: 100, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  room.name.toUpperCase(),
                  style: TextStyle(
                    color: kThemeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Increase size
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  room.locationName,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rs.${room.price}/ per month",
                  style: TextStyle(
                    color: kThemeColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                if (showApproveRejectButtons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => approveRoom(room.uid),
                        child: const Text("Approve"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => rejectRoom(room.uid),
                        child: const Text("Reject"),
                      ),
                    ],
                  ),
                if (!showApproveRejectButtons)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kThemeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Approved"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}