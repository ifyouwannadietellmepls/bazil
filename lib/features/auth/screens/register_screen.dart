import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;
  bool _smsSent = false;
  bool _codeVerified = false;
  String? _generatedCode;
  String? _error;

  void _formatPhone(String value) {
    String clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('7')) clean = clean.substring(1);
    if (clean.length > 10) clean = clean.substring(0, 10);
    _phoneCtrl.text = clean.isNotEmpty ? '+7$clean' : '';
    _phoneCtrl.selection = TextSelection.fromPosition(TextPosition(offset: _phoneCtrl.text.length));
  }

  Future<void> _sendSmsCode() async {
    if (_phoneCtrl.text.length != 12) { setState(() => _error = 'Введите номер в формате +7XXXXXXXXXX'); return; }
    setState(() { _loading = true; _error = null; });
    final ok = await AuthService.sendSmsCode(_phoneCtrl.text, purpose: 'register');
    if (mounted) {
      if (ok) {
        _generatedCode = (DateTime.now().millisecondsSinceEpoch % 9000 + 1000).toString();
        print('🔐 SMS-код для регистрации: $_generatedCode');
        setState(() { _smsSent = true; _loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Код отправлен (для теста: $_generatedCode)')));
      } else {
        setState(() { _error = 'Ошибка отправки кода'; _loading = false; });
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_codeCtrl.text.length != 4) { setState(() => _error = 'Введите 4-значный код'); return; }
    setState(() { _loading = true; _error = null; });
    final ok = _codeCtrl.text == _generatedCode;
    if (mounted) {
      if (ok) {
        setState(() { _codeVerified = true; _loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Телефон подтверждён'), backgroundColor: Colors.green));
      } else {
        setState(() { _error = 'Неверный код'; _loading = false; });
      }
    }
  }

  Future<void> _register() async {
    if (!_codeVerified) { setState(() => _error = 'Подтвердите телефон кодом'); return; }
    if (_passCtrl.text.length < 4) { setState(() => _error = 'Пароль минимум 4 символа'); return; }
    if (_nameCtrl.text.isEmpty) { setState(() => _error = 'Введите имя'); return; }
    setState(() { _loading = true; _error = null; });
    final ok = await AuthService.register(_phoneCtrl.text, _passCtrl.text, _nameCtrl.text, _surnameCtrl.text);
    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Регистрация успешна!'), backgroundColor: Colors.green));
        context.pop();
      } else {
        setState(() { _error = 'Ошибка регистрации. Возможно, телефон занят.'; _loading = false; });
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
      appBar: AppBar(title: const Text('Регистрация'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Имя', border: const OutlineInputBorder(), filled: true, fillColor: theme.cardColor), style: TextStyle(color: textColor), enabled: !_smsSent),
            const SizedBox(height: 16),
            TextField(controller: _surnameCtrl, decoration: InputDecoration(labelText: 'Фамилия', border: const OutlineInputBorder(), filled: true, fillColor: theme.cardColor), style: TextStyle(color: textColor), enabled: !_smsSent),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _formatPhone,
              decoration: InputDecoration(
                labelText: 'Телефон', hintText: '+7XXXXXXXXXX',
                border: const OutlineInputBorder(), filled: true, fillColor: theme.cardColor,
                suffixIcon: IconButton(icon: const Icon(Icons.sms), onPressed: _smsSent ? null : _sendSmsCode),
              ),
              style: TextStyle(color: textColor), enabled: !_smsSent,
            ),
            if (_smsSent && !_codeVerified) ...[
              const SizedBox(height: 16),
              Text('Введите код из SMS', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: _codeCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '1234'), maxLength: 4, style: TextStyle(color: textColor))),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _loading ? null : _verifyCode, child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Проверить')),
              ]),
            ],
            if (_codeVerified) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl, obscureText: _obscurePass,
                decoration: InputDecoration(
                  labelText: 'Пароль', border: const OutlineInputBorder(), filled: true, fillColor: theme.cardColor,
                  suffixIcon: IconButton(icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: hintColor), onPressed: () => setState(() => _obscurePass = !_obscurePass)),
                ),
                style: TextStyle(color: textColor),
              ),
            ],
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
              onPressed: _loading || (_smsSent && !_codeVerified) ? null : _register,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text(_smsSent && !_codeVerified ? 'Подтвердите телефон' : 'Создать аккаунт'),
            )),
            if (!_smsSent) TextButton(onPressed: () => context.pop(), child: Text('Уже есть аккаунт? Войти', style: TextStyle(color: AppColors.primary))),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose(); _passCtrl.dispose(); _nameCtrl.dispose(); _surnameCtrl.dispose(); _codeCtrl.dispose();
    super.dispose();
  }
}