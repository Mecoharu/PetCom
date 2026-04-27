import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/adoption_service.dart';
import '../services/auth_service.dart';
import '../widgets/widgets.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  final String postId;
  const ApplyScreen({super.key, required this.postId});
  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _reason = TextEditingController();
  final _additional = TextEditingController();
  String _housingType = 'House';
  bool _hasPets = false;
  bool _loading = false;

  final _housingOptions = ['House', 'Apartemen', 'others'];

  @override
  void dispose() { _phone.dispose(); _reason.dispose(); _additional.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final appUser = ref.read(appUserProvider).asData?.value;
      final service = ref.read(adoptionServiceProvider);
      final post = await service.getPost(widget.postId);
      if (post == null || appUser == null) return;

      final application = service.buildApplication(
        postId: widget.postId,
        petName: post.petName,
        applicantName: appUser.fullName,
        applicantEmail: appUser.email,
        applicantPhone: _phone.text.trim(),
        reason: _reason.text.trim(),
        housingType: _housingType,
        hasPetsAlready: _hasPets,
        additionalInfo: _additional.text.trim().isNotEmpty ? _additional.text.trim() : null,
      );

      await service.applyToAdopt(application: application, ownerFcmToken: '');

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('Permohonan Terkirim!', style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Permohonan adopsi ${post.petName} telah dikirim. Tunggu konfirmasi dari pemilik ya!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(color: const Color(0xFF8B5E3C), height: 1.5)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () { Navigator.pop(context); context.pop(); context.pop(); },
                  child: const Text('Kembali ke Beranda'),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(appUserProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Adopsi'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.pop()),
      ),
      body: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDD5C0)),
                ),
                child: Row(
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Form application', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Applicant info 
              Text('Data Pemohon', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEDD5C0))),
                child: Column(
                  children: [
                    _ReadonlyRow(Icons.person_outline, 'Name', appUser?.fullName ?? '-'),
                    const Divider(height: 16),
                    _ReadonlyRow(Icons.email_outlined, 'Email', appUser?.email ?? '-'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(controller: _phone, label: 'Phone number / WhatsApp *', hint: '08xx-xxxx-xxxx', keyboardType: TextInputType.phone, prefixIcon: Icons.phone_outlined,
                validator: (v) => v?.isEmpty == true ? 'Mobile phone number is required' : null),
              const SizedBox(height: 16),

              
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _housingOptions.map((opt) {
                  final sel = _housingType == opt;
                  return GestureDetector(
                    onTap: () => setState(() => _housingType = opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFFE8622A) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? const Color(0xFFE8622A) : const Color(0xFFEDD5C0)),
                      ),
                      child: Text(opt, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13, color: sel ? Colors.white : const Color(0xFF2C1810))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEDD5C0))),
                child: CheckboxListTile(
                  title: Text('Sudah memiliki hewan peliharaan lain', style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 14)),
                  value: _hasPets,
                  onChanged: (v) => setState(() => _hasPets = v!),
                  activeColor: const Color(0xFFE8622A),
                  controlAffinity: ListTileControlAffinity.leading,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(controller: _reason, label: 'Reason to Adopt *', maxLines: 4, prefixIcon: Icons.favorite_outline,
                validator: (v) { if (v?.isEmpty == true) return 'required field'; if ((v?.length ?? 0) < 20) return 'Minimal 20 character'; return null; }),
              const SizedBox(height: 14),


              PrimaryButton(label: 'Submit an adoption application', onPressed: _submit, isLoading: _loading, icon: Icons.send),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadonlyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ReadonlyRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: const Color(0xFF8B5E3C)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.nunito(fontSize: 11, color: const Color(0xFF8B5E3C))),
        Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14)),
      ]),
    ],
  );
}
