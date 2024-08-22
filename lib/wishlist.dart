import 'package:flutter/material.dart';
import 'package:meroapp/provider/wishlistProvider.dart';
import 'package:provider/provider.dart';

import 'Constants/styleConsts.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    return Scaffold(
      appBar: AppBar(title:Text("Wishlist")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              itemCount: wishlistProvider.wishlist.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final room = wishlistProvider.wishlist[index];
                return GestureDetector(
                  onTap: (){

                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                              const BorderRadius.horizontal(
                                left: Radius.circular(16.0),
                                right: Radius.circular(16.0),
                              ),
                              child: Image.network(
                                room.photo.isNotEmpty
                                    ? room.photo[0]
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
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      room.name.toUpperCase(),
                                      style: TextStyle(
                                        color: kThemeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      room.locationName,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Capacity: ${room.capacity}",
                                      style: TextStyle(
                                        color: kThemeColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                                Icons
                                                    .location_on_rounded,
                                                size: 16,
                                                color: kThemeColor),
                                            // Text(
                                            //   "${(sortedRooms[index].lat - widget.lat).abs().toStringAsFixed(1)} km from you.",
                                            //   style: TextStyle(
                                            //       color: Colors
                                            //           .black45),
                                            // ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                size: 16,
                                                color: kThemeColor),
                                            Text(
                                              "Available",
                                              style: TextStyle(
                                                  color: Colors
                                                      .black45),
                                            )
                                          ],
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
                );
              },
            ),
          ],
        ),
      ),

    );
  }
}
