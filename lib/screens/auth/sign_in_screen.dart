import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _message;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });
    try {
      await _auth.signIn(email: _email.text, password: _password.text);
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _error = readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_email.text.trim().isEmpty) {
      setState(
        () => _error = 'اكتبي البريد الإلكتروني أولًا لإرسال رابط الاستعادة.',
      );
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });
    try {
      await _auth.resetPassword(_email.text);
      if (mounted)
        setState(
          () => _message = 'تم إرسال رابط استعادة كلمة المرور إلى بريدك.',
        );
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _error = readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppPage(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const AppHeader(
                title: 'مرحبًا بكِ في نُمُوّ',
                subtitle: 'سجّلي الدخول لمتابعة يوم طفلك بهدوء',
                showNotification: false,
              ),
              const SizedBox(height: 24),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تسجيل الدخول',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'استخدمي بريدك الإلكتروني وكلمة المرور.',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AuthField(
                      controller: _email,
                      label: 'البريد الإلكتروني',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 12),
                    _AuthField(
                      controller: _password,
                      label: 'كلمة المرور',
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                      textDirection: TextDirection.ltr,
                      validator: _passwordValidator,
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 12),
                      _Message(_message!, AppColors.mint, AppColors.mintLight),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      _Message(_error!, AppColors.peach, AppColors.peachLight),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('دخول'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loading ? null : _resetPassword,
                      child: const Text('نسيت كلمة المرور؟'),
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: SignUpScreen(),
                                ),
                              ),
                            ),
                      child: const Text('ليس لديكِ حساب؟ أنشئي حسابًا جديدًا'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _emailValidator(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'اكتبي البريد الإلكتروني.';
  if (!email.contains('@') || !email.contains('.'))
    return 'اكتبي بريدًا إلكترونيًا صحيحًا.';
  return null;
}

String? _passwordValidator(String? value) {
  if ((value ?? '').length < 6)
    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.';
  return null;
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.textDirection,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textDirection: textDirection,
      textAlign: TextAlign.start,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.mint),
        filled: true,
        fillColor: AppColors.mintLight.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.message, this.color, this.background);
  final String message;
  final Color color;
  final Color background;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      message,
      textAlign: TextAlign.start,
      style: TextStyle(color: color, fontWeight: FontWeight.w800, height: 1.5),
    ),
  );
}
