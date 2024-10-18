class User {
  final int userId;
  final String name;
  final String phone;
  final String role; // 'owner' or 'driver'
  final DateTime createdAt;

  User({
    required this.userId,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
