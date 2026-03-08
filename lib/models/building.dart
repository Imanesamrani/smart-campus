class Building {
  final String id;
  final String name;
  final String code;
  final String address;
  final double latitude;
  final double longitude;
  final int floors;
  final String description;
  final String imageUrl;
  final Map<String, dynamic> openingHours;
  final List<String> services;

  Building({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.floors,
    required this.description,
    required this.imageUrl,
    required this.openingHours,
    required this.services,
  });

  factory Building.fromMap(Map<String, dynamic> data, String documentId) {
    return Building(
      id: documentId,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      floors: data['floors'] is int
          ? data['floors']
          : ((data['floors'] ?? 0) as num).toInt(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      openingHours: Map<String, dynamic>.from(data['openingHours'] ?? {}),
      services: List<String>.from(data['services'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'floors': floors,
      'description': description,
      'imageUrl': imageUrl,
      'openingHours': openingHours,
      'services': services,
    };
  }
}