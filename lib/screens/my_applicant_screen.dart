import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/adoption_service.dart';
import '../models/adoption_application.dart';
import '../widgets/widgets.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adopt Your Pet'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: () => context.push('/my-posts'),
            child: Text('My post', style: GoogleFonts.nunito(color: const Color(0xFFE8622A), fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return EmptyState(
              emoji: '🐾',
              title: 'No applications yet',
              subtitle: 'Find your dream pet and apply to adopt now!',
              buttonLabel: 'Find Your Pet', onButton: () => context.push('/browse'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: apps.length,
            itemBuilder: (_, i) => _AppCard(application: apps[i]),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
     
    );
  }
}

class _AppCard extends StatelessWidget {
  final AdoptionApplication application;
  const _AppCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      ApplicationStatus.pending: const Color(0xFFFFB347),
      ApplicationStatus.approved: const Color(0xFF4CAF50),
      ApplicationStatus.rejected: Colors.red.shade400,
    };
    final statusEmoji = {
      ApplicationStatus.pending: '',
      ApplicationStatus.approved: '',
      ApplicationStatus.rejected: '',
    };
    final color = statusColors[application.status]!;
    final emoji = statusEmoji[application.status]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(application.petName, style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w600)),
                      Text('Submitted ${DateFormat('dd MMM yyyy').format(application.appliedAt)}',
                          style: Theme.of(context).textTheme.bodyMedium),
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

            if (application.status == ApplicationStatus.approved) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Congratulations! Your adoption application was succes ${application.petName}',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF2E7D32))),
                    ),
                  ],
                ),
              ),
            ],

            if (application.status == ApplicationStatus.rejected) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Your request wasnt successful this time',
                        style: GoogleFonts.nunito(fontSize: 13, color: Colors.red.shade700))),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.home_outlined, size: 14, color: Color(0xFF8B5E3C)),
                const SizedBox(width: 4),
                Text(application.housingType, style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                Text('See Detail', style: GoogleFonts.nunito(color: const Color(0xFFE8622A), fontWeight: FontWeight.w700, fontSize: 13)),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFE8622A)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
