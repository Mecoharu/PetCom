import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/adoption_service.dart';
import '../models/adoption_post.dart';
import '../widgets/widgets.dart';

class MyPostsScreen extends ConsumerWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(myPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.pop()),
      ),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return EmptyState(
              emoji: '🏡', title: 'No Post Yet',
              subtitle: '',
              buttonLabel: 'Posting!', onButton: () => context.push('/create'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: posts.length,
            itemBuilder: (_, i) => _MyPostCard(post: posts[i]),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create'),
        backgroundColor: const Color(0xFFE8622A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Make a post', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _MyPostCard extends ConsumerWidget {
  final AdoptionPost post;
  const _MyPostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = post.isAvailable ? const Color(0xFF4CAF50) : Colors.grey.shade500;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 70, height: 70,
                    child: post.photoUrls.isNotEmpty
                        ? Image.network(post.photoUrls.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFFFF3E8), child: Center(child: Text(post.typeEmoji, style: const TextStyle(fontSize: 32)))))
                        : Container(color: const Color(0xFFFFF3E8), child: Center(child: Text(post.typeEmoji, style: const TextStyle(fontSize: 32)))),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.petName, style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w600)),
                      Text('${post.typeLabel} • ${post.breed.isNotEmpty ? post.breed : 'Mixed'}', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(post.statusLabel, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                        ),
                        const SizedBox(width: 8),
                        Text('📍 ${post.location}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatBadge('🙋 ${post.applicantIds.length}', 'applicant'),
                const SizedBox(width: 12),
                _StatBadge('📅 ${DateFormat('dd MMM').format(post.createdAt)}', 'posted'),
                const Spacer(),
                // Action buttons
                if (post.isAvailable) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFFE8622A)),
                    onPressed: () => context.push('/create/${post.id}'),
                    tooltip: 'Edit',
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton(
                  onPressed: () => context.push('/post/${post.id}/applications'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFE8622A), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                  child: Text('See applicant', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value, label;
  const _StatBadge(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF2C1810))),
      Text(label, style: GoogleFonts.nunito(fontSize: 10, color: const Color(0xFF8B5E3C))),
    ],
  );
}
