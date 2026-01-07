import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
 
  static const String baseUrl = 'https://695d05f279f2f34749d6b423.mockapi.io/transactions';

  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

 
  double get totalIncome => _transactions
      .where((tx) => tx.type == 'income')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == 'expense')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalBalance => totalIncome - totalExpense;

  Future<void> fetchTransactions(String userId) async {
    try {

      final response = await http.get(Uri.parse('$baseUrl?userId=$userId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        _transactions = data.map((item) => Transaction.fromJson(item)).toList();
        
        notifyListeners(); 
      }
    } catch (e) {
      print('❌ Lỗi tải dữ liệu: $e');
    }
  }


  Future<void> addTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
       
        final newTransaction = Transaction.fromJson(json.decode(response.body));
        _transactions.add(newTransaction);
        notifyListeners();
      }
    } catch (e) {
      print('❌ Lỗi thêm giao dịch: $e');
    }
  }


  Future<void> deleteTransaction(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        _transactions.removeWhere((tx) => tx.id == id);
        notifyListeners();
      }
    } catch (e) {
      print('❌ Lỗi xóa giao dịch: $e');
    }
  }

  Future<void> updateTransaction(Transaction updatedTransaction) async {
    try {
      print('📡 Đang cập nhật ID: ${updatedTransaction.id}...');
      
      final response = await http.put(
        Uri.parse('$baseUrl/${updatedTransaction.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedTransaction.toJson()),
      );

      if (response.statusCode == 200) {
        print('✅ Cập nhật thành công trên Server');
        
        final index = _transactions.indexWhere((tx) => tx.id == updatedTransaction.id);
        if (index != -1) {
          _transactions[index] = updatedTransaction;
          notifyListeners(); 
        }
      } else {
        print('❌ Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi kết nối: $e');
    }
 }
}