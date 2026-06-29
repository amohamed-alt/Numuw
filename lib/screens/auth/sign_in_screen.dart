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
      if (mounted) {
        setState(
          () => _message = 'تم إرسال رابط استعادة كلمة المرور إلى بريدك.',
        );
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
              const SizedBox(height: 28),
              const IconBadge(
                icon: '👶',
                background: AppColors.mintLight,
                size: 120,
                borderColor: AppColors.mintSoft,
              ),
              const SizedBox(height: 22),
              const Text(
                'مرحبًا بكِ في نُمُوّ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'سجّلي الدخول لمتابعة يوم طفلك بهدوء',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.secondaryText, height: 1.6),
              ),
              const SizedBox(height: 24),
              SoftCard(
                radius: 24,
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
                    AppTextField(
                      controller: _email,
                      label: 'البريد الإلكتروني',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
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
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: _loading ? null : _resetPassword,
                        child: const Text('نسيتِ كلمة المرور؟'),
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 8),
                      InfoBanner(message: _message!),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      InfoBanner(
                        message: _error!,
                        color: AppColors.danger,
                        background: AppColors.peachLight,
                        icon: Icons.error_outline_rounded,
                      ),
                    ],
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: 'تسجيل الدخول',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              ),
                        child: const Text('ليس لديكِ حساب؟ إنشاء حساب'),
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

String? _passwordValidator(String? value) {
  if ((value ?? '').length < 6) {
    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.';
  }
  return null;
}
