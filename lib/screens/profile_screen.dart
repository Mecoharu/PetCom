import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/adoption_service.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(appUserProvider);
    final myPostsAsync = ref.watch(myPostsProvider);
    final myAppsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      body: userAsync.when(
        data: (user) {
          if (user == null) return const LoadingWidget();
          final totalPosts = myPostsAsync.asData?.value.length ?? 0;
          final totalApps = myAppsAsync.asData?.value.length ?? 0;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: const Color(0xFFFFF8F0),
                leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.pop()),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.push('/edit-profile'),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE8622A), Color(0xFFFFB347)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                            child: user.photoUrl == null
                                ? Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                                    style: GoogleFonts.fredoka(fontSize: 32, color: const Color(0xFFE8622A)))
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(user.fullName, style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600)),
                          Text(user.email, style: GoogleFonts.nunito(fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats
                      Row(
                        children: [
                          Expanded(child: _StatCard('🏡', '$totalPosts', 'Post', () => context.push('/my-posts'))),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard('❤️', '$totalApps', 'Request', () => context.push('/my-applications'))),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard('🎉', '${user.totalAdoptions}', 'Adopted', () {})),
                        ],
                      ),

                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text('Tentang Saya', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(user.bio!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
                      ],

                      if (user.location != null && user.location!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFE8622A)),
                          const SizedBox(width: 6),
                          Text(user.location!, style: Theme.of(context).textTheme.bodyMedium),
                        ]),
                      ],

                      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.phone_outlined, size: 16, color: Color(0xFFE8622A)),
                          const SizedBox(width: 6),
                          Text(user.phoneNumber!, style: Theme.of(context).textTheme.bodyMedium),
                        ]),
                      ],

                      const SizedBox(height: 28),
                      Text('Kelola Adopsi', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),

                      _MenuTile(Icons.pets, 'My post', 'Manage the animals you’ve found homes for', () => context.push('/my-posts')),
                      _MenuTile(Icons.favorite_border, 'Request','The animal you want to adopt', () => context.push('/my-applications')),
                      _MenuTile(Icons.add_circle_outline, 'Start new Adoption', 'Post animals for adoption', () => context.push('/create')),

                      const SizedBox(height: 20),
                      Text('settings', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      _MenuTile(Icons.person_outline, 'Edit Profil', 'change photo, name, and bio', () => context.push('/edit-profile')),
                      _MenuTile(Icons.notifications_outlined, 'Notification', 'Manage notification adoption', () {}),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmLogout(context, ref),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: Text('Keluar', style: GoogleFonts.nunito(color: Colors.red, fontWeight: FontWeight.w800, fontSize: 15)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red, width: 2),
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 4,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/home'); break;
            case 1: context.push('/browse'); break;
            case 2: context.push('/create'); break;
            case 3: context.push('/my-applications'); break;
            case 4: break;
          }
        },
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Exit?', style: GoogleFonts.fredoka(fontSize: 24)),
        content: const Text('Are you sure to exit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(authServiceProvider).logout();
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, value, label;
  final VoidCallback onTap;
  const _StatCard(this.emoji, this.value, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDD5C0), width: 1.5),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.fredoka(fontSize: 22, color: const Color(0xFFE8622A), fontWeight: FontWeight.w600)),
          Text(label, style: GoogleFonts.nunito(fontSize: 11, color: const Color(0xFF8B5E3C))),
        ],
      ),
    ),
  );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _MenuTile(this.icon, this.title, this.subtitle, this.onTap);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEDD5C0), width: 1.5)),
    child: ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFFFE0CC), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFFE8622A), size: 20),
      ),
      title: Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(subtitle, style: GoogleFonts.nunito(fontSize: 12, color: const Color(0xFF8B5E3C))),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF8B5E3C)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
