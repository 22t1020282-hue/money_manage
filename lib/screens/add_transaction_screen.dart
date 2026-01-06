import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../providers/user_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  // Thêm tham số này để nhận dữ liệu cần sửa (nếu có)
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedType = 'expense';
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Ăn uống'; 
  bool _isLoading = false;

  // Danh sách danh mục (Giữ nguyên)
  final Map<String, IconData> _expenseCategories = {
    'Ăn uống': Icons.restaurant,
    'Di chuyển': Icons.directions_car,
    'Mua sắm': Icons.shopping_bag,
    'Giải trí': Icons.movie,
    'Hóa đơn': Icons.receipt_long,
    'Y tế': Icons.local_hospital,
    'Giáo dục': Icons.school,
    'Khác': Icons.more_horiz,
  };

  final Map<String, IconData> _incomeCategories = {
    'Lương': Icons.attach_money,
    'Thưởng': Icons.card_giftcard,
    'Đầu tư': Icons.trending_up,
    'Bán đồ': Icons.store,
    'Khác': Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    // KIỂM TRA: Nếu là chế độ Sửa (có dữ liệu truyền vào) -> Điền sẵn thông tin
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toInt().toString(); // Bỏ số thập phân cho đẹp
      _selectedDate = widget.transaction!.date;
      _selectedType = widget.transaction!.type;
      _selectedCategory = widget.transaction!.category;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) return;

      setState(() => _isLoading = true);

      // Tạo object transaction mới (dùng cho cả Thêm và Sửa)
      final transactionData = Transaction(
        id: widget.transaction?.id ?? '', // Nếu sửa thì giữ ID cũ, thêm thì để trống
        title: _titleController.text.isEmpty ? _selectedCategory : _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        type: _selectedType,
        userId: user.id,
        category: _selectedCategory,
      );

      final provider = Provider.of<TransactionProvider>(context, listen: false);

      if (widget.transaction == null) {
        // --- CHẾ ĐỘ THÊM ---
        await provider.addTransaction(transactionData);
      } else {
        // --- CHẾ ĐỘ SỬA ---
        await provider.updateTransaction(transactionData);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _selectedType == 'expense';
    final mainColor = isExpense ? const Color(0xFFFF3D00) : const Color(0xFF00C853);
    final categories = isExpense ? _expenseCategories : _incomeCategories;

    // Logic để không bị lỗi khi chuyển type mà category cũ không tồn tại
    if (!categories.containsKey(_selectedCategory)) {
        // Nếu đang ở chế độ sửa và category khớp thì giữ nguyên, không thì reset
        if (widget.transaction != null && widget.transaction!.type == _selectedType) {
           _selectedCategory = widget.transaction!.category;
        } else {
           _selectedCategory = categories.keys.first;
        }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Đổi tiêu đề tùy theo chế độ
        title: Text(widget.transaction == null ? 'Thêm giao dịch' : 'Sửa giao dịch', 
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SWITCHER (Chỉ cho phép chọn nếu là Thêm mới, Sửa thì nên hạn chế đổi loại để tránh rắc rối logic, nhưng cho đổi cũng được)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: [
                    _buildTabButton('Chi tiêu', 'expense', Colors.redAccent),
                    _buildTabButton('Thu nhập', 'income', Colors.green),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 2. SỐ TIỀN
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: mainColor),
                decoration: InputDecoration(
                  hintText: '0',
                  border: InputBorder.none,
                  suffixText: 'đ',
                  suffixStyle: const TextStyle(fontSize: 20, color: Colors.grey),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Nhập tiền nhé' : null,
              ),
              const Divider(),
              const SizedBox(height: 20),

              // 3. CHỌN DANH MỤC
              const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.9,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final key = categories.keys.elementAt(index);
                  final icon = categories[key];
                  final isSelected = _selectedCategory == key;
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = key),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? mainColor.withOpacity(0.1) : Colors.grey.shade50,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: mainColor, width: 2) : null,
                          ),
                          child: Icon(icon, color: isSelected ? mainColor : Colors.grey, size: 24),
                        ),
                        const SizedBox(height: 5),
                        Text(key, style: TextStyle(fontSize: 12, color: isSelected ? mainColor : Colors.black87), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 4. TIÊU ĐỀ & NGÀY
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Ghi chú (Tùy chọn)',
                  prefixIcon: const Icon(Icons.edit_note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: mainColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    // Đổi chữ nút Lưu
                    : Text(widget.transaction == null ? 'Lưu giao dịch' : 'Cập nhật', 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, String value, Color color) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 5)] : [],
          ),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? color : Colors.grey)),
        ),
      ),
    );
  }
}