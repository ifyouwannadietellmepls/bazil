class LoyaltyConfig {
  static const levels = {
    'Start': {'minSpent': 0, 'discount': 0},
    'Bronze': {'minSpent': 40000, 'discount': 5},
    'Silver': {'minSpent': 60000, 'discount': 10},
    'Gold': {'minSpent': 75000, 'discount': 15},
  };

  static String calculateStatus(double totalSpent) {
    if (totalSpent >= 75000) return 'Gold';
    if (totalSpent >= 60000) return 'Silver';
    if (totalSpent >= 40000) return 'Bronze';
    return 'Start';
  }

  static int getDiscount(double totalSpent) {
    final status = calculateStatus(totalSpent);
    return levels[status]!['discount'] as int;
  }
}