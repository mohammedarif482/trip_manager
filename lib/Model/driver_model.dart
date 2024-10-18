class Driver {
  final String driverId;
  final String name;
  final String phoneNumber;
  final String licenseNumber;
  final String vehicleNumber;
  final List<String> assignedTrips;
  final DateTime createdAt;
  final DateTime updatedAt;

  Driver({
    required this.driverId,
    required this.name,
    required this.phoneNumber,
    required this.licenseNumber,
    required this.vehicleNumber,
    required this.assignedTrips,
    required this.createdAt,
    required this.updatedAt,
  });
}
