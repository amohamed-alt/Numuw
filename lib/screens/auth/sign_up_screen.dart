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
              Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: AppHeader(
                      title: 'حساب جديد',
                      subtitle: 'ابدئي متابعة يوم طفلك من مكان واحد',
                      showNotification: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SoftCard(
                radius: 24,
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
                    AppTextField(
                      controller: _email,
                      label: 'البريد الإلكتروني',
                      icon: Icons.email_outlined,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _password,
                      label: 'كلمة المرور',
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                      textDirection: TextDirection.ltr,
                      validator: _passwordValidator,
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 12),
                      InfoBanner(message: _message!),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      InfoBanner(
                        message: _error!,
                        color: AppColors.danger,
                        background: AppColors.peachLight,
                        icon: Icons.error_outline_rounded,
                      ),
                    ],
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: 'إنشاء الحساب',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('لديكِ حساب؟ تسجيل الدخول'),
                      ),
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
  if (!email.contains('@') || !email.contains('.')) {
    return 'اكتبي بريدًا إلكترونيًا صحيحًا.';
  }
  return null;
}

String? _passwordValidator(String? value) => (value ?? '').length < 6
    ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.'
    : null;
