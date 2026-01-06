import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart'; // Import để dùng model Transaction

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // Biến lưu tháng đang chọn xem báo cáo (Mặc định là tháng hiện tại)
  DateTime _selectedMonth = DateTime.now();

  // Hàm format tiền
  String formatCurrency(double amount) {
    final formatter = NumberFormat.decimalPattern('vi');
    return formatter.format(amount);
  }

  // Hàm format tháng (Ví dụ: "Tháng 01/2026")
  String formatMonth(DateTime date) {
    return 'Tháng ${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Chuyển sang tháng trước
  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  // Chuyển sang tháng sau
  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Báo cáo thu chi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          // 1. LỌC DANH SÁCH THEO THÁNG ĐANG CHỌN
          final filteredTransactions = provider.transactions.where((tx) {
            return tx.date.month == _selectedMonth.month && 
                   tx.date.year == _selectedMonth.year;
          }).toList();

          // 2. TÍNH TOÁN LẠI TỔNG THU/CHI DỰA TRÊN LIST ĐÃ LỌC
          double monthlyIncome = 0;
          double monthlyExpense = 0;
          Map<String, double> expenseMap = {};
          Map<String, double> incomeMap = {};

          for (var tx in filteredTransactions) {
            if (tx.type == 'expense') {
              monthlyExpense += tx.amount;
              // Gom nhóm chi tiêu
              expenseMap.update(tx.category, (val) => val + tx.amount, ifAbsent: () => tx.amount);
            } else {
              monthlyIncome += tx.amount;
              // Gom nhóm thu nhập
              incomeMap.update(tx.category, (val) => val + tx.amount, ifAbsent: () => tx.amount);
            }
          }

          double monthlyBalance = monthlyIncome - monthlyExpense;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- THANH CHỌN THÁNG ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        formatMonth(_selectedMonth),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        // Nếu là tháng hiện tại thì không cho bấm next (hoặc cho bấm tùy ý cậu)
                        onPressed: _nextMonth, 
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 25),

                // --- TỔNG KẾT THÁNG ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4E71FF), Color(0xFF2855E8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  ),
                  child: Column(
                    children: [
                      const Text('Số dư trong tháng', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 5),
                      Text(
                        '${monthlyBalance >= 0 ? '+' : ''}${formatCurrency(monthlyBalance)} đ',
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(children: [
                              const Text('Thu vào', style: TextStyle(color: Colors.white70)),
                              Text(formatCurrency(monthlyIncome), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                            ]),
                          ),
                          Container(width: 1, height: 40, color: Colors.white24),
                          Expanded(
                            child: Column(children: [
                              const Text('Chi ra', style: TextStyle(color: Colors.white70)),
                              Text(formatCurrency(monthlyExpense), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                            ]),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- CHECK DỮ LIỆU ---
                if (filteredTransactions.isEmpty) 
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today, size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 10),
                          Text('Tháng này chưa có giao dịch nào', style: TextStyle(color: Colors.grey.shade400)),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // --- BIỂU ĐỒ CHI TIÊU ---
                  if (expenseMap.isNotEmpty) ...[
                    const Text('Chi tiêu theo danh mục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildCategoryList(expenseMap, monthlyExpense, Colors.redAccent),
                  ],

                  const SizedBox(height: 30),

                  // --- BIỂU ĐỒ THU NHẬP ---
                  if (incomeMap.isNotEmpty) ...[
                    const Text('Nguồn thu nhập', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildCategoryList(incomeMap, monthlyIncome, Colors.green),
                  ],
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget hiển thị danh sách category kèm thanh %
  Widget _buildCategoryList(Map<String, double> data, double total, Color color) {
    // Sắp xếp giảm dần theo số tiền
    var sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: sortedEntries.map((e) {
          double pct = total == 0 ? 0 : (e.value / total);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                // Icon tròn tròn
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(e.key.substring(0, 1), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                
                // Thanh progress bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(formatCurrency(e.value)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          color: color,
                          backgroundColor: Colors.grey.shade100,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}