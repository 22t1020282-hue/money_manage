class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String type; // 'income' hoặc 'expense'
  final String userId;
  final String category; // <--- QUAN TRỌNG: Phải có dòng này mới hết lỗi

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.userId,
    required this.category, // <--- Và dòng này trong Constructor
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      title: json['title'],
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['date']),
      type: json['type'],
      userId: json['userId'] ?? '',
 
      category: json['category'] ?? 'Khác', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'userId': userId,
      'category': category, 
    };
  }
}