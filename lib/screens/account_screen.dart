import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';
import 'account_security_screen.dart';
import 'family/family_screen.dart';
import 'settings_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final rawName = user?.userMetadata?['full_name']?.toString().trim();
    final name = rawName == null || rawName.isEmpty ? 'ماما' : rawName;
    final child = ChildSession.instance.selectedChild;
    final items = <_AccountItem>[
      _AccountItem(Icons.person_outline_rounded, 'تعديل ملف الأم', AppColors.mint, () => _open(context, AccountProfileScreen(initialName: name))),
      _AccountItem(Icons.child_care_rounded, 'الطفل المحدد', AppColors.blue, () {}, subtitle: child?.name ?? 'لم يتم اختيار طفل'),
      _AccountItem(Icons.family_restroom_rounded, 'مقدمو الرعاية', AppColors.success, () => _open(context, const FamilyScreen())),
      _AccountItem(Icons.key_outlined, 'كلمة المرور والبريد', AppColors.mint, () => _open(context, AccountSecurityScreen(initialEmail: user?.email ?? ''))),
      _AccountItem(Icons.palette_outlined, 'المظهر وإمكانية الوصول', AppColors.blue, () => _open(context, const SettingsScreen())),
      _AccountItem(Icons.shield_outlined, 'الخصوصية والأذونات', AppColors.success, () => _open(context, const AccountPolicyScreen())),
    ];

    return Scaffold(
      backgroundColor: numuwPageColor(),
      appBar: AppBar(title: const Text('الحساب والخصوصية')),
      body: AppPage(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SoftCard(child: Row(children: [
            CircleAvatar(radius: 28, backgroundColor: numuwAccentColor().withValues(alpha: .14), child: Text(name.substring(0, 1), style: TextStyle(color: numuwAccentColor(), fontSize: 22, fontWeight: FontWeight.w900))),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: TextStyle(color: numuwTextColor(), fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(user?.email ?? 'الحساب الحالي', overflow: TextOverflow.ellipsis, style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 12.5)),
            ])),
          ])),
          const SizedBox(height: 18),
          SoftCard(padding: const EdgeInsetsDirectional.all(6), child: Column(children: List.generate(items.length, (index) {
            final item = items[index];
            return Column(children: [
              ListTile(
                onTap: item.onTap,
                leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: item.color.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)), child: Icon(item.icon, color: item.color, size: 21)),
                title: Text(item.title, style: TextStyle(color: numuwTextColor(), fontWeight: FontWeight.w800)),
                subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                trailing: Icon(Icons.chevron_left_rounded, color: numuwSecondaryTextColor()),
              ),
              if (index != items.length - 1) Divider(height: 1, color: numuwBorderColor()),
            ]);
          }))),
        ]),
      ),
    );
  }
}

class _AccountItem {
  const _AccountItem(this.icon, this.title, this.color, this.onTap, {this.subtitle});
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final String? subtitle;
}
