import 'package:flutter/material.dart';

import 'package:panorama/panorama.dart';
import 'model/onSaleModel.dart';

class RoomDetailPage extends StatefulWidget {
  final Room room;

  RoomDetailPage({required this.room});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  @override
  Widget build(BuildContext context) {
    // Combine panorama image with the other images
    List<String> allImages = widget.room.photo;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image slider
            Container(
              height: 250, // Adjust height as necessary
              child: PageView.builder(
                itemCount: allImages.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    allImages[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Decorated panorama image
            Container(
              height: 300, // Adjust height as necessary
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
                child: Image.network(
                  widget.room.panoramaImg, // Use network image for panorama
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 16),
            Text('Description: ${widget.room.description}'),
            Text('Capacity: ${widget.room.capacity}'),
            Text('Electricity: ${widget.room.electricity}'),
            Text('Fohor: ${widget.room.fohor}'),
            Text('Location: (${widget.room.lat}, ${widget.room.lng})'),
            Text('Location Name: (${widget.room.locationName}, ${widget.room.locationName})'),
            // Add more details as necessary
          ],
        ),
      ),
    );
  }
}
