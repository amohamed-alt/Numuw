import 'package:flutter/material.dart';

import '../../core/errors/app_error.dart';
import '../../repositories/profile_repository.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    this.onBack,
    this.onSignIn,
    this.onConfirmationRequired,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSignIn;
  final ValueChanged<String>? onConfirmationRequired;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _accepted = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_accepted) {
      setState(() => _error = 'وافقي على شروط الاستخدام وسياسة الخصوصية.');
      return;
    }
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await AuthService().signUp(
        email: _email.text,
        password: _password.text,
      );
      if (response.session != null) {
        try {
          await ProfileRepository().upsertCurrentProfile(fullName: _name.text);
        } catch (error, stackTrace) {
          logError(error, stackTrace);
        }
      }
      if (!mounted) return;
      if (response.session == null) {
        widget.onConfirmationRequired?.call(_email.text.trim());
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
              const SizedBox(height: 20),
              Center(
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
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'أهلًا بكِ في نُمُوّ',
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
                  'أنشئي حسابك لنبدأ رحلتنا معًا',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              NumuwTextField(
                controller: _name,
                label: 'اسمكِ',
                hint: 'اسمكِ الكريم',
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'اكتبي اسمكِ.' : null,
              ),
              const SizedBox(height: 15),
              NumuwTextField(
                controller: _email,
                label: 'البريد الإلكتروني',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                validator: _emailValidator,
              ),
              const SizedBox(height: 15),
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
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _accepted,
                  onChanged: (value) =>
                      setState(() => _accepted = value ?? false),
                  title: Text(
                    'أوافق على شروط الاستخدام وسياسة الخصوصية',
                    style: TextStyle(
                      color: numuwSecondaryTextColor(),
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                ErrorMessageCard(message: _error!),
                const SizedBox(height: 12),
              ],
              PrimaryButton(
                label: 'إنشاء الحساب',
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
                            'إنشاء الحساب عبر Google سيُفعّل بعد إعداد OAuth.',
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
                            'إنشاء الحساب عبر Apple سيُفعّل بعد إعداد OAuth.',
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
                  onPressed: widget.onSignIn,
                  child: const Text('لديكِ حساب؟ سجّلي الدخول'),
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
  final text = (value ?? '').trim();
  if (text.isEmpty) return 'اكتبي البريد الإلكتروني.';
  if (!text.contains('@')) return 'البريد الإلكتروني غير صحيح.';
  return null;
}

String? _passwordValidator(String? value) {
  final text = value ?? '';
  if (text.length < 6) return 'كلمة المرور لا تقل عن 6 أحرف.';
  return null;
}
