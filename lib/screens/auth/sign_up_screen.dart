import 'package:flutter/material.dart';

import '../../core/errors/app_error.dart';
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
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
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
                title: 'إنشاء حساب ✨',
                subtitle: 'ابدئي رحلتكِ مع نُمُوّ',
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
                validator: _passwordValidator,
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
