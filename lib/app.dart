import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/post_detail_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/my_posts_screen.dart';
import 'screens/my_applications_screen.dart';
import 'screens/post_applications_screen.dart';
import 'screens/apply_screen.dart';
import 'screens/profile_screen.dart';
//import 'screens/edit_profile_screen.dart';

class PetCompanionApp extends ConsumerWidget {
  const PetCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    final router = GoRouter(
      initialLocation: '/splash',
      redirect: (ctx, state) {
        return authState.when(
          data: (user) {
            final loggedIn = user != null;
            final loc = state.matchedLocation;
            final authRoutes = ['/login', '/register', '/splash',];
            if (!loggedIn && !authRoutes.contains(loc)) return '/login';
            if (loggedIn && authRoutes.contains(loc) && loc != '/splash') return '/home';
            return null;
          },
          loading: () => null,
          error: (_, __) => '/login',
        );
      },
     routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/browse', builder: (_, __) => const BrowseScreen()),
        GoRoute(path: '/post/:id', builder: (_, s) => PostDetailScreen(postId: s.pathParameters['id']!)),
        GoRoute(path: '/post/:id/apply', builder: (_, s) => ApplyScreen(postId: s.pathParameters['id']!)),
        GoRoute(path: '/post/:id/applications', builder: (_, s) => PostApplicationsScreen(postId: s.pathParameters['id']!)),
        GoRoute(path: '/create', builder: (_, __) => const CreatePostScreen()),
        GoRoute(path: '/create/:id', builder: (_, s) => CreatePostScreen(editPostId: s.pathParameters['id'])),
        GoRoute(path: '/my-posts', builder: (_, __) => const MyPostsScreen()),
        GoRoute(path: '/my-applications', builder: (_, __) => const MyApplicationsScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        //GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
      ],
    );

    return MaterialApp.router(
      title: 'PetCompanion',
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      routerConfig: router,
    );
  }

ThemeData _theme() {
  const bg = Color(0xFFFFF8F0);
  const primary = Color(0xFFE8622A);
  const secondary = Color(0xFF4CAF50);
  const textDark = Color(0xFF2C1810);
  const textMid = Color(0xFF8B5E3C);
  const border = Color(0xFFEDD5C0);
  final base = GoogleFonts.nunitoTextTheme();

  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: bg,
      onPrimary: Colors.white,
      onSurface: textDark,
    ),
    scaffoldBackgroundColor: bg,
    textTheme: base.copyWith(
      displayLarge: GoogleFonts.fredoka(fontSize: 34, fontWeight: FontWeight.w600, color: textDark),
      displayMedium: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.w600, color: textDark),
      titleLarge: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: textDark),
      titleMedium: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: textDark),
      bodyLarge: GoogleFonts.nunito(fontSize: 15, color: textDark),
      bodyMedium: GoogleFonts.nunito(fontSize: 13, color: textMid),
      labelLarge: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w600, color: textDark),
      iconTheme: const IconThemeData(color: textDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFF3E8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: border, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: border, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.nunito(color: textMid, fontSize: 14),
      prefixIconColor: textMid,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: border, width: 1.5),
      ),
    ),
  );
}
}