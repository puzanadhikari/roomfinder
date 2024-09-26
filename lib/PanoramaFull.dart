import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';

import 'model/onSaleModel.dart';

class PanoramaFullPage extends StatefulWidget {

  final Room? room;
   PanoramaFullPage({super.key,this.room});

  @override
  State<PanoramaFullPage> createState() => _PanoramaFullPageState();
}

class _PanoramaFullPageState extends State<PanoramaFullPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 500, // Adjust height as necessary
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              spreadRadius: 2, // Spread radius
              blurRadius: 10, // Blur radius
              offset: Offset(0, 3), // Offset for the shadow
            ),
          ],
          color: Colors.white, // Background color
        ),
        clipBehavior: Clip.hardEdge, // Clip child widgets to the rounded corners
        child: Panorama(
          animSpeed: 1.0,
          sensorControl: SensorControl.Orientation,
          child: Image.network(
            widget.room!.panoramaImg, // Use network image for panorama
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
