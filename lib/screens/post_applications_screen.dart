import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/adoption_service.dart';
import '../models/adoption_application.dart';
import '../models/adoption_post.dart';
import '../widgets/widgets.dart';

class PostApplicationsScreen extends ConsumerWidget {
  final String postId;
  const PostApplicationsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(postApplicationsProvider(postId));
    final myPostsAsync = ref.watch(myPostsProvider);

    AdoptionPost? post;
    myPostsAsync.whenData((posts) {
      try { post = posts.firstWhere((p) => p.id == postId); } catch (_) {}
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(post != null ? 'Applicant ${post!.petName}' : 'adoption applicants'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.pop()),
      ),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const EmptyState(emoji: '🔍', title: 'Theres no applicant yet', subtitle: 'No one has yet applied to adopt this animal');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: apps.length,
            itemBuilder: (_, i) => _ApplicationCard(application: apps[i], post: post, ref: ref),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final AdoptionApplication application;
  final AdoptionPost? post;
  final WidgetRef ref;
  const _ApplicationCard({required this.application, required this.post, required this.ref});

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      ApplicationStatus.pending: const Color(0xFFFFB347),
      ApplicationStatus.approved: const Color(0xFF4CAF50),
      ApplicationStatus.rejected: Colors.red.shade400,
    };
    final color = statusColors[application.status]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22, backgroundColor: const Color(0xFFFFE0CC),
                  child: Text(application.applicantName.isNotEmpty ? application.applicantName[0].toUpperCase() : '?',
                      style: GoogleFonts.fredoka(color: const Color(0xFFE8622A), fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(application.applicantName, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text(application.applicantEmail, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(application.statusLabel, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12, color: color)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            _InfoRow('📱', 'HP/WA', application.applicantPhone),
            const SizedBox(height: 6),
            _InfoRow('🏠', 'Hunian', application.housingType),
            const SizedBox(height: 6),
            _InfoRow('🐾', 'Punya Hewan Lain', application.hasPetsAlready ? 'Ya' : 'Tidak'),
            const SizedBox(height: 12),

            Text('Reason:', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFF3E8), borderRadius: BorderRadius.circular(10)),
              child: Text(application.reason, style: GoogleFonts.nunito(fontSize: 13, height: 1.5)),
            ),


            const SizedBox(height: 10),
            Text('Submitted: ${DateFormat('dd MMM yyyy, HH:mm').format(application.appliedAt)}',
                style: GoogleFonts.nunito(fontSize: 11, color: const Color(0xFF8B5E3C))),

            // Action buttons
            if (application.status == ApplicationStatus.pending && post != null && post!.isAvailable) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(context, ApplicationStatus.rejected),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        minimumSize: const Size(0, 44),
                      ),
                      child: Text('Rejected', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(context, ApplicationStatus.approved),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        minimumSize: const Size(0, 44),
                      ),
                      child: Text('Accepted', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, ApplicationStatus status) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(status == ApplicationStatus.approved ? 'Approve the Adoption?' : 'Reject the Request?',
            style: GoogleFonts.fredoka(fontSize: 22)),
        content: Text(status == ApplicationStatus.approved
            ? '${application.applicantName} will be designated as an adopter  ${application.petName}. The post will close automatically.'
            : 'Request ${application.applicantName} will be rejected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == ApplicationStatus.approved ? const Color(0xFF4CAF50) : Colors.red,
              minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(status == ApplicationStatus.approved ? 'Yes,Approve': 'Yes, Reject'),
          ),
        ],
      ),
    );

    if (ok == true && post != null && context.mounted) {
      await ref.read(adoptionServiceProvider).updateApplicationStatus(
        application: application, newStatus: status, post: post!,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(status == ApplicationStatus.approved ? 'Adoption approved!' : 'Application denied'),
          backgroundColor: status == ApplicationStatus.approved ? const Color(0xFF4CAF50) : Colors.red,
        ));
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String emoji, label, value;
  const _InfoRow(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 8),
      Text('$label: ', style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF8B5E3C))),
      Text(value, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700)),
    ],
  );
}
