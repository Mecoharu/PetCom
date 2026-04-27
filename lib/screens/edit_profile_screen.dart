import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/widgets.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  final _location = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(appUserProvider).asData?.value;
    if (user != null) {
      _name.text = user.fullName;
      _phone.text = user.phoneNumber ?? '';
      _bio.text = user.bio ?? '';
      _location.text = user.location ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _bio.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final uid = ref.read(currentUserProvider)!.uid;
      await ref.read(authServiceProvider).updateProfile(
            uid: uid,
            fullName: _name.text.trim(),
            phoneNumber: _phone.text.trim(),
            bio: _bio.text.trim(),
            location: _location.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil updated', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fail to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: Text(
              'Save',
              style: GoogleFonts.nunito(
                color: const Color(0xFFE8622A),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: const Color(0xFFE8622A),
                      child: Text(
                        _name.text.isNotEmpty ? _name.text[0].toUpperCase() : '?',
                        style: GoogleFonts.fredoka(color: Colors.white, fontSize: 40),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8622A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              AppTextField(
                controller: _name,
                label: 'Name',
                prefixIcon: Icons.person_outline,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Name is required';
                  if (v.length < 3) return 'minimal 3 charakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _phone,
                label: 'Phone number / WhatsApp',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _location,
                label: 'Location',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _bio,
                label: 'Bio',
                prefixIcon: Icons.info_outline,
                maxLines: 3,
              ),
              const SizedBox(height: 36),

              PrimaryButton(
                label: 'Save',
                onPressed: _save,
                isLoading: _loading,
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
