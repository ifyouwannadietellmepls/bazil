import 'package:go_router/go_router.dart';
import '../core/services/auth_service.dart';
import '../features/home/screens/home_screen.dart';
import '../features/menu/screens/menu_screen.dart';
import '../features/loyalty/screens/loyalty_card_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/admin/screens/admin_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final userId = await AuthService.getUserId();
      final role = await AuthService.getRole();
      final isAuth = userId != null;
      final isLoginRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isAdminRoute = state.matchedLocation == '/admin';

      if (!isAuth && !isLoginRoute) return '/login';
      if (isAuth && isLoginRoute) return '/';
      if (isAuth && isAdminRoute && role != 'admin') return '/profile';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/menu', builder: (context, state) => const MenuScreen()),
      GoRoute(path: '/loyalty', builder: (context, state) => const LoyaltyCardScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
    ],
  );
}