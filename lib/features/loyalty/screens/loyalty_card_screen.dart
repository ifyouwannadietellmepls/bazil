import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../loyalty/models/user_model.dart';
import '../../../core/services/auth_service.dart';

class LoyaltyCardScreen extends StatefulWidget {
  const LoyaltyCardScreen({super.key});
  @override
  State<LoyaltyCardScreen> createState() => _LoyaltyCardScreenState();
}

class _LoyaltyCardScreenState extends State<LoyaltyCardScreen> {
  User? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final id = await AuthService.getUserId();
      if (id == null) {
        if (mounted) {
          setState(() {
            _error = 'Пользователь не авторизован';
            _loading = false;
          });
        }
        return;
      }

      var data = await AuthService.fetchUser(id);
      if (data == null) {
        data = await AuthService.getCachedUser();
      }

      if (mounted) {
        if (data != null) {
          // Явно приводим к не-null типу после проверки
          final safeData = data;
          setState(() {
            _user = User(
              userId: safeData['userId']?.toString() ?? '',
              telegramId: int.tryParse(safeData['telegramId']?.toString() ?? '0') ?? 0,
              firstName: safeData['firstName']?.toString() ?? '',
              lastName: safeData['lastName']?.toString() ?? '',
              phone: safeData['phone']?.toString(),
              totalSpent: (safeData['totalSpent'] as num?)?.toDouble() ?? 0.0,
              status: safeData['status']?.toString() ?? 'Start',
              discount: int.tryParse(safeData['discount']?.toString() ?? '0') ?? 0,
            );
          });
        } else {
          setState(() => _error = 'Не удалось загрузить данные');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Ошибка сети');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    
    if (_error != null || _user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карта лояльности'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(_error ?? 'Данные не загружены', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () { 
                  if (mounted) setState(() { _loading = true; _error = null; }); 
                  _loadUser(); 
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      );
    }

    final fullName = '${_user!.firstName} ${_user!.lastName}'.trim();
    return Scaffold(
      appBar: AppBar(title: const Text('Карта лояльности'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity, 
              padding: const EdgeInsets.all(20), 
              decoration: BoxDecoration(
                gradient: AppColors.loyaltyGradient, 
                borderRadius: BorderRadius.circular(20), 
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))]
              ), 
              child: Column(
                children: [
                  const Text('БАЗИЛЬ КАФЕ', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  const Text('Программа лояльности', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12), 
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), 
                    child: QrImageView(
                      data: 'LOYALTY:${_user!.userId}',  // ← ИСПРАВЛЕНО: именованный параметр 
                      version: QrVersions.auto, 
                      size: 180, 
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(fullName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), 
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)), 
                    child: Text('${_user!.status} • ${_user!.discount}% скидка', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))
                  ),
                  const SizedBox(height: 4),
                  Text('ID: ${_user!.userId}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
              child: Padding(
                padding: const EdgeInsets.all(16), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    const Text('Информация', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const Divider(height: 24),
                    _infoRow('📱 Телефон', _user!.phone ?? 'Не указан'),
                    _infoRow('💰 Всего потрачено', '${_user!.totalSpent.toStringAsFixed(0)} ₽'),
                    _infoRow('🏷️ Текущая скидка', '${_user!.discount}%'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)), 
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500))
        ],
      ),
    );
  }
}