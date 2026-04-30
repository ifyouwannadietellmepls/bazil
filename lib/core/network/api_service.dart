import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://192.168.1.100:8000');

  ApiService() : _dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)));

  Future<Response> getUserByTelegramId(int telegramId) async {
    return await _dio.get('/api/user/telegram/$telegramId');
  }

  Future<Response> registerUser(Map<String, dynamic> userData) async {
    return await _dio.post('/api/user/register', data: userData);
  }

  Future<Response> updatePhone(int telegramId, String phone) async {
    return await _dio.patch('/api/user/$telegramId/phone', data: {'phone': phone});
  }

  Future<Response> getHistory(int userId, {int limit = 10}) async {
    return await _dio.get('/api/user/$userId/history', queryParameters: {'limit': limit});
  }

  Future<Response> addPurchase(Map<String, dynamic> purchaseData) async {
    return await _dio.post('/api/loyalty/add', data: purchaseData);
  }
}