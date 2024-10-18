
// lib/models/expense.dart
class Expense {
  final int expenseId;
  final int tripId;
  final String expenseType; // 'fuel', 'maintenance', 'food', 'other'
  final double amount;
  final String description;
  final int addedBy;
  final DateTime addedAt;

  Expense({
    required this.expenseId,
    required this.tripId,
    required this.expenseType,
    required this.amount,
    required this.description,
    required this.addedBy,
    required this.addedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['expenseId'],
      tripId: json['tripId'],
      expenseType: json['expenseType'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      addedBy: json['addedBy'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'tripId': tripId,
      'expenseType': expenseType,
      'amount': amount,
      'description': description,
      'addedBy': addedBy,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}
