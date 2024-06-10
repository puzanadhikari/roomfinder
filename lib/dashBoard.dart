import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:meroapp/Constants/styleConsts.dart';

class DashBoard extends StatefulWidget {
  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            top: 70,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextFormField(
                controller: searchController,
                decoration: KFormFieldDecoration.copyWith(
                  prefixIcon: Icon(Icons.search),
                  hintText: "search",
                  labelStyle: TextStyle(color: Colors.grey,fontSize: 20),
                  fillColor: Colors.white,
                  filled: true
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
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
    );
  }
}
