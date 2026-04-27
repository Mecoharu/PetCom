import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/adoption_service.dart';
import '../widgets/widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).asData?.value;
    final postsAsync = ref.watch(allPostsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome To PetCompanion, ${user?.fullName.split('').first?? 'Lets go find your friend'} 👋',
                            style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w600, color: const Color(0xFF2C1810))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: GestureDetector(
                  onTap: () => context.push('/browse'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEDD5C0), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Color(0xFF8B5E3C)),
                        const SizedBox(width: 12),
                        Text('Find your pet companion...', style: GoogleFonts.nunito(color: const Color(0xFF8B5E3C), fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Category chips
           SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), 
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
     
        Text(
          'Browse by category', 
          style: GoogleFonts.nunito(
            fontSize: 16, 
            fontWeight: FontWeight.w800, 
            color: const Color(0xFF2C1810)
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 85,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none, 
            children: const [
              _CategoryChip('🐕', 'Dog', Color(0xFFFFE0CC)),
              _CategoryChip('🐈', 'Cat', Color(0xFFCCE5FF)),
              _CategoryChip('🦜', 'Bird', Color(0xFFCCF2D8)),
              _CategoryChip('🐢', 'Reptile', Color(0xFFD9CCFF)),
              _CategoryChip('🐾', 'Other', Color(0xFFE8CCFF)),
            ],
          ),
        ),
      ],
    ),
  ),
),

            // Open Adopt Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: GestureDetector(
                  onTap: () => context.push('/create'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8622A), Color(0xFFFFB347)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text('🏡', style: TextStyle(fontSize: 42)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Open Adopt', style: GoogleFonts.fredoka(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                              Text('Help your pet find a new home', style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Latest posts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: SectionTitle(
                  title: 'Find your new home🐾',
                  actionLabel: 'See all',
                  onAction: () => context.push('/browse'),
                ),
              ),
            ),

            postsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: EmptyState(emoji: '🐾', title: 'No posts yet', subtitle: 'Be the first to adopt it!'),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => PetCard(post: posts[i], onTap: () => context.push('/post/${posts[i].id}')),
                      childCount: posts.take(6).length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: LoadingWidget())),
              error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) return;
  switch (i) {
      case 1: context.push('/browse'); break;
      case 2: context.push('/create'); break;
      case 3: context.push('/my-applications'); break;
      case 4: context.push('/profile'); break;
  }
},
      ),
    );
  }
}
class _CategoryChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  const _CategoryChip(this.emoji, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/browse'),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label, 
                style: GoogleFonts.nunito(
                  fontSize: 10, 
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C1810)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}