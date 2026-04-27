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
    final user = ref.watch(appUserProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Akun'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFFFF3E8),
                child: Text(
                  user?.fullName.isNotEmpty == true 
                      ? user!.fullName[0].toUpperCase() 
                      : '?',
                  style: GoogleFonts.fredoka(
                    fontSize: 40, 
                    fontWeight: FontWeight.bold, 
                    color: const Color(0xFFE8622A)
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Menampilkan Email Akun
              Text(
                user?.email ?? 'Email not found',
                style: GoogleFonts.nunito(
                  fontSize: 16, 
                  color: const Color(0xFF8B5E3C)
                ),
              ),
              
              const SizedBox(height: 48),

              
              SizedBox(
                width: 180,
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
      ),
  
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2, 
        onTap: (i) {
          if (i == 0) context.go('/home');
          if (i == 1) context.go('/browse');
          if (i == 2) return; 
        },
      ),
    );
  }
}