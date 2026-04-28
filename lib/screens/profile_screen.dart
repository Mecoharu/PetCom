import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(appUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: userAsync.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (e, _) => Center(child: Text('Error: $e')),
       data: (user) {
  debugPrint('USER DATA: ${user?.fullName} | ${user?.email} | uid: ${user?.uid}');
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
      child: Column(
        children: [
          const SizedBox(height: 32),
          _ProfileMenuItem(
            icon: Icons.pets,
            label: 'My Posts',
            onTap: () => context.push('/my-posts'),
          ),
          const SizedBox(height: 12),
          _ProfileMenuItem(
            icon: Icons.assignment_outlined,
            label: 'Applicant',
            onTap: () => context.push('/my-applications'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () => ref.read(authServiceProvider).logout(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8622A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
},
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) context.go('/home');
          if (i == 1) context.go('/browse');
        },
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDD5C0), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE8622A), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C1810),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF8B5E3C)),
          ],
        ),
      ),
    );
  }
}