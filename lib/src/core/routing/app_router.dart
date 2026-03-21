import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/email_verified_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/directory/provider_detail_screen.dart';
import '../../features/directory/providers_list_screen.dart';
import '../../features/admin/admin_screen.dart';
import '../../features/auth/landing_screen.dart';
import '../../features/auth/privacy_policy_screen.dart';
import '../../features/auth/terms_of_service_screen.dart';
import '../../features/profile/provider_application_screen.dart';
import '../auth/auth_providers.dart';
import '../supabase_client.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth stream so routes refresh correctly.
  ref.watch(authSessionProvider);
  final client = ref.watch(supabaseClientProvider);
  final refreshStream = client?.auth.onAuthStateChange.map((e) => e.session) ??
      const Stream<Session?>.empty();

  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: GoRouterRefreshStream(refreshStream),
    redirect: (context, state) {
      final session = ref.read(supabaseClientProvider)?.auth.currentSession;
      final loggedIn = session != null;

      final publicRoutes = [
        '/welcome',
        '/login',
        '/signup',
        '/terms',
        '/privacy',
        '/email-verified',
      ];

      final goingToPublicRoute = publicRoutes.contains(state.matchedLocation);

      if (!loggedIn && !goingToPublicRoute) return '/welcome';

      // If logged in, block access to auth screens only (welcome, login, signup)
      final authRoutes = ['/welcome', '/login', '/signup'];
      if (loggedIn && authRoutes.contains(state.matchedLocation)) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/email-verified',
        builder: (context, state) => const EmailVerifiedScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: '/provider-apply',
        builder: (context, state) => const ProviderApplicationScreen(),
      ),
      GoRoute(
        path: '/category/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProvidersListScreen(categoryId: id);
        },
      ),
      GoRoute(
        path: '/provider/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProviderDetailScreen(providerId: id);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
    ],
  );
});

/// Bridges a Stream into GoRouter refresh.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
