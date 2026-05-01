class PlaceModel {
  final int? id;
  final String name;
  final String description;
  final String image;
  final double lat;
  final double lng;
  final String type;
  final bool isFavourite;

  PlaceModel({
    this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.lat,
    required this.lng,
    required this.type,
    this.isFavourite = false,
  });

  PlaceModel copyWith({
    int? id,
    bool? isFavourite,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name,
      description: description,
      image: image,
      lat: lat,
      lng: lng,
      type: type,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'lat': lat,
      'lng': lng,
      'type': type,
      'isFavourite': isFavourite ? 1 : 0,
    };
  }

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      image: map['image'],
      lat: map['lat'],
      lng: map['lng'],
      type: map['type'],
      isFavourite: map['isFavourite'] == 1,
    );
  }
}
