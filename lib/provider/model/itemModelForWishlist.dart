class RoomProviderModel {
   int? id;
   String? name;
   String ?image;
   String? description;
   double? price;
  bool? isFavorite;

   RoomProviderModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
   required this.price,
    this.isFavorite = false,
  });

  void toggleFavorite() {
    isFavorite = !isFavorite!;
  }
}
