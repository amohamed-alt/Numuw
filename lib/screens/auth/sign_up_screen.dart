import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
      final response = await _auth.signUp(
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      if (response.session == null) {
        setState(
          () => _message =
              'تم إنشاء الحساب. افتحي بريدك الإلكتروني واضغطي رابط التأكيد ثم سجّلي الدخول.',
        );
      } else {
        Navigator.of(context).pop();
      }
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
                title: 'حساب جديد',
                subtitle: 'ابدئي متابعة يوم طفلك من مكان واحد',
                showNotification: false,
              ),
              const SizedBox(height: 24),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'أدخلي بريدك الإلكتروني وكلمة مرور آمنة.',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _email,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                      decoration: _decoration(
                        'البريد الإلكتروني',
                        Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.start,
                      obscureText: true,
                      validator: _passwordValidator,
                      decoration: _decoration(
                        'كلمة المرور',
                        Icons.lock_outline_rounded,
                      ),
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
                            : const Text('إنشاء الحساب'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('لديكِ حساب؟ عودي لتسجيل الدخول'),
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

InputDecoration _decoration(String label, IconData icon) => InputDecoration(
  labelText: label,
  prefixIcon: Icon(icon, color: AppColors.mint),
  filled: true,
  fillColor: AppColors.mintLight.withValues(alpha: 0.35),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: const BorderSide(color: AppColors.border),
  ),
);

String? _emailValidator(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'اكتبي البريد الإلكتروني.';
  if (!email.contains('@') || !email.contains('.'))
    return 'اكتبي بريدًا إلكترونيًا صحيحًا.';
  return null;
}

String? _passwordValidator(String? value) => (value ?? '').length < 6
    ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.'
    : null;

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
