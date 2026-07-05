import 'package:flutter/material.dart';

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
  bool _obscure = true;
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
      await AuthService().signIn(
        email: _email.text,
        password: _password.text,
      );
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
      await AuthService().resetPassword(_email.text);
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
      backgroundColor: numuwPageColor(),
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(22, 28, 22, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.onBack != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppIconButton(
                    icon: Icons.arrow_forward_rounded,
                    onPressed: widget.onBack,
                    badge: false,
                    size: 44,
                    radius: 14,
                    iconSize: 21,
                  ),
                ),
              const SizedBox(height: 22),
              const _AuthLogo(),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'أهلًا بعودتكِ',
                  style: TextStyle(
                    color: numuwTextColor(),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  'سجّلي الدخول للمتابعة مع نُمُوّ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              NumuwTextField(
                controller: _email,
                label: 'البريد الإلكتروني',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                validator: _emailValidator,
              ),
              const SizedBox(height: 16),
              Text(
                'كلمة المرور',
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                textDirection: TextDirection.ltr,
                validator: _passwordValidator,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: _resetPassword,
                  child: const Text('نسيتِ كلمة المرور؟'),
                ),
              ),
              if (_message != null) ...[
                InfoBanner(message: _message!),
                const SizedBox(height: 12),
              ],
              if (_error != null) ...[
                ErrorMessageCard(message: _error!),
                const SizedBox(height: 12),
              ],
              PrimaryButton(
                label: 'تسجيل الدخول',
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: Divider(color: numuwBorderColor())),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                    ),
                    child: Text(
                      'أو المتابعة عبر',
                      style: TextStyle(
                        color: numuwSecondaryTextColor(),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: numuwBorderColor())),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(
                        () => _error =
                            'تسجيل الدخول عبر Google سيُفعّل بعد إعداد OAuth.',
                      ),
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                      label: const Text('Google'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(
                        () => _error =
                            'تسجيل الدخول عبر Apple سيُفعّل بعد إعداد OAuth.',
                      ),
                      icon: const Icon(Icons.apple_rounded, size: 20),
                      label: const Text('Apple'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: widget.onSignUp,
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: numuwSecondaryTextColor(),
                        fontSize: 14,
                      ),
                      children: [
                        const TextSpan(text: 'ليس لديكِ حساب؟ '),
                        TextSpan(
                          text: 'إنشاء حساب',
                          style: TextStyle(
                            color: numuwAccentColor(),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthLogo extends StatelessWidget {
  const _AuthLogo();

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: numuwAccentColor().withValues(alpha: .14),
            shape: BoxShape.circle,
            border: Border.all(
              color: numuwAccentColor().withValues(alpha: .28),
            ),
            boxShadow: [
              BoxShadow(
                color: numuwAccentColor().withValues(alpha: .16),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.nightlight_round,
            color: numuwAccentColor(),
            size: 40,
          ),
        ),
      );
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
