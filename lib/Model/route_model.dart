// lib/models/route.dart
class Route {
  final int routeId;
  final String source;
  final String destination;

  Route({
    required this.routeId,
    required this.source,
    required this.destination,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      routeId: json['routeId'],
      source: json['source'],
      destination: json['destination'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'source': source,
      'destination': destination,
    };
  }
}
