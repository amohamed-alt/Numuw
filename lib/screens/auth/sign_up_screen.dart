import 'package:flutter/material.dart';

import '../../auth/password_policy.dart';
import '../../core/errors/app_error.dart';
import '../../design/numuw_organic_icons.dart';
import '../../repositories/profile_repository.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/numuw_components.dart';

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
  final _passwordConfirmation = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(_refreshPasswordStrength);
  }

  @override
  void dispose() {
    _password.removeListener(_refreshPasswordStrength);
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    super.dispose();
  }

  void _refreshPasswordStrength() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = AuthService();
      final response = await auth.signUp(
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
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 64, 24, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumuwAppBar(
                title: 'إنشاء حساب',
                subtitle: 'ابدئي رحلتكِ مع نُمُوّ بأمان وخصوصية',
                leading: AppIconButton(
                  icon: Icons.arrow_forward_rounded,
                  onPressed: widget.onBack,
                  badge: false,
                  size: 42,
                  radius: 13,
                  iconSize: 20,
                  borderWidth: 1.5,
                ),
                trailing: const NumuwOrganicIcon(
                  NumuwOrganicIconName.privacy,
                  size: 44,
                  semanticLabel: 'الخصوصية والأمان',
                ),
              ),
              const SizedBox(height: 14),
              const NumuwPlantProgress(progress: .18, label: 'البداية الجديدة'),
              const SizedBox(height: 22),
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
                hint: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                validator: _emailValidator,
              ),
              const SizedBox(height: 15),
              NumuwPasswordField(
                controller: _password,
                label: 'كلمة المرور',
                validator: PasswordPolicy.validate,
              ),
              const SizedBox(height: 10),
              _PasswordStrengthHint(password: _password.text),
              const SizedBox(height: 15),
              NumuwPasswordField(
                controller: _passwordConfirmation,
                label: 'تأكيد كلمة المرور',
                validator: (value) => PasswordPolicy.validateConfirmation(
                  confirmation: value,
                  password: _password.text,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                ErrorMessageCard(message: _error!),
              ],
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'إنشاء الحساب',
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      'لديكِ حساب؟ ',
                      style: TextStyle(
                        color: numuwSecondaryTextColor(),
                        fontSize: 14,
                      ),
                    ),
                    TextActionButton(
                      label: 'تسجيل الدخول',
                      onTap: widget.onSignIn ?? () {},
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

class _PasswordStrengthHint extends StatelessWidget {
  const _PasswordStrengthHint({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final strength = PasswordPolicy.strength(password);
    final (label, color, progress) = switch (strength) {
      PasswordStrength.weak => ('ضعيفة', const Color(0xFFB96E67), .32),
      PasswordStrength.fair => ('جيدة', const Color(0xFFC18D5C), .66),
      PasswordStrength.strong => ('قوية', const Color(0xFF68846B), 1.0),
    };

    return Semantics(
      label: 'قوة كلمة المرور: $label',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '10 أحرف على الأقل + حرف إنجليزي + رقم + رمز',
                  style: TextStyle(
                    color: numuwSecondaryTextColor(),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: password.isEmpty ? 0 : progress,
              minHeight: 5,
              backgroundColor: numuwBorderColor(),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
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
