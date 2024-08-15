import 'package:flutter/material.dart';
import 'package:meroapp/seller/createRoom.dart';

import 'enquiries.dart';
import 'myOpenings.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateRoom()));
            }, child: Text("Create")
            ),
            ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MyListingsPage()));
                }, child: Text("My Openings")
            ),
            ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>EnquiriesPage()));
                }, child: Text("Enquiries")
            ),
          ],
        ),
      ),
    );
  }
}
