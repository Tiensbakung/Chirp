enum PlaceType {
  city,
  unknown,
  country,
  admin,
  neighborhood,
  poi,
  zipCode,
  metro,
  admin0,
  admin1;

  factory PlaceType.parse(String s) {
    return PlaceType.values.byName(s);
  }
}

class PlaceModel {
  final String id;
  final String name;
  final String fullName;
  final String country;
  final String countryCode;
  final PlaceType placeType;
  const PlaceModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.country,
    required this.countryCode,
    required this.placeType,
  });
  factory PlaceModel.fromJson(Map<String, dynamic> el) {
    return PlaceModel(
      id: el['id'],
      country: el['country'],
      countryCode: el['country_code'],
      fullName: el['full_name'],
      name: el['name'],
      placeType: PlaceType.parse(el['place_type']),
    );
  }
}
