import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../services/auth_service.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';
import 'account_security_screen.dart';
import 'family/family_screen.dart';
import 'settings_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool deletingAccount = false;

  @override
  void initState() {
    super.initState();
    ChildSession.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    ChildSession.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _pickChild() async {
    final children = ChildSession.instance.children;
    if (children.isEmpty) return;

    final selectedId = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      backgroundColor: numuwSurfaceColor(),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsetsDirectional.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: numuwBorderColor(),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(
                'اختاري الطفل',
                style: TextStyle(
                  color: numuwTextColor(),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ...children.map(
                (child) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: numuwAccentColor().withValues(alpha: .14),
                    child: const Text('👶'),
                  ),
                  title: Text(child.name),
                  trailing: child.id == ChildSession.instance.selectedChild?.id
                      ? Icon(Icons.check_circle_rounded, color: numuwAccentColor())
                      : const Icon(Icons.chevron_left_rounded),
                  onTap: () => Navigator.pop(context, child.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedId == null) return;
    final selected = children.firstWhere((child) => child.id == selectedId);
    ChildSession.instance.selectChild(selected);
  }

  Future<void> _deleteAccount() async {
    if (deletingAccount) return;
    final confirmation = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الحساب نهائيًا؟'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'سيتم حذف حسابك وبيانات الأطفال الخاصة بك نهائيًا. إذا كان طفل مشتركًا مع مقدم رعاية آخر، سنحافظ على سجل الطفل وننقل مسؤوليته لمقدم رعاية لديه صلاحية تعديل.',
              ),
              const SizedBox(height: 16),
              const Text('للتأكيد اكتبي كلمة «حذف»:'),
              const SizedBox(height: 8),
              TextField(
                controller: confirmation,
                autofocus: true,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(hintText: 'حذف'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.pop(
                dialogContext,
                confirmation.text.trim() == 'حذف',
              ),
              child: const Text('حذف نهائي'),
            ),
          ],
        ),
      ),
    );
    confirmation.dispose();

    if (confirmed != true || !mounted) return;
    setState(() => deletingAccount = true);
    try {
      await AuthService().deleteAccount();
      ChildSession.instance.clear();
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(readableError(error))),
      );
    } finally {
      if (mounted) setState(() => deletingAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final rawName = user?.userMetadata?['full_name']?.toString().trim();
    final name = rawName == null || rawName.isEmpty ? 'ماما' : rawName;
    final child = ChildSession.instance.selectedChild;
    final items = <_AccountItem>[
      _AccountItem(
        Icons.person_outline_rounded,
        'تعديل ملف الأم',
        AppColors.mint,
        () => _open(AccountProfileScreen(initialName: name)),
      ),
      _AccountItem(
        Icons.child_care_rounded,
        'الطفل المحدد',
        AppColors.blue,
        _pickChild,
        subtitle: child?.name ?? 'لم يتم اختيار طفل',
      ),
      _AccountItem(
        Icons.family_restroom_rounded,
        'مقدمو الرعاية',
        AppColors.success,
        () => _open(const FamilyScreen()),
      ),
      _AccountItem(
        Icons.key_outlined,
        'كلمة المرور والبريد',
        AppColors.mint,
        () => _open(AccountSecurityScreen(initialEmail: user?.email ?? '')),
      ),
      _AccountItem(
        Icons.palette_outlined,
        'المظهر وإمكانية الوصول',
        AppColors.blue,
        () => _open(const SettingsScreen()),
      ),
      _AccountItem(
        Icons.shield_outlined,
        'الخصوصية والأذونات',
        AppColors.success,
        () => _open(const AccountPolicyScreen()),
      ),
    ];

    return Scaffold(
      backgroundColor: numuwPageColor(),
      appBar: AppBar(title: const Text('الحساب والخصوصية')),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SoftCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: numuwAccentColor().withValues(alpha: .14),
                    child: Text(
                      name.substring(0, 1),
                      style: TextStyle(
                        color: numuwAccentColor(),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: numuwTextColor(),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? 'الحساب الحالي',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: numuwSecondaryTextColor(),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SoftCard(
              padding: const EdgeInsetsDirectional.all(6),
              child: Column(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  return Column(
                    children: [
                      ListTile(
                        onTap: item.onTap,
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: .13),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(item.icon, color: item.color, size: 21),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: numuwTextColor(),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                        trailing: Icon(
                          Icons.chevron_left_rounded,
                          color: numuwSecondaryTextColor(),
                        ),
                      ),
                      if (index != items.length - 1)
                        Divider(height: 1, color: numuwBorderColor()),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 18),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'منطقة حساسة',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'يمكنك حذف الحساب وبياناته نهائيًا من داخل نُمُوّ.',
                    style: TextStyle(color: numuwSecondaryTextColor()),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: deletingAccount ? null : _deleteAccount,
                    icon: deletingAccount
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline_rounded),
                    label: Text(deletingAccount ? 'جارٍ حذف الحساب…' : 'حذف الحساب نهائيًا'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountItem {
  const _AccountItem(
    this.icon,
    this.title,
    this.color,
    this.onTap, {
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final String? subtitle;
}
