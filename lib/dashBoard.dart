import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/profilePage.dart';
import 'package:meroapp/roomdetail.dart';
import 'package:meroapp/splashScreen.dart';
import 'package:meroapp/test.dart';
import 'package:meroapp/wishlistPage.dart';

import 'calculation.dart';
import 'cartPage.dart';
import 'model/onSaleModel.dart';

class DashBoard extends StatefulWidget {
  double lat,lng;
  DashBoard(this.lat,this.lng, {super.key});
  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String fileName = '';
  List<String> filePaths = [];
  String? pdfFilePath;
  TextEditingController searchController = TextEditingController();
  final _advancedDrawerController = AdvancedDrawerController();

  Future<List<Room>> fetchRooms() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('onSale')
        .where('active', isEqualTo: true) // Query for active rooms
        .get();

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
        locationName: data["locationName"],
        status: data['status'] != null ? Map<String, dynamic>.from(data['status']) : {},
      );
      
    }).toList();
    
  }
  Future<void> recordSearch(String searchTerm, String productId) async {
    final docRef = FirebaseFirestore.instance.collection('searchHistory').doc(searchTerm);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        int newCount = (snapshot.data()?['count'] ?? 0) + 1;
        transaction.update(docRef, {'count': newCount});
      } else {
        transaction.set(docRef, {
          'searchTerm': searchTerm,
          'productId': productId,
          'count': 1,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
  }
  Future<List<Room>> fetchMostSearchedProducts() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('searchHistory')
        .orderBy('count', descending: true)
        .limit(10)
        .get();

    List<Room> mostSearchedProducts = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final productId = data['productId'];

      final productSnapshot = await FirebaseFirestore.instance.collection('onSale').doc(productId).get();
      if (productSnapshot.exists) {
        final productData = productSnapshot.data() as Map<String, dynamic>;
        mostSearchedProducts.add(Room(
          uid: productSnapshot.id,
          name: productData['name'],
          capacity: productData['capacity'],
          description: productData['description'],
            length: productData['length'],
            breadth: productData['breadth'],
            photo: List<String>.from(productData['photo']),
            panoramaImg: productData['panoramaImg'],
            electricity: productData['electricity'],
            fohor: productData['fohor'],
            lat: productData['lat'],
            lng: productData['lng'],
            active: productData['active'],
            featured: productData['featured'],
            locationName: productData["locationName"],
          status: data['status'] != null ? Map<String, dynamic>.from(data['status']) : {},
        ));
      }
    }
    return mostSearchedProducts;
  }

  late Future<List<Room>> rooms;
  List<Room> filteredRooms = [];
  String searchQuery = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rooms = fetchRooms();
  }
  void updateFilteredRooms(String query) {
    setState(() {
      searchQuery = query;
    });
  }
  List<Room> sortedRoomsByDistance(List<Room> rooms, double userLat, double userLng) {
    rooms.sort((a, b) {
      double distanceA = haversineDistance(userLat, userLng, a.lat, a.lng);
      double distanceB = haversineDistance(userLat, userLng, b.lat, b.lng);
      return distanceA.compareTo(distanceB);
    });
    return rooms;
  }
  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Colors.blueGrey,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      openRatio: 0.75,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: _buildDrawer(),
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: ValueListenableBuilder<AdvancedDrawerValue>(
                          valueListenable: _advancedDrawerController,
                          builder: (_, value, __) {
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                value.visible ? Icons.clear : Icons.menu_open_outlined,
                                key: ValueKey<bool>(value.visible),
                                color: kThemeColor,
                                size: 30,
                              ),
                            );
                          },
                        ),
                        onPressed: () => _advancedDrawerController.showDrawer(),
                      ),
                      // Shopping Cart Button
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
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Find a property anywhere.",
                            style: TextStyle(
                                color: Color(0xFF616161),
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: searchController,
                          decoration: kFormFieldDecoration.copyWith(
                            hintText: "search",
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 20),
                            fillColor: Colors.grey.shade300,
                            filled: true,
                          ),
                          onChanged: updateFilteredRooms,
                        ),
                      ],
                    ),
                  ),

                  Visibility(
                    visible: searchQuery.isEmpty?false:true,
                    child: SizedBox(
                      height: 200,
                      child: FutureBuilder<List<Room>>(
                        future: fetchRooms(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No rooms available.'));
                          }

                          // Filter and sort rooms based on search query
                          List<Room> filteredRooms = snapshot.data!
                              .where((room) => room.name.toLowerCase().contains(searchQuery.toLowerCase()))
                              .toList();

                          // Sort the filtered rooms by distance
                          List<Room> sortedRooms = sortedRoomsByDistance(filteredRooms, widget.lat, widget.lng);

                          return ListView.builder(
                            itemCount: sortedRooms.length,
                            itemBuilder: (context, index) {
                              final room = sortedRooms[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: GestureDetector(
                                  onTap: (){
                                    recordSearch( searchQuery,  room.uid);
                                  },
                                  child: ListTile(
                                    title: Text(
                                      room.name,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Capacity: ${room.capacity}'),
                                    contentPadding: const EdgeInsets.all(8.0),
                                    tileColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      side: const BorderSide(color: Colors.grey, width: 0.5),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Most searched",
                        style: TextStyle(
                          color: kThemeColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200, // Set the height for the horizontal list
                    child: FutureBuilder<List<Room>>(
                      future: fetchMostSearchedProducts(), // Fetch the most searched products
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No products found.'));
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal, // Horizontal scroll
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final product = snapshot.data![index];
                            return Container(
                              width: 150, // Set width for each item
                              margin: const EdgeInsets.all(8.0),
                              child: Card(
                                child: Column(
                                  children: [
                                    product.photo.isNotEmpty
                                        ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                                      child: Image.network(
                                        product.photo[0],
                                        height: 100,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                        : Container(
                                      height: 100,
                                      width: 150,
                                      color: Colors.grey,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        product.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text('Capacity: ${product.capacity}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Suggested near you ",
                        style: TextStyle(
                          color: kThemeColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: FutureBuilder<List<Room>>(
                      future: fetchRooms(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No rooms available.'));
                        }

                        // Filter and sort rooms based on search query
                        List<Room> filteredRooms = snapshot.data!
                            .where((room) => room.name.toLowerCase().contains(searchQuery.toLowerCase()))
                            .toList();

                        // Sort the filtered rooms by distance
                        List<Room> sortedRooms = sortedRoomsByDistance(filteredRooms, widget.lat, widget.lng);

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: sortedRooms.length,
                          itemBuilder: (context, index) {
                            final room = sortedRooms[index];
                            return Container(
                              width: 150,
                              margin: const EdgeInsets.all(8.0),
                              child: Card(
                                child: Column(
                                  children: [
                                    room.photo.isNotEmpty
                                        ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                                      child: Image.network(
                                        room.photo[0],
                                        height: 100,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                        : Container(
                                      height: 100,
                                      width: 150,
                                      color: Colors.grey,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        room.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text('Capacity: ${room.capacity}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Popular",
                          style: TextStyle(
                            color: kThemeColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // pickFile();
                          },
                          child: Row(
                            children: const [
                              Text(
                                "See More",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
              FutureBuilder<List<Room>>(
                future: fetchRooms(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No rooms available'));
                  }

                  final rooms = snapshot.data!;

                  return SizedBox(
                    height: 200, // Set height for the card
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];

                        return GestureDetector(
                          onTap: () {
                            // Navigate to details page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RoomDetailPage(room: room),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 150,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(room.photo.isNotEmpty ? room.photo[0] : ''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        room.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Capacity: ${room.capacity}'),
                                      // You can add more details here if needed
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
                  const SizedBox(height: 20),
                  // Container(
                  //   height: 200,
                  //   child: NotificationListener<OverscrollIndicatorNotification>(
                  //     onNotification: (overscroll) {
                  //       overscroll.disallowGlow(); // This disables the glow effect
                  //       return true;
                  //     },
                  //     child: ListView.builder(
                  //       scrollDirection: Axis.horizontal,
                  //       itemCount: filePaths.length,
                  //       itemBuilder: (context, index) {
                  //         return Padding(
                  //           padding: const EdgeInsets.only(left: 20.0),
                  //           child: GestureDetector(
                  //             onTap: () {
                  //               Navigator.push(
                  //                 context,
                  //                 MaterialPageRoute(
                  //                   builder: (context) => FullScreenImage(
                  //                     imagePath: filePaths[index],
                  //                   ),
                  //                 ),
                  //               );
                  //             },
                  //             child: Container(
                  //               // height: 200,
                  //               // width: 100,
                  //               child: filePaths[index].isNotEmpty &&
                  //                       File(filePaths[index]).existsSync()
                  //                   ? Image.file(
                  //                       File(filePaths[index]),
                  //                       fit: BoxFit.fill,
                  //                     )
                  //                   : Container(), // Display an empty container if file path is invalid
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Text(
                  //         "Choose Pdf",
                  //         style: TextStyle(
                  //           color: kThemeColor,
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //       IconButton(
                  //         color: Colors.grey,
                  //         onPressed: () {
                  //           pickPdf();
                  //         },
                  //         icon: Icon(Icons.picture_as_pdf),
                  //       )
                  //     ],
                  //   ),
                  // ),
                  // Visibility(
                  //   visible: pdfFilePath != null,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       log("yes");
                  //       openFile(context, pdfFilePath!);
                  //     },
                  //     child: Text('Open'),
                  //     style: ElevatedButton.styleFrom(
                  //       primary: kThemeColor,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(15.0),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // if (pdfFilePath != null)
                  //   Container(
                  //     width: 100,
                  //     height: 150,
                  //     child: PDFView(
                  //       filePath: pdfFilePath,
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    User? user = FirebaseAuth.instance.currentUser;
    return SafeArea(
      child: ListTileTheme(
        textColor: Colors.white,
        iconColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 60.0),
              child: Text(
                user?.displayName ?? "Guest",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.recommend),
              title: const Text('Recommended'),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.star),
              title: const Text('Popular'),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.category_sharp),
              title: const Text('Categories'),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const WishlistPage()));
              },
              leading: const Icon(Icons.favorite_outlined),
              title: const Text('Favourites'),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const ProfilePage()));
              },
              leading: const Icon(Icons.account_balance_wallet_sharp),
              title: const Text('Accounts'),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
            ),
            const Spacer(),
            ListTile(
              onTap: _signOut,
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } catch (e) {
      log("Error signing out: $e");
    }
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        fileName = file.name;
        filePaths.add(file.path!); // Add new file path to the list
      });
      // Access file properties
      log('File name: ${file.name}');
      log('File path: ${file.path}');
      log('File size: ${file.size} bytes');
      log('File extension: ${file.extension}');

      // You can now use the selected file as needed
    } else {
      // User canceled the file picker
    }
  }

  void pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        pdfFilePath = file.path;
      });
      log('PDF name: ${file.name}');
      log('PDF path: ${file.path}');
      log('PDF size: ${file.size} bytes');
      log('PDF extension: ${file.extension}');
    } else {}
  }
}


void openFile(BuildContext context, String? filePath) {
  if (filePath != null) {
    File file = File(filePath);
    file.exists().then((exists) {
      if (exists) {
        // Navigate to the PDFViewerPage passing the file path
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerPage(pdfFilePath: filePath),
          ),
        );
      } else {
        log('File does not exist');
      }
    });
  }
}
class FullScreenImage extends StatelessWidget {
  final String imagePath;

   const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
