import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/onSaleModel.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
      ),
      body: StreamBuilder<List<Room>>(
        stream: fetchRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rooms = snapshot.data ?? [];

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the first image
                      Image.network(
                        room.photo.isNotEmpty ? room.photo[0] : '',
                        height: 150, // Adjust height as needed
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        room.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Capacity: ${room.capacity}'),
                      const SizedBox(height: 4),
                      Text('Price: \$${room.fohor}'), // Assuming fohor is the price
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          approveRoom(room.uid);
                        },
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> approveRoom(String uid) async {
    try {
      // Reference to the specific room document using the uid
      DocumentReference roomRef = FirebaseFirestore.instance.collection('onSale').doc(uid);

      // Update the active field to true
      await roomRef.update({'active': true});

      // Optionally, you can show a confirmation message or perform other actions
      print('Room approved successfully.');
    } catch (e) {
      print('Error approving room: $e'); // Log the error
    }
  }
}
