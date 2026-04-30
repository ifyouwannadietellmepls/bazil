class User {
  final String userId; // <-- ИСПРАВЛЕНО: было int, стало String
  final int telegramId;
  final String firstName;
  final String? lastName;
  final String? phone;
  final double totalSpent;
  final String status;
  final int discount;

  User({
    required this.userId,
    required this.telegramId,
    required this.firstName,
    this.lastName,
    this.phone,
    required this.totalSpent,
    required this.status,
    required this.discount,
  });

  String get fullName => '$firstName ${lastName ?? ''}'.trim();
}