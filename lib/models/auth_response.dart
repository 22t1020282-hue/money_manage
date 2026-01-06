import 'user.dart';

class AuthResponse {
  // Nên thêm từ khóa final để biến không bị thay đổi sau khi khởi tạo (Best practice)
  final bool success;
  final String message;
  final String token;
  final User user;

  // SỬA LỖI Ở ĐÂY:
  // Bỏ cái "required bool success" ở đầu đi, chỉ giữ lại phần trong ngoặc nhọn {}
  AuthResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      // Lưu ý: Đảm bảo model User của cậu xử lý được Map rỗng {} nếu API không trả về user
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}