import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Xóa text điền sẵn trong ngoặc ('...') để ô trống trơn
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;

  void _login() async {
    // Kiểm tra nếu người dùng chưa nhập gì
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Vui lòng nhập đầy đủ Email và Mật khẩu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Gọi API đăng nhập
    final result = await AuthService.login(
      email: _emailController.text.trim(), // trim() để cắt khoảng trắng thừa
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      if (!mounted) return;
      // Lưu thông tin (giả lập)
      Provider.of<UserProvider>(context, listen: false).setUser(result.user);
      await AuthService.saveAuthData(result.token, result.user);
      
      // Chuyển sang màn hình chính
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đăng nhập thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng sạch sẽ
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo
              const Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'ĐĂNG NHẬP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Chào mừng trở lại',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // --- Ô NHẬP EMAIL ---
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Hãy nhập email của bạn', // Chữ mờ nhắc nhở
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Ô NHẬP MẬT KHẨU ---
              TextField(
                controller: _passwordController,
                obscureText: true, // Ẩn mật khẩu
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  hintText: 'Hãy nhập mật khẩu', // Chữ mờ nhắc nhở
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // --- NÚT ĐĂNG NHẬP ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ĐĂNG NHẬP',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 20),
              
              // Nút chuyển qua Đăng ký (nếu cần)
              TextButton(
                onPressed: () {
                   // --- SỬA LẠI ĐOẠN NÀY ---
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const RegisterScreen()),
                   );
                   // ------------------------
                },
                child: const Text('Chưa có tài khoản? Đăng ký ngay'),
           ),
          ],
        ),
       ),
     )
    );
  }
}