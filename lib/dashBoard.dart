import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:meroapp/Constants/styleConsts.dart';
import 'package:meroapp/profilePage.dart';
import 'package:meroapp/splashScreen.dart';
import 'package:meroapp/test.dart';
import 'package:meroapp/wishlistPage.dart';

import 'cartPage.dart';

class DashBoard extends StatefulWidget {
  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final List<String> imageUrls = [
    "https://econtent.o2.co.uk/o/econtent/media/get/43f82c83-69ec-480d-82b5-3fef330f2a0b",
    "https://m.media-amazon.com/images/I/61voYsPhFTL._AC_SL1500_.jpg",
    "https://i02.appmifile.com/504_operatorx_operatorx_xm/08/01/2024/fb199e5433ffcbcc38eeff0042fe0fbe.jpg",
    "https://images-cdn.ubuy.co.in/633b88f09d0e14619a371557-oneplus-nord-n200-5g-unlocked-android.jpg",
    "https://www.apple.com/v/iphone/home/bu/images/meta/iphone__ky2k6x5u6vue_og.png",
    "https://images.samsung.com/is/image/samsung/p6pim/uk/2401/gallery/uk-galaxy-s24-ultra-491396-sm-s928bztpeub-thumb-539464063",
    "https://image.oppo.com/content/dam/oppo/product-asset-library/specs/a78-4g/a78-bg.png",
    "https://asia-exstatic-vivofs.vivo.com/PSee2l50xoirPK7y/1687938111308/4347f794c401b874b7a314efe168da68.png",
    "https://i05.appmifile.com/175_item_fr/12/05/2023/deca984ab02cfffd8e52cb58683005da!400x400!85.png",
    "https://m.media-amazon.com/images/I/61jJeZBliWL._AC_SL1000_.jpg",
  ];
  final List<String> names = [
    "iPhone 13",
    "Redmi",
    "Poco",
    "One Plus",
    "iPhone 14",
    "Samsung",
    "Motorola",
    "Huwaei",
    "Oppo",
    "Vivo",
  ];
  String fileName = '';
  List<String> filePaths = [];
  String? pdfFilePath;
  TextEditingController searchController = TextEditingController();
  final _advancedDrawerController = AdvancedDrawerController();

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
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Stack(
                    children: [
                      Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: MediaQuery.of(context).size.height / 4,
                            decoration: BoxDecoration(
                              color: kThemeColor,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(50.0),
                                bottomLeft: Radius.circular(50.0),
                              ),
                            ),
                          )),
                      Positioned(
                        top: 40,
                        left: 20,
                        child: IconButton(
                          icon: ValueListenableBuilder<AdvancedDrawerValue>(
                            valueListenable: _advancedDrawerController,
                            builder: (_, value, __) {
                              return AnimatedSwitcher(
                                duration: Duration(milliseconds: 250),
                                child: Icon(
                                  value.visible
                                      ? Icons.clear
                                      : Icons.menu_open_outlined,
                                  key: ValueKey<bool>(value.visible),
                                  color: Colors.white,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                          onPressed: () => _advancedDrawerController.showDrawer(),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
                          },
                        ),
                      ),
                      Positioned(
                        top: 90,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Text(
                            "Discover",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 120,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: TextFormField(
                            controller: searchController,
                            decoration: KFormFieldDecoration.copyWith(
                              suffixIcon: Icon(Icons.search, size: 30),
                              hintText: "search",
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 200,
                        left: 0,
                        right: 0,
                        child: CarouselSlider(
                          options: CarouselOptions(
                            enlargeCenterPage: true,
                            autoPlay: true,
                            aspectRatio: 16 / 10,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 400),
                            viewportFraction: 0.8,
                          ),
                          items: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.network('https://econtent.o2.co.uk/o/econtent/media/get/43f82c83-69ec-480d-82b5-3fef330f2a0b', fit: BoxFit.cover),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.network('https://i02.appmifile.com/504_operatorx_operatorx_xm/08/01/2024/fb199e5433ffcbcc38eeff0042fe0fbe.jpg', fit: BoxFit.cover),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.network('https://images.samsung.com/is/image/samsung/p6pim/uk/2401/gallery/uk-galaxy-s24-ultra-491396-sm-s928bztpeub-thumb-539464063', fit: BoxFit.cover),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Categories",
                      style: TextStyle(
                        color: kThemeColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 100.0,
                  margin: EdgeInsets.symmetric(vertical:.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(10, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30.0,
                                backgroundColor: Colors.green.shade300,
                                backgroundImage: NetworkImage(imageUrls[index]),
                              ),
                              Text(names[index]),
                            ],
                          ),
                        );
                      }),
                    ),
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
                          pickFile();
                        },
                        child: Container(
                          child: Row(
                            children: [
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
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 200,
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowGlow(); // This disables the glow effect
                      return true;
                    },
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filePaths.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImage(
                                    imagePath: filePaths[index],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              // height: 200,
                              // width: 100,
                              child: filePaths[index].isNotEmpty &&
                                      File(filePaths[index]).existsSync()
                                  ? Image.file(
                                      File(filePaths[index]),
                                      fit: BoxFit.fill,
                                    )
                                  : Container(), // Display an empty container if file path is invalid
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Choose Pdf",
                        style: TextStyle(
                          color: kThemeColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        color: Colors.grey,
                        onPressed: () {
                          pickPdf();
                        },
                        icon: Icon(Icons.picture_as_pdf),
                      )
                    ],
                  ),
                ),
                Visibility(
                  visible: pdfFilePath != null,
                  child: ElevatedButton(
                    onPressed: () {
                      log("yes");
                      openFile(context, pdfFilePath!);
                    },
                    child: Text('Open'),
                    style: ElevatedButton.styleFrom(
                      primary: kThemeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                ),
                if (pdfFilePath != null)
                  Container(
                    width: 100,
                    height: 150,
                    child: PDFView(
                      filePath: pdfFilePath,
                    ),
                  ),
              ],
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
              padding: const EdgeInsets.only(left: 20, top: 10, bottom: 20.0),
              child: Container(
                width: 128.0,
                height: 128.0,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Image.asset('assets/ecommerce.png'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 60.0),
              child: Text(
                user?.displayName ?? "Guest",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.recommend),
              title: Text('Recommended'),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.star),
              title: Text('Popular'),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.category_sharp),
              title: Text('Categories'),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>WishlistPage()));
              },
              leading: Icon(Icons.favorite_outlined),
              title: Text('Favourites'),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage()));
              },
              leading: Icon(Icons.account_balance_wallet_sharp),
              title: Text('Accounts'),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
            Spacer(),
            ListTile(
              onTap: _signOut,
              leading: Icon(Icons.logout),
              title: Text('Logout'),
            ),
            SizedBox(height: 16),
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
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } catch (e) {
      print("Error signing out: $e");
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
        print('File does not exist');
      }
    });
  }
}
class FullScreenImage extends StatelessWidget {
  final String imagePath;

  FullScreenImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
