import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import 'model/onSaleModel.dart'; // Make sure to adjust the import based on your project structure

class PanoramaFullPage extends StatefulWidget {
  final Room room; // Room object containing details

  PanoramaFullPage({super.key, required this.room});

  @override
  State<PanoramaFullPage> createState() => _PanoramaFullPageState();
}

class _PanoramaFullPageState extends State<PanoramaFullPage> {
  bool isInfoVisible = true;
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for panorama images
          PageView.builder(
            controller: _pageController,
            itemCount: widget.room.panoramaImg.length, // Use panoramaImg from Room
            itemBuilder: (context, index) {
              return Panorama(
                animSpeed: 1.0,
                sensorControl: SensorControl.Orientation,
                child: Image.network(
                  widget.room.panoramaImg[index], // Use panorama images from Room
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
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
                    widget.room.name, // Display room name
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
                      "Room Dimensions: ${widget.room.roomLength}ft x ${widget.room.roomBreath}ft",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Kitchen: ${widget.room.kitchenLength}ft x ${widget.room.kitchenbreadth}ft",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Hall: ${widget.room.hallLength}ft x ${widget.room.hallBreadth}ft",
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
          // Navigation arrows for panorama images
          Positioned(
            left: 16,
            top: MediaQuery.of(context).size.height / 2 - 20,
            child: GestureDetector(
              onTap: () {
                // Go to the previous page
                if (_pageController.page!.toInt() > 0) {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_left,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height / 2 - 20,
            child: GestureDetector(
              onTap: () {
                // Go to the next page
                if (_pageController.page!.toInt() < (widget.room.panoramaImg.length - 1)) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_right,
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