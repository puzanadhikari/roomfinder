class Room {
  final String uid;
  final String name;
  final double capacity;
  final String description;
  final double length;
  final double breadth;
  final List<String> photo;
  final String panoramaImg;
  final double electricity;
  final double fohor;
  final double lat;
  final double lng;
  final bool active;
  final bool featured;
  final String locationName;
  late final Map<String, dynamic> status;

  Room({
    required this.uid,
    required this.name,
    required this.capacity,
    required this.description,
    required this.length,
    required this.breadth,
    required this.photo,
    required this.panoramaImg,
    required this.electricity,
    required this.fohor,
    required this.lat,
    required this.lng,
    required this.active,
    required this.featured,
    required this.locationName,
    required this.status,
  });
}
