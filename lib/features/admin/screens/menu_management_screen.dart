import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});
  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  List<Map<String, dynamic>> _menuItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('${AuthService.baseUrl}/api/menu'));
      if (res.statusCode == 200 && mounted) {
        final items = jsonDecode(res.body) as List;
        setState(() => _menuItems = items.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteItem(String id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Удалить блюдо?'),
      content: const Text('Это действие нельзя отменить'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Удалить')),
      ],
    ));
    if (confirm != true) return;
    try {
      final res = await http.delete(Uri.parse('${AuthService.baseUrl}/api/menu/$id'));
      if (res.statusCode == 200 && mounted) {
        _loadMenu();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Удалено'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red));
    }
  }

  void _showEditDialog([Map<String, dynamic>? item]) {
    final nameCtrl = TextEditingController(text: item?['name'] ?? '');
    final descCtrl = TextEditingController(text: item?['description'] ?? '');
    final priceCtrl = TextEditingController(text: item?['price'] ?? '');
    final categoryCtrl = TextEditingController(text: item?['category'] ?? '');
    final isActive = ValueNotifier<bool>(item?['isActive'] ?? true);

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(item == null ? '➕ Добавить блюдо' : '✏️ Редактировать'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Категория', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Цена (₽)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        ValueListenableBuilder<bool>(valueListenable: isActive, builder: (context, value, _) => SwitchListTile(title: const Text('Активно'), value: value, onChanged: (v) => isActive.value = v)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        ElevatedButton(onPressed: () async {
          if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Заполните обязательные поля')));
            return;
          }
          final payload = {'name': nameCtrl.text, 'category': categoryCtrl.text, 'description': descCtrl.text, 'price': priceCtrl.text, 'isActive': isActive.value};
          try {
            final res = item == null
                ? await http.post(Uri.parse('${AuthService.baseUrl}/api/menu'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload))
                : await http.put(Uri.parse('${AuthService.baseUrl}/api/menu/${item['id']}'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));
            if (res.statusCode == 200 || res.statusCode == 201) {
              Navigator.pop(ctx);
              _loadMenu();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(item == null ? '✅ Добавлено' : '✅ Обновлено'), backgroundColor: Colors.green));
            }
          } catch (e) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red));
          }
        }, child: const Text('Сохранить')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Управление меню'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: () => _showEditDialog()),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMenu),
      ]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _menuItems.isEmpty ? const Center(child: Text('Меню пустое. Добавьте блюда!')) : ListView.builder(
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), color: (item['isActive'] == false) ? Colors.grey[200] : null, child: ListTile(
            title: Text(item['name'] ?? ''),
            subtitle: Text('${item['category']} • ${item['price']} ₽'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _showEditDialog(item)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteItem(item['id'])),
            ]),
          ));
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showEditDialog(), backgroundColor: AppColors.primary, child: const Icon(Icons.add)),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}