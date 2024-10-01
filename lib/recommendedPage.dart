import 'package:flutter/material.dart';
import 'package:meroapp/roomdetail.dart';
import 'Constants/styleConsts.dart';
import 'dashBoard.dart';
import 'model/onSaleModel.dart';

class RecommendedRoomsPage extends StatelessWidget {
  final List<Room> recommendations;
  final double userLat;
  final double userLng;

  const RecommendedRoomsPage({
    Key? key,
    required this.recommendations,
    required this.userLat,
    required this.userLng,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: kThemeColor,
        ),
        backgroundColor: Colors.grey.shade200,
        title: Text(
          "Recommended Rooms",
          style: TextStyle(
            color: kThemeColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: recommendations.isEmpty
          ? const Center(
        child: Text('No recommended rooms to show.'),
      )
          : ListView.builder(
        itemCount: recommendations.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final product = recommendations[index];

          // Calculate distance using Haversine formula
          final distance = calculateDistance(
            userLat,
            userLng,
            product.lat,
            product.lng,
          ).toStringAsFixed(1); // Convert to a string with 1 decimal precision

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomDetailPage(
                    room: product,
                    distance: distance,
                  ),
                ),
              );
            },
            child: Visibility(
              visible: product.status.isEmpty,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16.0),
                            right: Radius.circular(16.0),
                          ),
                          child: Image.network(
                            product.photo.isNotEmpty
                                ? product.photo[0]
                                : 'https://via.placeholder.com/150',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product.name.toUpperCase(),
                                  style: TextStyle(
                                    color: kThemeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.locationName,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${product.price}/ per month",
                                  style: TextStyle(
                                    color: kThemeColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 16,
                                      color: kThemeColor,
                                    ),
                                    Text(
                                      "$distance km from you.",
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      product.status['statusDisplay'] == "Owned"
                                          ? Icons.check_circle
                                          : Icons.flag_circle,
                                      size: 16,
                                      color: kThemeColor,
                                    ),
                                    Text(
                                      product.status['statusDisplay'] == "To Buy"
                                          ? "Booked"
                                          : product.status['statusDisplay'] == "Sold"
                                          ? "Sold"
                                          : product.status['statusDisplay'] == "Owned"
                                          ? "Owned"
                                          : "To Buy",
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
