import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../core/services/auth_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _searchCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  Map<String, dynamic>? _selectedUser;
  bool _loading = false;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('${AuthService.baseUrl}/api/all-users'));
      if (res.statusCode == 200 && mounted) {
        final users = jsonDecode(res.body) as List;
        setState(() {
          _allUsers = users.cast<Map<String, dynamic>>();
          _filteredUsers = List.from(_allUsers);
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filterUsers(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        final name = (u['firstName']?.toString() ?? '').toLowerCase();
        final surname = (u['lastName']?.toString() ?? '').toLowerCase();
        final phone = (u['phone']?.toString() ?? '').toLowerCase();
        return name.contains(q) || surname.contains(q) || phone.contains(q);
      }).toList();
    });
  }

  Future<void> _addPurchase() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || _selectedUser == null) return;
    final adminId = await AuthService.getUserId();
    try {
      final res = await http.post(Uri.parse('${AuthService.baseUrl}/api/purchases'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'userId': _selectedUser!['userId'], 'amount': amount, 'adminId': adminId}));
      if (res.statusCode == 200 && mounted) {
        _loadUsers();
        _amountCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Покупка начислена!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red));
    }
  }

  void _confirmRoleChange(String userId, String name, bool makeAdmin) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(makeAdmin ? '🔑 Выдать права?' : '🚫 Забрать права?'),
      content: Text(makeAdmin ? 'Вы хотите сделать пользователя $name администратором?' : 'Вы хотите лишить пользователя $name прав администратора?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: makeAdmin ? AppColors.primary : Colors.red), onPressed: () { _toggleAdminRole(userId, makeAdmin); Navigator.pop(ctx); }, child: Text(makeAdmin ? 'Выдать' : 'Забрать', style: const TextStyle(color: Colors.white))),
      ],
    ));
  }

  Future<void> _toggleAdminRole(String userId, bool isAdmin) async {
    try {
      final currentAdminId = await AuthService.getUserId();
      final res = await http.put(Uri.parse('${AuthService.baseUrl}/api/users/$userId/role'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'role': isAdmin ? 'admin' : 'user', 'changedBy': currentAdminId}));
      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAdmin ? '✅ Права выданы' : '✅ Права забраны'), backgroundColor: Colors.green));
        _loadUsers();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Ошибка изменения роли'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red));
    }
  }

  void _startScan() => setState(() => _scanning = true);
  void _stopScan() => setState(() => _scanning = false);

  Future<void> _handleScan(String qrValue) async {
    _stopScan();
    if (qrValue.startsWith('LOYALTY:')) {
      final userId = qrValue.split(':').last.trim();
      final user = _allUsers.cast<Map<String, dynamic>?>().firstWhere((u) => u?['userId'] == userId, orElse: () => null);
      if (user != null && mounted) {
        setState(() => _selectedUser = user);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('👤 Найден: ${user['firstName']} ${user['lastName']}'), backgroundColor: Colors.green, duration: const Duration(seconds: 3)));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Пользователь не найден'), backgroundColor: Colors.red));
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Неверный формат QR'), backgroundColor: Colors.orange));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_scanning) {
      return Scaffold(appBar: AppBar(title: const Text('📷 Сканирование'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, leading: IconButton(icon: const Icon(Icons.close), onPressed: _stopScan)),
        body: Stack(children: [
          MobileScanner(onDetect: (capture) { for (final barcode in capture.barcodes) { if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) { _handleScan(barcode.rawValue!); break; } } }),
          Center(child: Container(width: 250, height: 250, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(20)))),
          Positioned(bottom: 30, left: 0, right: 0, child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: const Text('Наведите на QR-код карты', style: TextStyle(color: Colors.white, fontSize: 14))))),
        ]),
        bottomNavigationBar: const BottomNavBar(currentIndex: 4),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Админ-панель'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, actions: [
        IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _startScan),
        // ← НОВОЕ: Кнопка для управления мероприятиями
        IconButton(icon: const Icon(Icons.event), onPressed: () => context.push('/admin/events')),
        IconButton(icon: const Icon(Icons.restaurant_menu), onPressed: () => context.push('/admin/menu')),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
      ]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(labelText: 'Поиск (имя, фамилия, телефон)', hintText: 'Введите для поиска...', border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
          onChanged: _filterUsers,
          keyboardType: TextInputType.text,
        )),
        Expanded(
          child: _loading ? const Center(child: CircularProgressIndicator()) : _filteredUsers.isEmpty ? const Center(child: Text('Пользователи не найдены')) : ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              final isSelected = _selectedUser?['userId'] == user['userId'];
              final isAdmin = user['role'] == 'admin';
              return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), color: isSelected ? AppColors.secondary.withValues(alpha: 0.2) : null, child: ListTile(
                leading: CircleAvatar(backgroundColor: isAdmin ? AppColors.accent : AppColors.primary, child: isAdmin ? const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20) : Text(user['firstName']?[0]?.toString().toUpperCase() ?? '?', style: const TextStyle(color: Colors.white))),
                title: Row(children: [Flexible(child: Text('${user['firstName']} ${user['lastName'] ?? ''}', overflow: TextOverflow.ellipsis)), if (isAdmin) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)), child: const Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))]),
                subtitle: Text('${user['phone']} • ${user['status']} • ${user['discount']}%', overflow: TextOverflow.ellipsis),
                trailing: Wrap(spacing: 4, alignment: WrapAlignment.end, children: [
                  Text('${user['totalSpent']} ₽', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  OutlinedButton(onPressed: () => _confirmRoleChange(user['userId'], user['firstName'] ?? '', !isAdmin), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), side: BorderSide(color: isAdmin ? Colors.red : AppColors.primary), minimumSize: const Size(0, 28)), child: Text(isAdmin ? '🚫 Забрать' : '🔑 Выдать', style: TextStyle(color: isAdmin ? Colors.red : AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold))),
                ]),
                onTap: () => setState(() => _selectedUser = user),
              ));
            },
          ),
        ),
        if (_selectedUser != null) Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.background, border: Border(top: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)))), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Выбран: ${_selectedUser!['firstName']} ${_selectedUser!['lastName']}', style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: TextField(controller: _amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма чека (₽)', border: OutlineInputBorder(), isDense: true))), const SizedBox(width: 8), ElevatedButton(onPressed: _addPurchase, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)), child: const Text('Начислить'))]),
        ])),
      ]),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }
}