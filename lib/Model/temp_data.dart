// lib/data/dummy_data.dart
import 'package:tripmanager/Model/expense_model.dart';
import 'package:tripmanager/Model/route_model.dart';
import 'package:tripmanager/Model/trip_model.dart';
import 'package:tripmanager/Model/user_model.dart';
import 'package:tripmanager/Model/vehicle_model.dart';

class DummyData {
  static List<User> users = [
    User(
      userId: 1,
      name: 'John Smith',
      phone: '9876543210',
      role: 'owner',
      createdAt: DateTime(2024, 1, 1),
    ),
    User(
      userId: 2,
      name: 'Dave Wilson',
      phone: '9876543211',
      role: 'driver',
      createdAt: DateTime(2024, 1, 5),
    ),
    User(
      userId: 3,
      name: 'Mike Johnson',
      phone: '9876543212',
      role: 'driver',
      createdAt: DateTime(2024, 1, 10),
    ),
    User(
      userId: 4,
      name: 'Robert Davis',
      phone: '9876543213',
      role: 'driver',
      createdAt: DateTime(2024, 1, 15),
    ),
    User(
      userId: 5,
      name: 'Carlos Rodriguez',
      phone: '9876543214',
      role: 'driver',
      createdAt: DateTime(2024, 1, 20),
    ),
    User(
      userId: 6,
      name: 'Steve Thompson',
      phone: '9876543215',
      role: 'driver',
      createdAt: DateTime(2024, 1, 25),
    ),
    User(
      userId: 7,
      name: 'James Anderson',
      phone: '9876543216',
      role: 'driver',
      createdAt: DateTime(2024, 2, 1),
    ),
  ];

  static List<Vehicle> vehicles = [
    Vehicle(
      vehicleId: 1,
      vehicleNumber: 'TN01AB1234',
      vehicleType: 'Container Truck',
      ownerId: 1,
    ),
    Vehicle(
      vehicleId: 2,
      vehicleNumber: 'TN01CD5678',
      vehicleType: 'Dump Truck',
      ownerId: 1,
    ),
    Vehicle(
      vehicleId: 3,
      vehicleNumber: 'TN01EF9012',
      vehicleType: 'Tanker',
      ownerId: 1,
    ),
    Vehicle(
      vehicleId: 4,
      vehicleNumber: 'TN01GH3456',
      vehicleType: 'Container Truck',
      ownerId: 1,
    ),
    Vehicle(
      vehicleId: 5,
      vehicleNumber: 'TN01IJ7890',
      vehicleType: 'Refrigerated Truck',
      ownerId: 1,
      active: false, // Inactive vehicle
    ),
  ];

  static List<Route> routes = [
    Route(
      routeId: 1,
      source: 'Chennai',
      destination: 'Bangalore',
    ),
    Route(
      routeId: 2,
      source: 'Mumbai',
      destination: 'Pune',
    ),
    Route(
      routeId: 3,
      source: 'Delhi',
      destination: 'Jaipur',
    ),
    Route(
      routeId: 4,
      source: 'Kolkata',
      destination: 'Bhubaneswar',
    ),
    Route(
      routeId: 5,
      source: 'Hyderabad',
      destination: 'Vijayawada',
    ),
    Route(
      routeId: 6,
      source: 'Chennai',
      destination: 'Coimbatore',
    ),
    Route(
      routeId: 7,
      source: 'Mumbai',
      destination: 'Ahmedabad',
    ),
    Route(
      routeId: 8,
      source: 'Bangalore',
      destination: 'Hyderabad',
    ),
  ];

  static List<Trip> trips = [
    Trip(
      tripId: 1,
      driverId: 2,
      vehicleId: 1,
      routeId: 1,
      startDate: DateTime(2024, 3, 15),
      endDate: DateTime(2024, 3, 16),
      amount: 25000,
      status: 'completed',
      createdBy: 1,
      createdAt: DateTime(2024, 3, 14),
    ),
    Trip(
      tripId: 2,
      driverId: 3,
      vehicleId: 2,
      routeId: 2,
      startDate: DateTime(2024, 3, 16),
      endDate: DateTime(2024, 3, 17),
      amount: 15000,
      status: 'completed',
      createdBy: 1,
      createdAt: DateTime(2024, 3, 15),
    ),
    Trip(
      tripId: 3,
      driverId: 4,
      vehicleId: 3,
      routeId: 3,
      startDate: DateTime(2024, 3, 17),
      endDate: DateTime(2024, 3, 18),
      amount: 22000,
      status: 'in_progress',
      createdBy: 1,
      createdAt: DateTime(2024, 3, 16),
    ),
    Trip(
      tripId: 4,
      driverId: 5,
      vehicleId: 1,
      routeId: 4,
      startDate: DateTime(2024, 3, 18),
      endDate: DateTime(2024, 3, 19),
      amount: 35000,
      status: 'pending',
      createdBy: 1,
      createdAt: DateTime(2024, 3, 17),
    ),
    Trip(
      tripId: 5,
      driverId: 6,
      vehicleId: 2,
      routeId: 5,
      startDate: DateTime(2024, 3, 19),
      endDate: DateTime(2024, 3, 20),
      amount: 28000,
      status: 'pending',
      createdBy: 1,
      createdAt: DateTime(2024, 3, 18),
    ),
    Trip(
      tripId: 6,
      driverId: 2,
      vehicleId: 4,
      routeId: 6,
      startDate: DateTime(2024, 3, 20),
      endDate: DateTime(2024, 3, 21),
      amount: 42000,
      status: 'pending',
      createdBy: 1,
      createdAt: DateTime(2024, 3, 19),
    ),
    Trip(
      tripId: 7,
      driverId: 3,
      vehicleId: 1,
      routeId: 7,
      startDate: DateTime(2024, 3, 15),
      endDate: DateTime(2024, 3, 16),
      amount: 45000,
      status: 'cancelled',
      createdBy: 1,
      createdAt: DateTime(2024, 3, 14),
    ),
  ];

  static List<Expense> expenses = [
    Expense(
      expenseId: 1,
      tripId: 1,
      expenseType: 'fuel',
      amount: 8000,
      description: 'Diesel refill at Chennai',
      addedBy: 2,
      addedAt: DateTime(2024, 3, 15, 8, 30),
    ),
    Expense(
      expenseId: 2,
      tripId: 1,
      expenseType: 'food',
      amount: 500,
      description: 'Lunch and dinner',
      addedBy: 2,
      addedAt: DateTime(2024, 3, 15, 20, 15),
    ),
    Expense(
      expenseId: 3,
      tripId: 1,
      expenseType: 'maintenance',
      amount: 1500,
      description: 'Emergency tire repair',
      addedBy: 2,
      addedAt: DateTime(2024, 3, 15, 14, 20),
    ),
    Expense(
      expenseId: 4,
      tripId: 2,
      expenseType: 'fuel',
      amount: 5000,
      description: 'Diesel refill at Mumbai',
      addedBy: 3,
      addedAt: DateTime(2024, 3, 16, 9, 45),
    ),
    Expense(
      expenseId: 5,
      tripId: 2,
      expenseType: 'food',
      amount: 450,
      description: 'Meals for the day',
      addedBy: 3,
      addedAt: DateTime(2024, 3, 16, 19, 30),
    ),
    Expense(
      expenseId: 6,
      tripId: 3,
      expenseType: 'fuel',
      amount: 7000,
      description: 'Diesel refill at Delhi',
      addedBy: 4,
      addedAt: DateTime(2024, 3, 17, 7, 15),
    ),
    Expense(
      expenseId: 7,
      tripId: 3,
      expenseType: 'maintenance',
      amount: 2500,
      description: 'Regular maintenance check',
      addedBy: 4,
      addedAt: DateTime(2024, 3, 17, 16, 45),
    ),
    Expense(
      expenseId: 8,
      tripId: 3,
      expenseType: 'other',
      amount: 1000,
      description: 'Toll charges',
      addedBy: 4,
      addedAt: DateTime(2024, 3, 17, 12, 30),
    ),
    Expense(
      expenseId: 9,
      tripId: 4,
      expenseType: 'fuel',
      amount: 9000,
      description: 'Initial fuel filling',
      addedBy: 5,
      addedAt: DateTime(2024, 3, 18, 6, 0),
    ),
    Expense(
      expenseId: 10,
      tripId: 1,
      expenseType: 'other',
      amount: 800,
      description: 'Parking charges',
      addedBy: 2,
      addedAt: DateTime(2024, 3, 15, 23, 45),
    ),
  ];

  // Helper method to get all expenses for a trip
  static List<Expense> getExpensesForTrip(int tripId) {
    return expenses.where((expense) => expense.tripId == tripId).toList();
  }

  // Helper method to get all trips for a driver
  static List<Trip> getTripsForDriver(int driverId) {
    return trips.where((trip) => trip.driverId == driverId).toList();
  }

  // Helper method to get active vehicles
  static List<Vehicle> getActiveVehicles() {
    return vehicles.where((vehicle) => vehicle.active).toList();
  }

  // Helper method to calculate total earnings for a driver
  static double getDriverEarnings(int driverId) {
    final driverTrips = getTripsForDriver(driverId);
    return driverTrips
        .where((trip) => trip.status == 'completed')
        .fold(0, (sum, trip) => sum + trip.amount);
  }

  // Helper method to get total expenses for a trip
  static double getTripExpenses(int tripId) {
    final tripExpenses = getExpensesForTrip(tripId);
    return tripExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }
}
