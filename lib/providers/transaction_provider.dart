import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  // URL MockAPI của cậu
  static const String baseUrl = 'https://695d05f279f2f34749d6b423.mockapi.io/transactions';

  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  // Tính toán tổng tiền (giữ nguyên logic cũ)
  double get totalIncome => _transactions
      .where((tx) => tx.type == 'income')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == 'expense')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalBalance => totalIncome - totalExpense;

  // --- 1. HÀM TẢI DỮ LIỆU TỪ API ---
  Future<void> fetchTransactions(String userId) async {
    try {
      // Gọi API lấy về danh sách transaction của user đó
      final response = await http.get(Uri.parse('$baseUrl?userId=$userId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        _transactions = data.map((item) => Transaction.fromJson(item)).toList();
        
        notifyListeners(); // Báo cho giao diện cập nhật
      }
    } catch (e) {
      print('❌ Lỗi tải dữ liệu: $e');
    }
  }

  // --- 2. HÀM THÊM GIAO DỊCH LÊN API ---
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        // Nếu server lưu thành công, ta thêm vào list ở app để hiện luôn
        final newTransaction = Transaction.fromJson(json.decode(response.body));
        _transactions.add(newTransaction);
        notifyListeners();
      }
    } catch (e) {
      print('❌ Lỗi thêm giao dịch: $e');
    }
  }

  // --- 3. HÀM XÓA GIAO DỊCH TRÊN API ---
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
// --- HÀM CẬP NHẬT GIAO DỊCH (CHUẨN) ---
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
        
        // Cập nhật luôn vào danh sách đang hiển thị trên App (để không cần load lại cũng thấy đổi)
        final index = _transactions.indexWhere((tx) => tx.id == updatedTransaction.id);
        if (index != -1) {
          _transactions[index] = updatedTransaction;
          notifyListeners(); // <--- Quan trọng: Báo cho màn hình vẽ lại
        }
      } else {
        print('❌ Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi kết nối: $e');
    }
 }
}