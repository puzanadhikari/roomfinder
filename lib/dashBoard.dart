import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:meroapp/Constants/styleConsts.dart';

class DashBoard extends StatefulWidget {
  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String fileName = '';
  String filePath = '';
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
      child: Scaffold(
        body: Stack(
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
              ),
            ),
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
                        value.visible ? Icons.clear : Icons.menu_open_outlined,
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
                onPressed: () {},
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
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
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
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: Duration(milliseconds: 400),
                  viewportFraction: 0.8,
                ),
                items: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Image.asset('assets/pic1.jpg', fit: BoxFit.cover),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Image.asset('assets/pic2.jpg', fit: BoxFit.cover),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Image.asset('assets/pic3.jpg', fit: BoxFit.cover),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return SafeArea(
      child: ListTileTheme(
        textColor: Colors.white,
        iconColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(left:20,top: 10,bottom:20.0),
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
              padding: const EdgeInsets.only(left:20,bottom:60.0),
              child: Text("Pujan Adhikari",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
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
              onTap: () {},
              leading: Icon(Icons.favorite_outlined),
              title: Text('Favourites'),
            ),
            ListTile(
              onTap: () {},
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
              onTap: () {
                Navigator.pop(context);
              },
              leading: Icon(Icons.logout),
              title: Text('Logout'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        fileName = file.name;
        filePath = file.path!;
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
}

