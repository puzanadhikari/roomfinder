import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
      // Reference to the specific room document using the uid
      DocumentReference roomRef = FirebaseFirestore.instance.collection('onSale').doc(uid);

      // Update the active field to true
      await roomRef.update({
        'active': true,
        'statusByAdmin': 'Approved',
      });

      // Optionally, you can show a confirmation message or perform other actions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room approved successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving room: $e')),
      );
    }
  }
  Future<void> rejectRoom(String uid) async {
    try {
      // Reference to the specific room document using the uid
      DocumentReference roomRef = FirebaseFirestore.instance.collection('onSale').doc(uid);

      await roomRef.update({
        'active': false,
        'statusByAdmin': 'Rejected',
      });


      // Optionally, you can show a confirmation message or perform other actions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room approved successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving room: $e')),
      );
    }
  }

  Stream<List<Room>> fetchRooms() {
    return FirebaseFirestore.instance
        .collection('onSale')
        .where('active', isEqualTo: false).where("statusByAdmin",isEqualTo: "Pending")
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
          length: data['length'],
          breadth: data['breadth'],
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
                              fontSize: 25)),
                      IconButton(
                        icon: Icon(
                          Icons.notifications_none_outlined,
                          color: kThemeColor,
                          size: 30,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFD9D6D6), height: 2, thickness: 1),
                  const SizedBox(height: 10),
                  StreamBuilder<List<Room>>(
                    stream: fetchRooms(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: kThemeColor));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: kThemeColor)));
                      }

                      final rooms = snapshot.data ?? [];

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          return GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdminRoomDetails(room: room),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 6,
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
                                          color: Colors.grey.shade200,
                                          height: 150,
                                          width: double.infinity,
                                          child: const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      room.name.toUpperCase(),
                                      style: TextStyle(
                                        color: kThemeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      room.locationName,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "${room.price}/ per month",
                                      style: TextStyle(
                                        color: kThemeColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: kThemeColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                                            ),
                                            onPressed: () {
                                              _showApproveDialog(context, room.uid);
                                            },
                                            child: const Text('Approve'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                                            ),
                                            onPressed: () {
                                              _showRejectDialog(context, room.uid);
                                            },
                                            child: const Text('Reject'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _showApproveDialog(BuildContext context, String roomUid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Text(
          'Confirm Approval',
          style: TextStyle(color: kThemeColor, fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to approve this room?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              approveRoom(roomUid);
            },
            style: ElevatedButton.styleFrom(
              primary: kThemeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }
  void _showRejectDialog(BuildContext context, String roomUid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Text(
          'Confirm Rejection',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to reject this room?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              rejectRoom(roomUid);
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}