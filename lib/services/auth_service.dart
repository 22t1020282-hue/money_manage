import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/auth_response.dart';

class AuthService {
  // URL API THẬT CỦA BẠN
  static const String baseUrl = 'https://695d05f279f2f34749d6b423.mockapi.io';

  // --- HÀM HỖ TRỢ: TẠO USER RỖNG (Để code gọn hơn) ---
  static User _emptyUser() {
    return User(
      id: '',
      email: '',
      name: '',
      createdAt: DateTime.now(),
    );
  }
  
  // 1. ĐĂNG KÝ
  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('📡 [API] Đang gửi request đăng ký...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/user'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password, // MockAPI lưu plain text
          'name': name,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );
      
      print('✅ [API] Register status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        return AuthResponse(
          success: true,
          message: '🎉 Đăng ký thành công!',
          token: 'jwt_token_${data['id']}',
          user: User.fromJson(data),
        );
      } else {
        return AuthResponse(
          success: false,
          message: '❌ Lỗi API: ${response.statusCode}',
          token: '',
          user: _emptyUser(),
        );
      }
    } catch (e) {
      print('❌ [API] Lỗi kết nối: $e');
      return AuthResponse(
        success: false,
        message: '🌐 Lỗi mạng. Vui lòng kiểm tra internet!',
        token: '',
        user: _emptyUser(),
      );
    }
  }
  
  // 2. ĐĂNG NHẬP (Đã sửa logic trùng Email)
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      print('📡 [API] Đang gửi request đăng nhập...');
      
      // Query user theo email
      final response = await http.get(
        Uri.parse('$baseUrl/user?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('✅ [API] Login status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isEmpty) {
          return AuthResponse(
            success: false,
            message: '📭 Email không tồn tại',
            token: '',
            user: _emptyUser(),
          );
        }
        
        // --- LOGIC MỚI: TÌM USER KHỚP PASSWORD ---
        try {
          // MockAPI có thể trả về nhiều user cùng email
          // Ta tìm người nào có password khớp với cái người dùng nhập
          final userData = data.firstWhere(
            (user) => user['password'] == password,
          );

          // Nếu tìm thấy:
          return AuthResponse(
            success: true,
            message: '🎉 Đăng nhập thành công!',
            token: 'jwt_token_${userData['id']}',
            user: User.fromJson(userData),
          );

        } catch (e) {
          // Nếu duyệt hết danh sách mà không ai khớp password
          return AuthResponse(
            success: false,
            message: '🔐 Mật khẩu không đúng',
            token: '',
            user: _emptyUser(),
          );
        }
        // ------------------------------------------

      } else {
        return AuthResponse(
          success: false,
          message: '❌ Lỗi API: ${response.statusCode}',
          token: '',
          user: _emptyUser(),
        );
      }
    } catch (e) {
      print('❌ [API] Lỗi kết nối: $e');
      return AuthResponse(
        success: false,
        message: '🌐 Lỗi kết nối server. Vui lòng thử lại!',
        token: '',
        user: _emptyUser(),
      );
    }
  }
  
  // 3. LƯU TOKEN (Đã fix lỗi RangeError)
  static Future<void> saveAuthData(String token, User user) async {
    print('💾 Đang lưu thông tin đăng nhập...');
    
    // In token ra console an toàn (không dùng substring nữa)
    print('Token: $token'); 
    
    // Giả lập thời gian lưu
    await Future.delayed(const Duration(milliseconds: 300));
  }
  
  // 4. CÁC HÀM KHÁC
  static Future<bool> checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return false;
  }
  
  static Future<void> logout() async {
    print('🚪 Đang đăng xuất...');
    await Future.delayed(const Duration(milliseconds: 300));
  }
}