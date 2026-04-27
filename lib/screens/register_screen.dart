import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false, _obscure = true, _obscureC = true;

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _phone.dispose();
    _pass.dispose(); _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).register(
        email: _email.text.trim(),
        password: _pass.text,
        fullName: _name.text.trim(),
        phoneNumber: _phone.text.trim().isNotEmpty ? _phone.text.trim() : null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_friendlyError(e.toString())),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String e) {
    if (e.contains('email-already-in-use')) return 'Email already registered';
    if (e.contains('weak-password')) return 'Password too weak, minimal 6 characters';
    if (e.contains('invalid-email')) return 'Invalid email';
    return 'Registration failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => context.go('/login'),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF3E8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Make new account', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
          

                AppTextField(controller: _name, label: 'Name', prefixIcon: Icons.person_outline,
                  validator: (v) { if (v == null || v.isEmpty) return 'require field'; if (v.length < 3) return 'Minimal 3 characters'; return null; }),
                const SizedBox(height: 14),

                AppTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined,
                  validator: (v) { if (v == null || v.isEmpty) return 'Email is required'; if (!v.contains('@')) return 'Invalid Format'; return null; }),
                const SizedBox(height: 14),

                AppTextField(controller: _phone, label: 'Phone number', keyboardType: TextInputType.phone, prefixIcon: Icons.phone_outlined),
                const SizedBox(height: 14),

                AppTextField(controller: _pass, label: 'Password', obscureText: _obscure, prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF8B5E3C)), onPressed: () => setState(() => _obscure = !_obscure)),
                  validator: (v) { if (v == null || v.isEmpty) return 'Password required'; if (v.length < 6) return 'Minimal 6 characters'; return null; }),
                const SizedBox(height: 14),

                AppTextField(controller: _confirm, label: 'Confirm Password', obscureText: _obscureC, prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(icon: Icon(_obscureC ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF8B5E3C)), onPressed: () => setState(() => _obscureC = !_obscureC)),
                  validator: (v) { if (v != _pass.text) return 'Password does not match'; return null; }),
                const SizedBox(height: 32),

                PrimaryButton(label: 'Register!', onPressed: _register, isLoading: _loading),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text('Login', style: GoogleFonts.nunito(color: const Color(0xFFE8622A), fontWeight: FontWeight.w800, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
