import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:money_manage/models/transaction.dart';
import 'package:money_manage/providers/transaction_provider.dart';
import 'package:money_manage/providers/user_provider.dart'; // Import UserProvider
import 'package:money_manage/screens/add_transaction_screen.dart';
import 'package:money_manage/screens/report_screen.dart';
import 'package:money_manage/screens/login_screen.dart'; // Import LoginScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động tải dữ liệu khi mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _refreshData();
    });
  }

  // Hàm tải lại dữ liệu (Dùng cho Pull-to-refresh)
  Future<void> _refreshData() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions(user.id);
    }
  }

  // Hàm Đăng xuất
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              // 1. Xóa user khỏi provider
              Provider.of<UserProvider>(context, listen: false).logout();
              // 2. Quay về màn hình đăng nhập (Xóa hết các màn hình cũ)
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.decimalPattern('vi');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator( // <--- TÍNH NĂNG KÉO ĐỂ LÀM MỚI
        onRefresh: _refreshData,
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // --- HEADER ---
                _buildHeader(context, provider),
                
                const SizedBox(height: 20),

                // --- TIÊU ĐỀ LIST ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Giao dịch gần đây',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      TextButton(
                        onPressed: _refreshData, // Bấm vào đây cũng reload được
                        child: const Text('Làm mới'),
                      )
                    ],
                  ),
                ),

                // --- LIST GIAO DỊCH ---
                Expanded(
                  child: _buildTransactionList(provider),
                ),
              ],
            );
          },
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        backgroundColor: const Color(0xFF4E71FF),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(BuildContext context, TransactionProvider provider) {
    final user = Provider.of<UserProvider>(context).user;

    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4E71FF), Color(0xFF2855E8)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, 10), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nút Logout (Thay cho nút Cloud cũ)
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: _logout, // Gọi hàm logout
                tooltip: 'Đăng xuất',
              ),
              Column(
                children: [
                  const Text('Xin chào,', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    user?.name ?? 'Bạn', // Hiện tên user
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // Nút Report
              IconButton(
                icon: const Icon(Icons.bar_chart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportScreen()),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          const Text('Tổng số dư', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            '${formatCurrency(provider.totalBalance)} đ',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 30),

          // Card Thu/Chi nhỏ
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.arrow_upward, color: Colors.greenAccent)),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Thu nhập', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(formatCurrency(provider.totalIncome), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ])
                  ]),
                ),
                Expanded(
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.arrow_downward, color: Colors.redAccent)),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Chi tiêu', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(formatCurrency(provider.totalExpense), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ])
                  ]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTransactionList(TransactionProvider provider) {
    if (provider.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notes, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text('Chưa có giao dịch nào', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    // Đảo ngược list để cái mới nhất lên đầu
    final reversedList = provider.transactions.reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, bottom: 80),
      // Quan trọng: Để RefreshIndicator hoạt động khi list ngắn, cần thêm physics này
      physics: const AlwaysScrollableScrollPhysics(), 
      itemCount: reversedList.length,
      itemBuilder: (context, index) {
        final transaction = reversedList[index];
        final isIncome = transaction.type == 'income';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            onTap: () async { // <--- 1. Thêm từ khóa async
              // 2. Thêm await vào trước Navigator
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTransactionScreen(transaction: transaction),
                ),
              );
              
              // 3. Sau khi quay về, gọi hàm làm mới dữ liệu ngay lập tức
              if (context.mounted) {
                 _refreshData();
              }
            },
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isIncome ? const Color(0xFFE5F9ED) : const Color(0xFFFFE5E5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome ? Icons.attach_money : Icons.shopping_bag_outlined,
                color: isIncome ? const Color(0xFF00C853) : const Color(0xFFFF3D00),
              ),
            ),
            title: Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(
              '${transaction.date.day}/${transaction.date.month} • ${transaction.category}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'}${formatCurrency(transaction.amount)}',
              style: TextStyle(
                color: isIncome ? const Color(0xFF00C853) : const Color(0xFFFF3D00),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xóa giao dịch'),
                  content: Text('Bạn có chắc muốn xóa "${transaction.title}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                    TextButton(
                      onPressed: () {
                        provider.deleteTransaction(transaction.id);
                        Navigator.pop(context);
                      },
                      child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}