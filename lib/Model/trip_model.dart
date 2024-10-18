
// lib/models/trip.dart
import 'package:tripmanager/Model/expense_model.dart';
import 'package:tripmanager/Model/route_model.dart';
import 'package:tripmanager/Model/user_model.dart';
import 'package:tripmanager/Model/vehicle_model.dart';

class Trip {
  final int tripId;
  final int driverId;
  final int vehicleId;
  final int routeId;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String status; // 'pending', 'in_progress', 'completed', 'cancelled'
  final int createdBy;
  final DateTime createdAt;
  
  // Additional fields for related data
  User? driver;
  Vehicle? vehicle;
  Route? route;
  List<Expense> expenses = [];

  Trip({
    required this.tripId,
    required this.driverId,
    required this.vehicleId,
    required this.routeId,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.driver,
    this.vehicle,
    this.route,
    this.expenses = const [],
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['tripId'],
      driverId: json['driverId'],
      vehicleId: json['vehicleId'],
      routeId: json['routeId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      amount: json['amount'].toDouble(),
      status: json['status'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'routeId': routeId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'amount': amount,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  double get totalExpenses {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double get remainingAmount {
    return amount - totalExpenses;
  }
}
