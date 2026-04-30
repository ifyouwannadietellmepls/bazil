import 'dart:async'; // ← ДОБАВЛЕНО: для StreamSubscription
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/menu/screens/menu_screen.dart';
import 'features/loyalty/screens/loyalty_card_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/admin/screens/admin_screen.dart';
import 'features/admin/screens/menu_management_screen.dart';
import 'features/admin/screens/events_management_screen.dart';
import 'core/services/auth_service.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

void saveTheme(bool isDark) {
  themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) => MaterialApp.router(
        title: 'БАЗИЛЬ КАФЕ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light),
          scaffoldBackgroundColor: Colors.grey[50],
          cardColor: Colors.white,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark),
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardColor: const Color(0xFF1E1E1E),
        ),
        themeMode: mode,
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: GoRouterRefreshStream(AuthService.userIdStream),
  redirect: (context, state) async {
    final isLoggedIn = await AuthService.getUserId() != null;
    final isAuthRoute = state.uri.path == '/login' || state.uri.path == '/register';
    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => child,
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/menu', builder: (context, state) => const MenuScreen()),
        GoRoute(path: '/loyalty', builder: (context, state) => const LoyaltyCardScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminScreen(),
          routes: [
            GoRoute(path: 'menu', builder: (context, state) => const MenuManagementScreen()),
            GoRoute(path: 'events', builder: (context, state) => const EventsManagementScreen()),
          ],
        ),
      ],
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() { 
    _subscription.cancel(); 
    super.dispose(); 
  }
}