import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/onSaleModel.dart';

class WishlistProvider extends ChangeNotifier {
  List<Room> _wishlist = [];

  List<Room> get wishlist => _wishlist;

  void addToWishlist(Room room) {
    room.toggleFavorite();
    _wishlist.add(room);
    notifyListeners();
  }

  void removeFromWishlistLocally(String roomId) {
    wishlist.removeWhere((room) => room.uid == roomId);
    notifyListeners();
  }

  bool isInWishlist(Room room) {
    return _wishlist.contains(room);
  }
  Future<void> fetchWishlist(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .get();

      _wishlist = snapshot.docs.map((doc) {
        return Room(
          uid: doc.id,
          name: doc['name'],
          price: doc["price"],
          capacity: doc['capacity'],
          description: doc['description'],
          roomLength: doc['roomLength'],
          roomBreath: doc['roomBreadth'],
          hallBreadth: doc['hallBreadth'],
          hallLength: doc['hallLength'],
          kitchenbreadth: doc['kitchenBreadth'],
          kitchenLength: doc['kitchenLength'],
          photo: List<String>.from(doc['photo']),
          panoramaImg: List<String>.from(doc['panoramaImg']),
          electricity: doc['electricity'],
          fohor: doc['fohor'],
          water: doc['water'],
          lat: doc['lat'],
          lng: doc['lng'],
          active: doc['active'],
          featured: doc['featured'],
          details: Map<String, String>.from(doc["detail"]),
          locationName: doc['locationName'],
          statusByAdmin: doc["statusByAdmin"],
          status: doc['status'] != null ? Map<String, dynamic>.from(doc['status']) : {},
          report: doc['report'] != null ? Map<String, dynamic>.from(doc['report']) : {},
          facilities: doc['facilities'] != null ? List<String>.from(doc['facilities']) : [],
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      log('Failed to fetch wishlist: $e');
    }
  }
}
