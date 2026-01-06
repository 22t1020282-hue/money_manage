// lib/services/transaction_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class TransactionApi {
  static const String baseUrl = 'https://695d05f279f2f34749d6b423.mockapi.io';
  
  static Future<List<Transaction>> getTransactions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/transactions'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Transaction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Lỗi API: $e');
      return [];
    }
  }
  
  static Future<bool> addTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transaction.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}