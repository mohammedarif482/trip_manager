class Vehicle {
  final int vehicleId;
  final String vehicleNumber;
  final String vehicleType;
  final int ownerId;
  final bool active;

  Vehicle({
    required this.vehicleId,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.ownerId,
    this.active = true,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleId'],
      vehicleNumber: json['vehicleNumber'],
      vehicleType: json['vehicleType'],
      ownerId: json['ownerId'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'ownerId': ownerId,
      'active': active,
    };
  }
}

