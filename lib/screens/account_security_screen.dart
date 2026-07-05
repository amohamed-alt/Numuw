import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors/app_error.dart';
import '../repositories/profile_repository.dart';
import '../services/auth_service.dart';
import '../widgets/app_widgets.dart';

class AccountProfileScreen extends StatefulWidget {
  const AccountProfileScreen({super.key, required this.initialName});
  final String initialName;

  @override
  State<AccountProfileScreen> createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends State<AccountProfileScreen> {
  late final TextEditingController controller = TextEditingController(text: widget.initialName);
  bool loading = false;
  String? message;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final value = controller.text.trim();
    if (value.isEmpty || loading) return;
    setState(() => loading = true);
    try {
      await ProfileRepository().upsertCurrentProfile(fullName: value);
      await Supabase.instance.client.auth.updateUser(UserAttributes(data: {'full_name': value}));
      if (mounted) setState(() => message = 'تم حفظ بياناتك.');
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => message = readableError(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _FormPage(
        title: 'تعديل ملف الأم',
        children: [
          NumuwTextField(controller: controller, label: 'الاسم'),
          if (message != null) ...[const SizedBox(height: 12), InfoBanner(message: message!)],
          const SizedBox(height: 18),
          PrimaryButton(label: 'حفظ التغييرات', loading: loading, onPressed: save),
        ],
      );
}

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key, required this.initialEmail});
  final String initialEmail;

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  late final TextEditingController email = TextEditingController(text: widget.initialEmail);
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmation = TextEditingController();
  bool loading = false;
  String? message;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> saveEmail() async {
    if (!email.text.contains('@') || loading) return;
    setState(() => loading = true);
    try {
      await AuthService().updateEmail(email.text);
      if (mounted) setState(() => message = 'أرسلنا رسالة تأكيد إلى البريد الجديد.');
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => message = readableError(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> savePassword() async {
    if (password.text.length < 6 || password.text != confirmation.text) {
      setState(() => message = 'تأكدي أن كلمتي المرور متطابقتان ومن 6 أحرف على الأقل.');
      return;
    }
    setState(() => loading = true);
    try {
      await AuthService().updatePassword(password.text);
      if (mounted) setState(() => message = 'تم تغيير كلمة المرور.');
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => message = readableError(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _FormPage(
        title: 'الأمان والدخول',
        children: [
          NumuwTextField(controller: email, label: 'البريد الإلكتروني', keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr),
          const SizedBox(height: 12),
          SecondaryButton(label: 'تغيير البريد', onPressed: saveEmail),
          const SizedBox(height: 24),
          NumuwPasswordField(controller: password, label: 'كلمة المرور الجديدة'),
          const SizedBox(height: 12),
          NumuwPasswordField(controller: confirmation, label: 'تأكيد كلمة المرور'),
          if (message != null) ...[const SizedBox(height: 12), InfoBanner(message: message!)],
          const SizedBox(height: 18),
          PrimaryButton(label: 'حفظ كلمة المرور', loading: loading, onPressed: savePassword),
        ],
      );
}

class AccountPolicyScreen extends StatelessWidget {
  const AccountPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: numuwPageColor(),
        appBar: AppBar(title: const Text('الخصوصية والأذونات')),
        body: AppPage(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const WarningBanner(message: 'نُمُوّ لا يقدّم تشخيصًا طبيًا ولا يصف علاجًا أو جرعات.'),
            const SizedBox(height: 16),
            Text('يطلب التطبيق أذونات الميكروفون والكاميرا والصور والإشعارات عند الحاجة فقط. بيانات الطفل لا يراها إلا أفراد الأسرة المصرح لهم.', style: TextStyle(color: numuwTextColor(), fontSize: 15, height: 1.9)),
          ]),
        ),
      );
}

class _FormPage extends StatelessWidget {
  const _FormPage({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: numuwPageColor(),
        appBar: AppBar(title: Text(title)),
        body: AppPage(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
      );
}
