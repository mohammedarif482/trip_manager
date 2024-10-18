class Transaction {
  final String name;
  final double amount;
  final DateTime date;
  final String purpose;
  final bool isExpense;

  Transaction({
    required this.name,
    required this.amount,
    required this.date,
    required this.purpose,
    required this.isExpense,
  });
}
