import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      await roomRef.update({'active': true});

      // Optionally, you can show a confirmation message or perform other actions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room approved successfully.')),
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
        .where('active', isEqualTo: false) // Query for inactive rooms
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Room(
          uid: doc.id,
          name: data['name'],
          capacity: data['capacity'],
          description: data['description'],
          length: data['length'],
          breadth: data['breadth'],
          photo: List<String>.from(data['photo']),
          panoramaImg: data['panoramaImg'],
          electricity: data['electricity'],
          fohor: data['fohor'],
          lat: data['lat'],
          lng: data['lng'],
          active: data['active'],
          featured: data['featured'],
          locationName: data['locationName'],
          status: data['status'] != null ? Map<String, dynamic>.from(data['status']) : {},
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
                        backgroundImage: NetworkImage(
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
                  Divider(color: Color(0xFFD9D6D6), height: 2, thickness: 1),
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
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      room.photo.isNotEmpty ? room.photo[0] : '',
                                      height: 150, // Adjust height as needed
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 150, color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    room.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: kThemeColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Capacity: ${room.capacity}', style: TextStyle(color: kThemeColor)),
                                  const SizedBox(height: 4),
                                  Text('Price: \$${room.fohor}', style: TextStyle(color: kThemeColor)),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kThemeColor,
                                      ),
                                      onPressed: () {
                                        approveRoom(room.uid);
                                      },
                                      child: const Text('Approve'),
                                    ),
                                  ),
                                ],
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
}