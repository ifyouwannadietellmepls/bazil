import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';

class EventsManagementScreen extends StatefulWidget {
  const EventsManagementScreen({super.key});
  @override
  State<EventsManagementScreen> createState() => _EventsManagementScreenState();
}

class _EventsManagementScreenState extends State<EventsManagementScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadEvents();
        _startAutoRefresh();
      }
    });
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('${AuthService.baseUrl}/api/events'));
      if (res.statusCode == 200 && mounted) {
        final events = jsonDecode(res.body) as List;
        setState(() => _events = events.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteEvent(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить мероприятие?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final res = await http.delete(Uri.parse('${AuthService.baseUrl}/api/events/$id'));
      if (res.statusCode == 200 && mounted) {
        _loadEvents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Удалено'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEditDialog([Map<String, dynamic>? event]) {
    final titleCtrl = TextEditingController(text: event?['title'] ?? '');
    final dateCtrl = TextEditingController(text: event?['date'] ?? '');
    final timeCtrl = TextEditingController(text: event?['time'] ?? '');
    final descCtrl = TextEditingController(text: event?['description'] ?? '');
    final iconCtrl = TextEditingController(text: event?['icon'] ?? 'event');
    final isActive = ValueNotifier<bool>(event?['isActive'] ?? true);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(event == null ? '➕ Добавить мероприятие' : '✏️ Редактировать'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Дата (ДД.ММ.ГГГГ)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Время (ЧЧ:ММ)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()), maxLines: 3),
              const SizedBox(height: 12),
              TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'Иконка (music_note, quiz, sports_soccer)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: isActive,
                builder: (context, value, _) => SwitchListTile(
                  title: const Text('Активно'),
                  value: value,
                  onChanged: (v) => isActive.value = v,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty || dateCtrl.text.isEmpty) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Заполните обязательные поля')));
                }
                return;
              }
              final payload = {
                'title': titleCtrl.text,
                'date': dateCtrl.text,
                'time': timeCtrl.text,
                'description': descCtrl.text,
                'icon': iconCtrl.text.isNotEmpty ? iconCtrl.text : 'event',
                'isActive': isActive.value,
              };
              try {
                final res = event == null
                    ? await http.post(
                        Uri.parse('${AuthService.baseUrl}/api/events'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode(payload),
                      )
                    : await http.put(
                        Uri.parse('${AuthService.baseUrl}/api/events/${event['id']}'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode(payload),
                      );
                if ((res.statusCode == 200 || res.statusCode == 201) && ctx.mounted) {
                  Navigator.pop(ctx);
                  if (mounted) {
                    _loadEvents();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(event == null ? '✅ Добавлено' : '✅ Обновлено'), backgroundColor: Colors.green),
                    );
                  }
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление мероприятиями'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showEditDialog()),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEvents),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('Нет мероприятий. Добавьте первое!'))
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      color: (event['isActive'] == false) ? Colors.grey[200] : null,
                      child: ListTile(
                        leading: Icon(_getIconData(event['icon']), color: AppColors.primary, size: 28),
                        title: Text(event['title'] ?? ''),
                        subtitle: Text('${event['date']} • ${event['time']}\n${event['description'] ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _showEditDialog(event)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteEvent(event['id'])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconData(String? icon) {
    switch (icon) {
      case 'music_note': return Icons.music_note;
      case 'quiz': return Icons.quiz;
      case 'sports_soccer': return Icons.sports_soccer;
      case 'celebration': return Icons.celebration;
      case 'movie': return Icons.movie;
      default: return Icons.event;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}