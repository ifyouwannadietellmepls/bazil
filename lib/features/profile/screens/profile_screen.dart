import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../loyalty/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../main.dart'; // Для доступа к themeMode и saveTheme

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  List<Map<String, dynamic>> _transactions = [];
  bool _loadingUser = true;
  bool _loadingTransactions = false;
  bool _isDark = themeMode.value == ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final id = await AuthService.getUserId();
      if (id == null) {
        if (mounted) setState(() => _loadingUser = false);
        return;
      }

      final data = await AuthService.fetchUser(id);
      if (data != null && mounted) {
        setState(() {
          _user = User(
            userId: data['userId']?.toString() ?? '',
            telegramId: int.tryParse(data['telegramId']?.toString() ?? '0') ?? 0,
            firstName: data['firstName']?.toString() ?? '',
            lastName: data['lastName']?.toString() ?? '',
            phone: data['phone']?.toString(),
            totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
            status: data['status']?.toString() ?? 'Start',
            discount: int.tryParse(data['discount']?.toString() ?? '0') ?? 0,
          );
        });
        // Загружаем историю сразу после профиля
        await _loadTransactions(_user!.userId);
      }
    } catch (e) {
      print('Profile load error: $e');
    } finally {
      if (mounted) setState(() => _loadingUser = false);
    }
  }

  Future<void> _loadTransactions(String userId) async {
    setState(() => _loadingTransactions = true);
    try {
      final res = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/users/$userId/transactions'),
      ).timeout(const Duration(seconds: 10));
      
      if (res.statusCode == 200 && mounted) {
        final list = jsonDecode(res.body) as List;
        setState(() {
          _transactions = list.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print('Transactions load error: $e');
    } finally {
      if (mounted) setState(() => _loadingTransactions = false);
    }
  }

  void _toggleTheme(bool val) {
    setState(() => _isDark = val);
    saveTheme(val);
  }

  // === Диалог редактирования профиля ===
  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _user?.firstName);
    final surnameCtrl = TextEditingController(text: _user?.lastName);
    final phoneCtrl = TextEditingController(text: _user?.phone);
    final passCtrl = TextEditingController();
    bool _obscurePass = true;
    bool _phoneChanged = false;
    bool _smsSent = false;
    String? _generatedCode;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Редактировать профиль'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Имя', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: surnameCtrl, decoration: const InputDecoration(labelText: 'Фамилия', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Телефон',
                    hintText: '+7XXXXXXXXXX',
                    border: const OutlineInputBorder(),
                    suffixIcon: phoneCtrl.text != _user?.phone
                        ? IconButton(
                            icon: const Icon(Icons.sms),
                            onPressed: () async {
                              if (phoneCtrl.text.length != 12) {
                                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Введите номер в формате +7XXXXXXXXXX')));
                                return;
                              }
                              final ok = await AuthService.sendSmsCode(phoneCtrl.text, purpose: 'change_phone');
                              if (ok && ctx.mounted) {
                                _generatedCode = (DateTime.now().millisecondsSinceEpoch % 9000 + 1000).toString();
                                print('🔐 SMS-код для смены телефона ($phoneCtrl.text): $_generatedCode');
                                setDialogState(() => _smsSent = true);
                                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Код отправлен (для теста: $_generatedCode)')));
                              } else if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Ошибка отправки кода'), backgroundColor: Colors.red));
                              }
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) {
                    String clean = v.replaceAll(RegExp(r'\D'), '');
                    if (clean.startsWith('7')) clean = clean.substring(1);
                    if (clean.length > 10) clean = clean.substring(0, 10);
                    phoneCtrl.text = clean.isNotEmpty ? '+7$clean' : '';
                    phoneCtrl.selection = TextSelection.fromPosition(TextPosition(offset: phoneCtrl.text.length));
                    setDialogState(() => _phoneChanged = phoneCtrl.text != _user?.phone);
                  },
                ),
                if (_phoneChanged && _smsSent) ...[
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(labelText: 'Код из SMS', border: OutlineInputBorder(), hintText: '1234'),
                    maxLength: 4,
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: 'Новый пароль (опционально)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                if (phoneCtrl.text.length != 12) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Введите корректный номер телефона')));
                  return;
                }

                final updates = <String, dynamic>{
                  'firstName': nameCtrl.text,
                  'lastName': surnameCtrl.text,
                  'phone': phoneCtrl.text,
                };
                if (passCtrl.text.isNotEmpty) updates['password'] = passCtrl.text;

                final userId = await AuthService.getUserId();
                if (userId == null) return;

                final result = await AuthService.updateProfile(userId, updates);
                if (result != null && ctx.mounted) {
                  Navigator.pop(ctx);
                  setState(() {
                    _user = User(
                      userId: result['userId']?.toString() ?? '',
                      telegramId: int.tryParse(result['telegramId']?.toString() ?? '0') ?? 0,
                      firstName: result['firstName']?.toString() ?? '',
                      lastName: result['lastName']?.toString() ?? '',
                      phone: result['phone']?.toString(),
                      totalSpent: (result['totalSpent'] as num?)?.toDouble() ?? 0.0,
                      status: result['status']?.toString() ?? 'Start',
                      discount: int.tryParse(result['discount']?.toString() ?? '0') ?? 0,
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Профиль обновлён'), backgroundColor: Colors.green));
                } else if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('❌ Ошибка обновления'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  // === Диалог сброса пароля ===
  void _showForgotPasswordDialog() {
    if (_user == null) return;
    
    final phoneCtrl = TextEditingController(text: _user!.phone);
    final codeCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    bool _smsSent = false;
    bool _codeVerified = false;
    bool _loading = false;
    String? _generatedCode;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('🔑 Сброс пароля'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phoneCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Ваш телефон',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                if (!_smsSent)
                  ElevatedButton.icon(
                    onPressed: _loading ? null : () async {
                      setDialogState(() => _loading = true);
                      final ok = await AuthService.sendSmsCode(phoneCtrl.text, purpose: 'reset_password');
                      if (ok && ctx.mounted) {
                        _generatedCode = (DateTime.now().millisecondsSinceEpoch % 9000 + 1000).toString();
                        print('🔐 SMS-код для сброса пароля ($phoneCtrl.text): $_generatedCode');
                        setDialogState(() { _smsSent = true; _loading = false; });
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Код отправлен (для теста: $_generatedCode)')));
                      } else if (ctx.mounted) {
                        setDialogState(() => _loading = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Ошибка отправки кода'), backgroundColor: Colors.red));
                      }
                    },
                    icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sms),
                    label: Text(_loading ? 'Отправка...' : 'Отправить код'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                if (_smsSent && !_codeVerified) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: codeCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(labelText: 'Код из SMS', border: OutlineInputBorder(), hintText: '1234'),
                    maxLength: 4,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (codeCtrl.text == _generatedCode) {
                        setDialogState(() => _codeVerified = true);
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('✅ Код подтверждён'), backgroundColor: Colors.green));
                      } else {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('❌ Неверный код'), backgroundColor: Colors.red));
                      }
                    },
                    child: const Text('Подтвердить код'),
                  ),
                ],
                if (_codeVerified) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Новый пароль', border: OutlineInputBorder(), hintText: 'Минимум 4 символа'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (newPassCtrl.text.length < 4) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Пароль слишком короткий')));
                        return;
                      }
                      setDialogState(() => _loading = true);
                      final userId = await AuthService.getUserId();
                      if (userId == null) return;
                      
                      final result = await AuthService.updateProfile(userId, {'password': newPassCtrl.text});
                      if (result != null && ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Пароль успешно изменён'), backgroundColor: Colors.green));
                      } else if (ctx.mounted) {
                        setDialogState(() => _loading = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('❌ Ошибка смены пароля'), backgroundColor: Colors.red));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Сохранить новый пароль'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Закрыть')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    if (_user == null) {
      return Scaffold(
        body: Center(child: TextButton(onPressed: () => context.go('/login'), child: const Text('Войти снова'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _showEditProfileDialog),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(36)),
                      child: Icon(Icons.person, size: 36, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_user!.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(_user!.phone ?? 'Телефон не указан', style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                            child: Text('ID: ${_user!.userId}', style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: AppColors.loyaltyGradient, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.card_membership, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text('Статус: ${_user!.status}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Text('🏷️ Скидка ${_user!.discount}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 12),
                    Text('💰 ${_user!.totalSpent.toStringAsFixed(0)} ₽', style: const TextStyle(color: Colors.white70)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Тёмная тема'),
                    subtitle: const Text('Бережёт глаза ночью'),
                    value: _isDark,
                    onChanged: _toggleTheme,
                    activeColor: AppColors.primary,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.lock_reset, color: AppColors.primary),
                    title: const Text('Сбросить пароль'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showForgotPasswordDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('📜 История зачислений', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        TextButton(
                          onPressed: _loadingTransactions ? null : () => _loadTransactions(_user!.userId),
                          child: _loadingTransactions
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Обновить'),
                        ),
                      ],
                    ),
                  ),
                  if (_transactions.isEmpty && !_loadingTransactions)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('Нет зачислений', style: TextStyle(color: AppColors.textSecondary))),
                    )
                  else if (_loadingTransactions)
                    const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
                  else
                    ..._transactions.map((t) => _transactionItem(t)).toList(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await AuthService.logout();
                  if (mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Выйти из аккаунта', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Версия 1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _transactionItem(Map<String, dynamic> t) {
    final date = t['createdAt']?.toString().substring(0, 10) ?? '—';
    final amount = (t['amount'] as num?)?.toDouble() ?? 0;
    final discount = t['discountApplied'] as int? ?? 0;
    final finalAmount = (t['finalAmount'] as num?)?.toDouble() ?? amount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📅 $date', style: const TextStyle(fontWeight: FontWeight.w500)),
              if (discount > 0) Text('Скидка $discount%', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (discount > 0) Text('$amount ₽', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough)),
              Text('$finalAmount ₽', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}