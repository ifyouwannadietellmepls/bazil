import 'dart:convert';
import 'dart:async'; // ← ВАЖНО: для StreamController
import 'package:flutter/foundation.dart'; // ← ВАЖНО: для debugPrint
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.113:8081';
  
  // ← Stream для авто-обновления авторизации (должен быть static!)
  static final _userIdController = StreamController<String?>.broadcast();
  static Stream<String?> get userIdStream => _userIdController.stream;

  static Future<Map<String, dynamic>?> login(String phone, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final user = data['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user['userId']);
        await prefs.setString('role', user['role']);
        await prefs.setString('userData', jsonEncode(user));
        
        // ← Уведомляем подписчиков об изменении userId
        _userIdController.add(user['userId']);
        
        return user;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
    return null;
  }

  static Future<bool> register(String phone, String password, String firstName, String lastName) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password, 'firstName': firstName, 'lastName': lastName}),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) { 
      debugPrint('Register error: $e'); 
      return false; 
    }
  }

  static Future<bool> sendSmsCode(String phone, {String purpose = 'register'}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/sms/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'purpose': purpose}),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) { 
      debugPrint('SMS send error: $e'); 
      return false; 
    }
  }

  static Future<bool> verifySmsCode(String phone, String code, {String purpose = 'register'}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/sms/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'code': code, 'purpose': purpose}),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) { 
      debugPrint('SMS verify error: $e'); 
      return false; 
    }
  }

  static Future<Map<String, dynamic>?> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updates),
      ).timeout(const Duration(seconds: 10));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(data['user']));
        return data['user'];
      }
    } catch (e) { 
      debugPrint('Update profile error: $e'); 
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchUser(String userId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/users/$userId'),
      ).timeout(const Duration(seconds: 10));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(data));
        return data;
      }
    } catch (e) { 
      debugPrint('Fetch user error: $e'); 
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('userData');
      if (cached != null) return jsonDecode(cached);
    } catch (e) { 
      debugPrint('Cache read error: $e'); 
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // ← Уведомляем подписчиков о выходе
    _userIdController.add(null);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
  
  // ← Очистка ресурсов
  static void dispose() {
    _userIdController.close();
  }
}