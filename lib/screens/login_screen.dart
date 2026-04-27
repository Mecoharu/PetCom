import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).login(email: _email.text.trim(), password: _pass.text);
    } catch (e) {
      if (mounted) _showError(_friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String e) {
    if (e.contains('user-not-found') || e.contains('wrong-password') || e.contains('invalid-credential')) return 'Email or password incorrect';
    if (e.contains('invalid-email')) return 'Invalid email format';
    return 'Try again';
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
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
                const SizedBox(height: 40),
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8622A),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: const Color(0xFFE8622A).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: const Center(child: Text('🐾', style: TextStyle(fontSize: 40))),
                      ),
                      const SizedBox(height: 20),
                      Text('Welcome!', style: Theme.of(context).textTheme.displayMedium),
                      const SizedBox(height: 8),
                      Text('Log in to find your Anabul', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                AppTextField(
                  controller: _email,
                  label: 'Email',
                  hint: 'nama@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Invalid email format';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _pass,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF8B5E3C)),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimal 6 character';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgot,
                    child: Text('forgot password?', style: GoogleFonts.nunito(color: const Color(0xFFE8622A), fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(label: 'login', onPressed: _login, isLoading: _loading),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Dont have an account yet?  ', style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text('Register now!', style: GoogleFonts.nunito(color: const Color(0xFFE8622A), fontWeight: FontWeight.w800, fontSize: 14)),
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

  Future<void> _showForgot() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Password', style: GoogleFonts.fredoka(fontSize: 22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email', style: GoogleFonts.nunito()),
            const SizedBox(height: 12),
            TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isNotEmpty) {
                await ref.read(authServiceProvider).resetPassword(ctrl.text.trim());
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email reset password sent! Check your inbox.')));
                }
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
