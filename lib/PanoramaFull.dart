import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';

import 'model/onSaleModel.dart';

class PanoramaFullPage extends StatefulWidget {
  final Room? room;
  PanoramaFullPage({super.key, this.room});

  @override
  State<PanoramaFullPage> createState() => _PanoramaFullPageState();
}

class _PanoramaFullPageState extends State<PanoramaFullPage> {
  bool isInfoVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Panorama view taking full screen
          Panorama(
            animSpeed: 1.0,
            sensorControl: SensorControl.Orientation,
            child: Image.network(
              widget.room!.panoramaImg,
              fit: BoxFit.cover,
            ),
          ),
          // Overlay for top bar (Back button & Title)
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Room title (optional)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.room!.name ?? 'Room Panorama',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Information overlay for additional details
          if (isInfoVisible)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Room Dimensions: ${widget.room!.roomLength}m x ${widget.room!.roomBreath}m",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Kitchen: ${widget.room!.kitchenLength}m x ${widget.room!.kitchenbreadth}m",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Hall: ${widget.room!.hallLength}m x ${widget.room!.hallBreadth}m",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Toggle button for info visibility
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isInfoVisible = !isInfoVisible;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isInfoVisible ? Icons.info_outline : Icons.info,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}