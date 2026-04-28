import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/adoption_service.dart';
import '../services/auth_service.dart';
import '../models/adoption_post.dart';
import '../widgets/widgets.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(allPostsProvider);
    final myPostsAsync = ref.watch(myPostsProvider);
    final currentUid = ref.watch(currentUserProvider)?.uid;


    AdoptionPost? post;
    postsAsync.whenData((posts) => post = posts.firstWhere((p) => p.id == postId, orElse: () => post!));
    if (post == null) {
      myPostsAsync.whenData((posts) {
        try { post = posts.firstWhere((p) => p.id == postId); } catch (_) {}
      });
    }

    if (post == null) {
      return const Scaffold(body: LoadingWidget());
    }

    final p = post!;
    final isOwner = p.ownerId == currentUid;
    final alreadyApplied = p.applicantIds.contains(currentUid);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Photo hero
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFFFFF8F0),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .9), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
              onPressed: () => context.pop(),
            ),
            actions: isOwner ? [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                  child: const Icon(Icons.edit_outlined, size: 18),
                ),
                onPressed: () => context.push('/create/${p.id}'),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                ),
                onPressed: () => _confirmDelete(context, ref, p),
              ),
            ] : null,
            flexibleSpace: FlexibleSpaceBar(
              background: p.photoUrls.isNotEmpty
                  ? PageView.builder(
                      itemCount: p.photoUrls.length,
                      itemBuilder: (_, i) => Image.network(p.photoUrls[i], fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFFFFF3E8),
                          child: Center(child: Text(p.typeEmoji, style: const TextStyle(fontSize: 80)))),
                      ),
                    )
                  : Container(color: const Color(0xFFFFF3E8),
                      child: Center(child: Text(p.typeEmoji, style: const TextStyle(fontSize: 100)))),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Row(
                    children: [
                      Expanded(child: Text(p.petName, style: GoogleFonts.fredoka(fontSize: 30, fontWeight: FontWeight.w600, color: const Color(0xFF2C1810)))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: p.isAvailable ? const Color(0xFF4CAF50).withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(p.statusLabel, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: p.isAvailable ? const Color(0xFF2E7D32) : Colors.grey.shade600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${p.typeLabel} • ${p.breed.isNotEmpty ? p.breed : 'Mixed'}', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),

                  // Info row
                  Row(
                    children: [
                      _InfoBox(emoji: '🎂', label: 'Age', value: p.ageLabel),
                      const SizedBox(width: 10),
                      _InfoBox(emoji: p.gender == PetGender.male ? '♂️' : '♀️', label: 'Gender', value: p.genderLabel),
                      const SizedBox(width: 10),
                     
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Health badges
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _Badge('💉 Vaksin', p.isVaccinated),
                      _Badge('✂️ Steril', p.isNeutered),
                      
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Location
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEDD5C0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFE8622A), size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p.location, style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: const Color(0xFF2C1810)))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('About ${p.petName}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(p.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
                  const SizedBox(height: 20),

                  // Owner info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEDD5C0), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFFFE0CC),
                          backgroundImage: p.ownerPhotoUrl.isNotEmpty ? NetworkImage(p.ownerPhotoUrl) : null,
                          child: p.ownerPhotoUrl.isEmpty
                              ? Text(p.ownerName.isNotEmpty ? p.ownerName[0].toUpperCase() : '?',
                                  style: GoogleFonts.fredoka(color: const Color(0xFFE8622A), fontSize: 20))
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.ownerName, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15)),
                              Text('Owner', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Text(DateFormat('dd MMM yyyy').format(p.createdAt), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (isOwner)
                    OutlinedButton.icon(
                      onPressed: () => context.push('/post/${p.id}/applications'),
                      icon: const Icon(Icons.people_outline),
                      label: Text('See ${p.applicantIds.length} applicant'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE8622A), width: 2),
                        foregroundColor: const Color(0xFFE8622A),
                      ),
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isOwner && p.isAvailable
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEDD5C0), width: 1.5)),
              ),
              child: alreadyApplied
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF4CAF50)),
                      ),
                      child: Center(
                        child: Text('Application Submitted', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: const Color(0xFF2E7D32))),
                      ),
                    )
                  : PrimaryButton(
                      label: 'apply for adoption ${p.petName} 🐾',
                      onPressed: () => context.push('/post/${p.id}/apply'),
                    ),
            )
          : null,
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, AdoptionPost post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete', style: GoogleFonts.fredoka(fontSize: 22)),
        content: Text('Are u sure bro? ${post.petName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(adoptionServiceProvider).deletePost(post);
      if (context.mounted) context.pop();
    }
  }
}

class _InfoBox extends StatelessWidget {
  final String emoji, label, value;
  const _InfoBox({required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDD5C0)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(label, style: GoogleFonts.nunito(fontSize: 10, color: const Color(0xFF8B5E3C))),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final bool active;
  const _Badge(this.label, this.active);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4CAF50).withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? const Color(0xFF4CAF50) : Colors.grey.shade300),
      ),
      child: Text(label, style: GoogleFonts.nunito(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: active ? const Color(0xFF2E7D32) : Colors.grey.shade500)),
    );
  }
}
