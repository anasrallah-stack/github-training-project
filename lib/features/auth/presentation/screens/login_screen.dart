import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../routes/route_names.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo
                Center(
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 24)],
                    ),
                    child: const Icon(Icons.timer_rounded, size: 38, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(child: Text('TimeSync', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.w900,
                ))),
                const SizedBox(height: 6),
                Center(child: Text('تسجيل الدخول إلى حسابك', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 14,
                  color: isDark ? AppColors.textDark : AppColors.textSecondaryLight,
                ))),
                const SizedBox(height: 40),

                // Email field
                TextFormField(
                  controller: _emailCtrl,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 14),

                // Password field
                TextFormField(
                  controller: _passCtrl,
                  validator: Validators.password,
                  obscureText: _obscure,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(AppStrings.forgotPassword, style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(_error!, style: const TextStyle(
                      color: AppColors.error, fontFamily: 'Cairo', fontSize: 13,
                    )),
                  ),
                  const SizedBox(height: 12),
                ],

                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text(AppStrings.login),
                ),
                const SizedBox(height: 16),

                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('أو', style: TextStyle(
                      fontFamily: 'Cairo', color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    )),
                  ),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _loading ? null : _googleSignIn,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Image.network(
                    'https://www.google.com/favicon.ico',
                    width: 20, height: 20,
                    errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
                  ),
                  label: const Text(AppStrings.signInWithGoogle, style: TextStyle(fontFamily: 'Cairo', fontSize: 15)),
                ),
                const SizedBox(height: 32),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(AppStrings.dontHaveAccount, style: TextStyle(
                    fontFamily: 'Cairo',
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  )),
                  TextButton(
                    onPressed: () => context.push(RouteNames.register),
                    child: const Text(AppStrings.createAccount, style: TextStyle(
                      fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                    )),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final ok = await ref.read(currentUserProvider.notifier).login(
      _emailCtrl.text.trim(), _passCtrl.text,
    );
    if (!mounted) return;
    if (!ok) setState(() { _error = AppStrings.loginFailed; });
    setState(() => _loading = false);
  }

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _error = null; });
    await ref.read(currentUserProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
  }
}
