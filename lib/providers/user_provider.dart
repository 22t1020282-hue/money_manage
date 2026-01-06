import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  // Lấy user hiện tại
  User? get user => _user;

  // Lưu user vào (gọi khi đăng nhập thành công)
  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  // Xóa user (gọi khi đăng xuất)
  void logout() {
    _user = null;
    notifyListeners();
  }
}