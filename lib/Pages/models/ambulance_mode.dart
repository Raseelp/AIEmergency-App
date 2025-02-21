class Ambulance {
  final String vehicleNumber;
  final String hospital;
  final String type;
  final String status;
  final int id;
  final double? latitude;
  final double? longitude;

  Ambulance({
    required this.vehicleNumber,
    required this.hospital,
    required this.type,
    required this.status,
    required this.id,
    this.latitude,
    this.longitude,
  });

  factory Ambulance.fromJson(Map<String, dynamic> json) {
    return Ambulance(
      vehicleNumber: json['Ambulance'],
      hospital: json['Hospital'],
      type: json['Type'],
      status: json['Status'],
      id: json['id'],
      latitude:
          json['Latitude'] != null ? double.parse(json['Latitude']) : null,
      longitude:
          json['Longitude'] != null ? double.parse(json['Longitude']) : null,
    );
  }
}
