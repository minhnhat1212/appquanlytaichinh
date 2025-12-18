import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Logic chọn Base URL:
  // - Android Emulator: 10.0.2.2
  // - iOS Simulator / Desktop / Web: localhost (hoặc 127.0.0.1)
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  static String get login => '$baseUrl/api/auth/login';
  static String get register => '$baseUrl/api/auth/register';
  static String get changePassword => '$baseUrl/api/auth/change-password';
}
