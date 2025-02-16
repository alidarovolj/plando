import 'package:go_router/go_router.dart';
import 'package:plando/core/services/storage_service.dart';
import 'package:plando/features/home/presentation/pages/home_page.dart';
import 'package:plando/features/login/presentation/pages/code_page.dart';
import 'package:plando/features/login/presentation/pages/guest_page.dart';
import 'package:plando/features/login/presentation/pages/login_page.dart';
import 'package:plando/features/login/presentation/pages/registration_page.dart';
import 'package:plando/features/login/presentation/pages/username_page.dart';
import 'package:plando/features/splash/presentation/pages/splash_page.dart';
import 'package:plando/features/storybook/presentation/pages/storybook.dart';
import 'package:plando/core/widgets/main_tabbar_screen.dart';
import 'package:plando/features/onboarding/presentation/pages/onboarding_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final hasSeenOnboarding = await StorageService.getHasSeenOnboarding();
      if (!hasSeenOnboarding && state.uri.path != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      // Main app routes (with a tab bar layout)
      ShellRoute(
        builder: (context, state, child) {
          return MainTabBarScreen(
            currentRoute: state.uri.toString(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
        ],
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
      )
    ],
  );
}
