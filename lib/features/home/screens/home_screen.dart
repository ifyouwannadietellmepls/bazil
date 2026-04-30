import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../core/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _eventsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _startAutoRefresh();
  }

  Future<void> _loadEvents() async {
    try {
      final res = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/events?active=true'),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200 && mounted) {
        final events = jsonDecode(res.body) as List;
        setState(() {
          _events = events.cast<Map<String, dynamic>>();
          _eventsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _eventsLoading = false);
    }
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadEvents();
        _startAutoRefresh();
      }
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C5F2D), Color(0xFF1A4A1B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.restaurant, size: 72, color: Colors.white.withValues(alpha: 0.95)),
                      const SizedBox(height: 12),
                      const Text('БАЗИЛЬ КАФЕ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text('Авторская кухня • Уютная атмосфера • Живые события', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _infoCard('🌿 О кафе', 'БАЗИЛЬ — это место, где сочетаются авторская кухня, живая музыка и атмосфера настоящего отдыха. Мы готовим из свежих продуктов, используем домашнее тесто и фирменные рецепты. Приходите за вкусной едой и хорошим настроением!'),
                _infoCard('📍 Контакты', '📍 ул. Герцена, 56, Томск\n🕐 Пн-Вс: 10:00 – 23:00 (кухня до 22:30)\n📞 +7 (3822) 90-12-34\n🌐 cafebazil.ru', isContacts: true, onCall: () => _makeCall('83822901234'), onSite: () => _openUrl('https://cafebazil.ru')),
                
                // === ДИНАМИЧЕСКИЕ СОБЫТИЯ ===
                const Padding(padding: EdgeInsets.only(top: 16, bottom: 8), child: Text('📅 Ближайшие события', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                if (_eventsLoading)
                  const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
                else if (_events.isEmpty)
                  const Padding(padding: EdgeInsets.all(16), child: Text('События загружаются...', style: TextStyle(color: Colors.white70)))
                else
                  ..._events.take(3).map((e) => _eventCard(
                        e['title'] ?? 'Событие',
                        '${e['date']} • ${e['time']}',
                        e['description'] ?? '',
                        _getIconData(e['icon']),
                      )),
                
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: _actionButton('🍽️ Меню', '/menu', context)),
                  const SizedBox(width: 12),
                  Expanded(child: _actionButton('🎫 Карта', '/loyalty', context)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _actionButton('📞 Позвонить', 'tel:83822901234', context, isPhone: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _actionButton('🌐 Сайт', 'https://cafebazil.ru', context, isUrl: true)),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _infoCard(String title, String content, {bool isContacts = false, VoidCallback? onCall, VoidCallback? onSite}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withValues(alpha: 0.15),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(color: Colors.white70, height: 1.4)),
            if (isContacts) ...[
              const SizedBox(height: 12),
              Row(children: [
                if (onCall != null) Expanded(child: ElevatedButton.icon(onPressed: onCall, icon: const Icon(Icons.phone, size: 18), label: const Text('Позвонить'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 10)))),
                if (onCall != null && onSite != null) const SizedBox(width: 8),
                if (onSite != null) Expanded(child: OutlinedButton.icon(onPressed: onSite, icon: const Icon(Icons.language, size: 18), label: const Text('Сайт'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white70), padding: const EdgeInsets.symmetric(vertical: 10)))),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _eventCard(String title, String subtitle, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white.withValues(alpha: 0.1),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber[300], size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        ]),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: () {},
      ),
    );
  }

  Widget _actionButton(String text, String target, BuildContext context, {bool isPhone = false, bool isUrl = false}) {
    return ElevatedButton(
      onPressed: () async {
        if (isPhone) {
          await _makeCall(target.replaceAll('tel:', ''));
        } else if (isUrl) {
          await _openUrl(target);
        } else {
          if (mounted) context.go(target);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
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
}