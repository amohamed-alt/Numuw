import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
import '../../design/numuw_motion_widgets.dart';
import '../../design/numuw_organic_icons.dart';
import '../../models/child_guardian.dart';
import '../../repositories/family_sharing_repository.dart';
import '../../state/child_session.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/numuw_components.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _repo = FamilySharingRepository();
  final _email = TextEditingController();
  final _code = TextEditingController();
  Future<_FamilyData>? _future;
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  void _load() {
    final child = ChildSession.instance.selectedChild;
    if (child == null) {
      _future = null;
      return;
    }
    _future = _FamilyData.load(_repo, child.id);
  }

  Future<void> _createInvite() async {
    final child = ChildSession.instance.selectedChild;
    if (child == null || _busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final invite = await _repo.createInvite(
        childId: child.id,
        invitedEmail: _email.text,
      );
      if (!mounted) return;
      _email.clear();
      setState(() {
        _message = 'كود الدعوة: ${invite.inviteCode}';
        _load();
      });
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _message = readableError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _acceptInvite() async {
    final inviteCode = _code.text.trim();
    if (_busy || inviteCode.isEmpty) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _repo.acceptInvite(inviteCode);
      await ChildSession.instance.refresh();
      if (!mounted) return;
      _code.clear();
      setState(() {
        _message = 'تم قبول الدعوة وتحديث الأطفال المتاحين.';
        _load();
      });
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (mounted) setState(() => _message = readableError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildSession.instance.selectedChild;
    return Scaffold(
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumuwEntrance(
              child: NumuwAppBar(
                title: 'مشاركة العائلة',
                subtitle: 'ادعي ولي أمر أو اقبلي دعوة لمتابعة الطفل بأمان.',
                leading: AppIconButton(
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.pop(context),
                  badge: false,
                  size: 42,
                  radius: 13,
                  iconSize: 20,
                ),
                trailing: const NumuwOrganicIcon(
                  NumuwOrganicIconName.family,
                  size: 42,
                  semanticLabel: 'العائلة',
                ),
              ),
            ),
            const SizedBox(height: 14),
            const NumuwEntrance(
              child: NumuwPlantProgress(
                progress: .42,
                label: 'البيت متصل',
              ),
            ),
            const SizedBox(height: 18),
            if (child == null)
              const NumuwEmptyState(
                message: 'اختاري طفلًا أولًا لإدارة مشاركة العائلة.',
              )
            else
              FutureBuilder<_FamilyData>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingSkeleton(height: 240);
                  }
                  if (snapshot.hasError) {
                    return ErrorMessageCard(
                      message: readableError(snapshot.error!),
                    );
                  }
                  final data = snapshot.data ?? const _FamilyData([], []);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InviteCard(
                        email: _email,
                        busy: _busy,
                        onCreate: _createInvite,
                      ),
                      const SizedBox(height: 14),
                      _AcceptInviteCard(
                        code: _code,
                        busy: _busy,
                        onAccept: _acceptInvite,
                      ),
                      const SizedBox(height: 14),
                      _GuardiansCard(guardians: data.guardians),
                      if (data.invites.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _PendingInvitesCard(invites: data.invites),
                      ],
                    ],
                  );
                },
              ),
            if (_message != null) ...[
              const SizedBox(height: 14),
              NumuwEntrance(
                child: InfoBanner(
                  message: _message!,
                  icon: Icons.info_outline_rounded,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FamilyData {
  const _FamilyData(this.guardians, this.invites);

  final List<ChildGuardian> guardians;
  final List<FamilyInvite> invites;

  static Future<_FamilyData> load(
    FamilySharingRepository repo,
    String childId,
  ) async {
    final results = await Future.wait([
      repo.fetchGuardians(childId),
      repo.fetchPendingInvites(childId),
    ]);
    return _FamilyData(
      results[0] as List<ChildGuardian>,
      results[1] as List<FamilyInvite>,
    );
  }
}

class _OrganicSectionTitle extends StatelessWidget {
  const _OrganicSectionTitle({required this.title, required this.icon});

  final String title;
  final NumuwOrganicIconName icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      NumuwOrganicIcon(icon, size: 34, semanticLabel: title),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: numuwTextColor(),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ],
  );
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.email,
    required this.busy,
    required this.onCreate,
  });

  final TextEditingController email;
  final bool busy;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => NumuwEntrance(
    child: NumuwCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OrganicSectionTitle(
            title: 'دعوة ولي أمر',
            icon: NumuwOrganicIconName.family,
          ),
          const SizedBox(height: 10),
          AppTextField(
            controller: email,
            label: 'البريد الإلكتروني اختياري',
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 10),
          NumuwPrimaryButton(
            label: busy ? 'جاري إنشاء الدعوة...' : 'إنشاء كود دعوة',
            onPressed: busy ? null : onCreate,
          ),
        ],
      ),
    ),
  );
}

class _AcceptInviteCard extends StatelessWidget {
  const _AcceptInviteCard({
    required this.code,
    required this.busy,
    required this.onAccept,
  });

  final TextEditingController code;
  final bool busy;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) => NumuwEntrance(
    child: NumuwCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OrganicSectionTitle(
            title: 'قبول دعوة',
            icon: NumuwOrganicIconName.done,
          ),
          const SizedBox(height: 10),
          AppTextField(
            controller: code,
            label: 'كود الدعوة',
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 10),
          NumuwSecondaryButton(
            label: busy ? 'جاري القبول...' : 'قبول الدعوة',
            onPressed: busy ? null : onAccept,
          ),
        ],
      ),
    ),
  );
}

class _GuardiansCard extends StatelessWidget {
  const _GuardiansCard({required this.guardians});

  final List<ChildGuardian> guardians;

  @override
  Widget build(BuildContext context) => NumuwEntrance(
    child: NumuwCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OrganicSectionTitle(
            title: 'أولياء الأمور',
            icon: NumuwOrganicIconName.family,
          ),
          const SizedBox(height: 10),
          if (guardians.isEmpty)
            Text(
              'لا توجد بيانات عائلة بعد.',
              style: TextStyle(color: numuwSecondaryTextColor()),
            )
          else
            ...guardians.map(
              (guardian) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const NumuwOrganicIcon(
                  NumuwOrganicIconName.account,
                  size: 42,
                ),
                title: Text(guardian.label, textAlign: TextAlign.start),
                subtitle: Text(
                  guardian.role == 'owner' ? 'مالك ملف الطفل' : 'ولي أمر',
                  textAlign: TextAlign.start,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _PendingInvitesCard extends StatelessWidget {
  const _PendingInvitesCard({required this.invites});

  final List<FamilyInvite> invites;

  @override
  Widget build(BuildContext context) => NumuwEntrance(
    child: NumuwCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OrganicSectionTitle(
            title: 'دعوات معلقة',
            icon: NumuwOrganicIconName.notifications,
          ),
          const SizedBox(height: 10),
          ...invites.map(
            (invite) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const NumuwOrganicIcon(
                NumuwOrganicIconName.share,
                size: 38,
              ),
              title: Text(invite.inviteCode, textDirection: TextDirection.ltr),
              subtitle: Text(invite.invitedEmail ?? 'بدون بريد محدد'),
            ),
          ),
        ],
      ),
    ),
  );
}
