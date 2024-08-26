class Room {
  final String uid;
  final String name;
  final double price;
  final double capacity;
  final String description;
  final double length;
  final double breadth;
  final List<String> photo;
  final String panoramaImg;
  final double electricity;
  final double fohor;
  final double water;
  final double lat;
  final double lng;
  final bool active;
  final bool featured;
  final String locationName;
  final String statusByAdmin;
  final Map<String, String> details; // Add the details field
  late final Map<String, dynamic> status;
  late final Map<String, dynamic> report;
  bool? isFavorite;
  final List<String> facilities;

  Room({
    required this.uid,
    required this.name,
    required this.price,
    required this.capacity,
    required this.description,
    required this.length,
    required this.breadth,
    required this.photo,
    required this.panoramaImg,
    required this.electricity,
    required this.fohor,
    required this.water,
    required this.lat,
    required this.lng,
    required this.active,
    required this.featured,
    required this.locationName,
    required this.statusByAdmin,
    required this.details, // Initialize the details field
    required this.status,
    required this.report,
    this.isFavorite = false,
    required this.facilities,
  });

  void toggleFavorite() {
    isFavorite = !isFavorite!;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Room && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
