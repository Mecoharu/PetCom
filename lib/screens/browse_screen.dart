import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/adoption_service.dart';
import '../models/adoption_post.dart';
import '../widgets/widgets.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});
  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final _search = TextEditingController();
  PetType? _filterType;
  PetGender? _filterGender;
  String _query = '';

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(allPostsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Find Your Pet'), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.pop())),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, ras, lokasi...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF8B5E3C)),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.close, color: Color(0xFF8B5E3C)), onPressed: () { _search.clear(); setState(() => _query = ''); })
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                // Type filter chips
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(label: 'Semua', selected: _filterType == null, onTap: () => setState(() => _filterType = null)),
                      _FilterChip(label: ' Dog', selected: _filterType == PetType.dog, onTap: () => setState(() => _filterType = _filterType == PetType.dog ? null : PetType.dog)),
                      _FilterChip(label: ' Cat', selected: _filterType == PetType.cat, onTap: () => setState(() => _filterType = _filterType == PetType.cat ? null : PetType.cat)),
                      _FilterChip(label: ' Bird', selected: _filterType == PetType.bird, onTap: () => setState(() => _filterType = _filterType == PetType.bird ? null : PetType.bird)),
                      _FilterChip(label: ' Reptile', selected: _filterType == PetType.reptile, onTap: () => setState(() => _filterType = _filterType == PetType.reptile
                       ? null : PetType.reptile)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          Expanded(
            child: postsAsync.when(
              data: (posts) {
                final filtered = posts.where((p) {
                  final matchType = _filterType == null || p.petType == _filterType;
                  final matchGender = _filterGender == null || p.gender == _filterGender;
                  final matchQuery = _query.isEmpty ||
                      p.petName.toLowerCase().contains(_query) ||
                      p.breed.toLowerCase().contains(_query) ||
                      p.location.toLowerCase().contains(_query);
                  return matchType && matchGender && matchQuery;
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    emoji: '🔍',
                    title: 'Not Found',
                    subtitle: "",);
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => PetCard(post: filtered[i], onTap: () => context.push('/post/${filtered[i].id}')),
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
     
bottomNavigationBar: AppBottomNav(
  currentIndex: 1,
  onTap: (i) {
    if (i == 1) return;
    if (i == 0) context.go('/home');
    if (i == 2) context.go('/profile');
  },
),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8622A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xFFE8622A) : const Color(0xFFEDD5C0), width: 1.5),
        ),
        child: Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF2C1810))),
      ),
    );
  }
}
