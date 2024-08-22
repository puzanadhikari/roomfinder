import 'package:flutter/material.dart';
import '../model/onSaleModel.dart';
import 'model/itemModelForWishlist.dart';


class WishlistProvider extends ChangeNotifier {
  List<Room> _wishlist = [];

  List<Room> get wishlist => _wishlist;

  void addToWishlist(Room room) {
    room.toggleFavorite();
    _wishlist.add(room);
    notifyListeners();
  }

  void removeFromWishlist(Room room) {
    room.toggleFavorite();
    _wishlist.remove(room);
    notifyListeners();
  }

  bool isInWishlist(Room room) {
    return _wishlist.contains(room);
  }
}
