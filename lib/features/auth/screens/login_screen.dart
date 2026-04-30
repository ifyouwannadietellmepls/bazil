import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;
  String? _error;

  void _formatPhone(String value) {
    String clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('7')) clean = clean.substring(1);
    if (clean.length > 10) clean = clean.substring(0, 10);
    _phoneCtrl.text = clean.isNotEmpty ? '+7$clean' : '';
    _phoneCtrl.selection = TextSelection.fromPosition(TextPosition(offset: _phoneCtrl.text.length));
  }

  Future<void> _login() async {
    if (_phoneCtrl.text.length != 12 || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Введите телефон и пароль');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final user = await AuthService.login(_phoneCtrl.text, _passCtrl.text);
    if (mounted) {
      if (user != null) {
        final role = user['role'] ?? 'user';
        // ← ИСПРАВЛЕНО: правильный маршрут для обычного пользователя
        if (role == 'admin') {
          context.go('/admin');
        } else {
          context.go('/');  // ← Переход на главную (не /home!)
        }
      } else {
        setState(() {
          _error = 'Неверный телефон или пароль';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final hintColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant, size: 64, color: AppColors.primary),
                const SizedBox(height: 16),
                Text('БАЗИЛЬ КАФЕ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                Text('Вход в аккаунт', style: TextStyle(color: hintColor)),
                const SizedBox(height: 32),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  onChanged: _formatPhone,
                  decoration: InputDecoration(
                    labelText: 'Телефон', hintText: '+7XXXXXXXXXX',
                    prefixIcon: const Icon(Icons.phone),
                    border: const OutlineInputBorder(),
                    filled: true, fillColor: theme.cardColor,
                  ),
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    filled: true, fillColor: theme.cardColor,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: hintColor),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  style: TextStyle(color: textColor),
                ),
                if (_error != null) Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Войти', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: Text('Нет аккаунта? Зарегистрироваться', style: TextStyle(color: AppColors.primary, fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _phoneCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }
}