import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.onBack, this.onSignUp});

  final VoidCallback? onBack;
  final VoidCallback? onSignUp;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
      final auth = AuthService();
      await auth.signIn(email: _email.text, password: _password.text);
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
      final auth = AuthService();
      await auth.resetPassword(_email.text);
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
        padding: const EdgeInsetsDirectional.fromSTEB(24, 64, 24, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumuwHeader(
                title: 'مرحباً بعودتكِ 👋',
                subtitle: 'سجّلي الدخول للمتابعة',
                leading: AppIconButton(
                  icon: Icons.arrow_forward_rounded,
                  onPressed: widget.onBack,
                  badge: false,
                  size: 42,
                  radius: 13,
                  iconSize: 20,
                  borderWidth: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              NumuwTextField(
                controller: _email,
                label: 'البريد الإلكتروني',
                hint: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                validator: _emailValidator,
              ),
              const SizedBox(height: 16),
              NumuwPasswordField(
                controller: _password,
                label: 'كلمة المرور',
                validator: _passwordValidator,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextActionButton(
                  label: 'نسيتِ كلمة المرور؟',
                  onTap: _resetPassword,
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                InfoBanner(message: _message!),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                ErrorMessageCard(message: _error!),
              ],
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'تسجيل الدخول',
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                    ),
                    child: Text(
                      'أو',
                      style: TextStyle(
                        color: numuwSecondaryTextColor(),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 14),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      'ليس لديكِ حساب؟ ',
                      style: TextStyle(
                        color: numuwSecondaryTextColor(),
                        fontSize: 14,
                      ),
                    ),
                    TextActionButton(
                      label: 'إنشاء حساب',
                      onTap: widget.onSignUp ?? () {},
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

String? _passwordValidator(String? value) => (value ?? '').length < 6
    ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.'
    : null;
