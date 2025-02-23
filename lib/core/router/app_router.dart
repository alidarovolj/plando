import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:plando/core/services/storage_service.dart';
import 'package:plando/features/home/presentation/pages/home_page.dart';
import 'package:plando/features/login/presentation/pages/code_page.dart';
import 'package:plando/features/login/presentation/pages/forgot_password_page.dart';
import 'package:plando/features/login/presentation/pages/guest_page.dart';
import 'package:plando/features/login/presentation/pages/known_login_page.dart';
import 'package:plando/features/login/presentation/pages/login_page.dart';
import 'package:plando/features/login/presentation/pages/registration_page.dart';
import 'package:plando/features/login/presentation/pages/username_page.dart';
import 'package:plando/features/splash/presentation/pages/splash_page.dart';
import 'package:plando/features/storybook/presentation/pages/storybook.dart';
// import 'package:plando/core/widgets/main_tabbar_screen.dart';
import 'package:plando/features/onboarding/presentation/pages/onboarding_page.dart';

class AppRouter {
  static const _storage = FlutterSecureStorage();

  static String? _initialLocation;

  static Future<String?> _redirect(
      BuildContext context, GoRouterState state) async {
    final isAuthenticated = await _storage.read(key: 'is_authenticated');

    // Allow these paths without authentication
    if (state.uri.path == '/' ||
        state.uri.path == '/login' ||
        state.uri.path == '/guest' ||
        state.uri.path == '/code' ||
        state.uri.path == '/username' ||
        state.uri.path == '/known-login' ||
        state.uri.path == '/forgot-password' ||
        state.uri.path == '/registration') {
      return null;
    }

    // If not authenticated and trying to access protected route, redirect to login
    if (isAuthenticated != 'true' && !state.uri.path.startsWith('/login')) {
      _initialLocation ??= state.uri.path;
      return '/login';
    }

    // If authenticated and on login page, redirect to home or saved location
    if (isAuthenticated == 'true' && state.uri.path == '/login') {
      final redirectTo = _initialLocation ?? '/home';
      _initialLocation = null;
      return redirectTo;
    }

    return null;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      // Main app routes (with a tab bar layout)
      // ShellRoute(
      //   builder: (context, state, child) {
      //     return MainTabBarScreen(
      //       currentRoute: state.uri.toString(),
      //       child: child,
      //     );
      //   },
      //   routes: [
      //     GoRoute(
      //       path: '/home',
      //       name: 'home',
      //       builder: (context, state) => const HomePage(),
      //     ),
      //   ],
      // ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      // Storybook and dynamic route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/guest',
        builder: (context, state) => const GuestPage(),
      ),
      GoRoute(
        path: '/code',
        builder: (context, state) => CodeInputScreen(
          email: state.extra as String,
        ),
      ),
      GoRoute(
        path: '/registration',
        builder: (context, state) => RegistrationPage(
          email: state.extra as String,
        ),
      ),
      GoRoute(
        path: '/username',
        builder: (context, state) {
          final Map<String, String> params = state.extra as Map<String, String>;
          return UsernamePage(
            email: params['email']!,
            password: params['password']!,
          );
        },
      ),
      // Storybook and dynamic route
      GoRoute(
        path: '/storybook',
        builder: (context, state) => const StorybookScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/known-login',
        builder: (context, state) => KnownLoginPage(
          email: state.extra as String,
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordPage(
          email: state.extra as String?,
        ),
      ),
    ],
  );
}
