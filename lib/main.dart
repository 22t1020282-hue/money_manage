import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/user_provider.dart';
// --- QUAN TRỌNG: Phải import màn hình Login thì mới gọi được ---
import 'screens/login_screen.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 1. Provider quản lý User (đăng nhập/đăng xuất)
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // 2. Provider quản lý Giao dịch (thêm/sửa/xóa)
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // SỬA LỖI: Bỏ cái ChangeNotifierProvider bao quanh MaterialApp đi
    // Vì ta đã bao bằng MultiProvider ở hàm main() rồi. 
    // Nếu bao lại ở đây, nó sẽ tạo ra kho dữ liệu mới tinh -> Mất kết nối với UserProvider.
    
    return MaterialApp(
      title: 'Quản lý chi tiêu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Dùng Material 3 cho đẹp, hoặc false nếu muốn giống giao diện cũ
        useMaterial3: true, 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginScreen(), // Giờ import rồi thì dòng này hết lỗi
      debugShowCheckedModeBanner: false,
    );
  }
}