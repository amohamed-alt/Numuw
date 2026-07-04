import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/errors/app_error.dart';
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
    if (child == null) return;
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
      _email.clear();
      setState(() {
        _message = 'ÙƒÙˆØ¯ Ø§Ù„Ø¯Ø¹ÙˆØ©: ${invite.inviteCode}';
        _load();
      });
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      setState(() => _message = readableError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _acceptInvite() async {
    if (_busy || _code.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _repo.acceptInvite(_code.text.trim());
      _code.clear();
      await ChildSession.instance.refresh();
      setState(() {
        _message =
            'ØªÙ… Ù‚Ø¨ÙˆÙ„ Ø§Ù„Ø¯Ø¹ÙˆØ© ÙˆØªØ­Ø¯ÙŠØ« Ø§Ù„Ø£Ø·ÙØ§Ù„ Ø§Ù„Ù…ØªØ§Ø­ÙŠÙ†.';
        _load();
      });
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      setState(() => _message = readableError(error));
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
            NumuwAppBar(
              title: 'Ù…Ø´Ø§Ø±ÙƒØ© Ø§Ù„Ø¹ÙŠÙ„Ø©',
              subtitle:
                  'Ø§Ø¯Ø¹ÙŠ ÙˆÙ„ÙŠ Ø£Ù…Ø± Ø£Ùˆ Ø§Ù‚Ø¨Ù„ÙŠ Ø¯Ø¹ÙˆØ© Ù„Ù…ØªØ§Ø¨Ø¹Ø© Ø§Ù„Ø·ÙÙ„ Ø¨Ø£Ù…Ø§Ù†.',
              leading: AppIconButton(
                icon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.pop(context),
                badge: false,
                size: 42,
                radius: 13,
                iconSize: 20,
              ),
            ),
            const SizedBox(height: 14),
            const NumuwPlantProgress(
              progress: .42,
              label: 'Ø§Ù„Ø¨ÙŠØª Ù…ØªØµÙ„',
            ),
            const SizedBox(height: 18),
            if (child == null)
              const NumuwEmptyState(
                message:
                    'Ø§Ø®ØªØ§Ø±ÙŠ Ø·ÙÙ„Ù‹Ø§ Ø£ÙˆÙ„Ù‹Ø§ Ù„Ø¥Ø¯Ø§Ø±Ø© Ø§Ù„Ø¹ÙŠÙ„Ø©.',
              )
            else
              FutureBuilder<_FamilyData>(
                future: _future,
                builder: (context, snapshot) {
                  final data = snapshot.data;
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
                      _GuardiansCard(guardians: data?.guardians ?? const []),
                      if ((data?.invites ?? const []).isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _PendingInvitesCard(invites: data!.invites),
                      ],
                    ],
                  );
                },
              ),
            if (_message != null) ...[
              const SizedBox(height: 14),
              InfoBanner(message: _message!, icon: Icons.info_outline_rounded),
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
  Widget build(BuildContext context) => NumuwCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NumuwSectionHeader(
          title: 'Ø¯Ø¹ÙˆØ© ÙˆÙ„ÙŠ Ø£Ù…Ø±',
          icon: Icons.group_add_outlined,
        ),
        const SizedBox(height: 10),
        AppTextField(
          controller: email,
          label: 'Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ Ø§Ø®ØªÙŠØ§Ø±ÙŠ',
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 10),
        NumuwPrimaryButton(
          label: busy
              ? 'Ø¬Ø§Ø±ÙŠ Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø¯Ø¹ÙˆØ©...'
              : 'Ø¥Ù†Ø´Ø§Ø¡ ÙƒÙˆØ¯ Ø¯Ø¹ÙˆØ©',
          onPressed: busy ? null : onCreate,
        ),
      ],
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
  Widget build(BuildContext context) => NumuwCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NumuwSectionHeader(
          title: 'Ù‚Ø¨ÙˆÙ„ Ø¯Ø¹ÙˆØ©',
          icon: Icons.mark_email_read_outlined,
        ),
        const SizedBox(height: 10),
        AppTextField(
          controller: code,
          label: 'ÙƒÙˆØ¯ Ø§Ù„Ø¯Ø¹ÙˆØ©',
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 10),
        NumuwSecondaryButton(
          label: busy ? 'Ø¬Ø§Ø±ÙŠ Ø§Ù„Ù‚Ø¨ÙˆÙ„...' : 'Ù‚Ø¨ÙˆÙ„ Ø§Ù„Ø¯Ø¹ÙˆØ©',
          onPressed: busy ? null : onAccept,
        ),
      ],
    ),
  );
}

class _GuardiansCard extends StatelessWidget {
  const _GuardiansCard({required this.guardians});

  final List<ChildGuardian> guardians;

  @override
  Widget build(BuildContext context) => NumuwCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NumuwSectionHeader(
          title: 'Ø£ÙˆÙ„ÙŠØ§Ø¡ Ø§Ù„Ø£Ù…ÙˆØ±',
          icon: Icons.family_restroom_rounded,
        ),
        const SizedBox(height: 10),
        if (guardians.isEmpty)
          Text(
            'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¨ÙŠØ§Ù†Ø§Øª Ø¹ÙŠÙ„Ø© Ø¨Ø¹Ø¯.',
            style: TextStyle(color: numuwSecondaryTextColor()),
          )
        else
          ...guardians.map(
            (guardian) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.mintLight,
                child: Icon(Icons.person_outline, color: AppColors.mint),
              ),
              title: Text(guardian.label, textAlign: TextAlign.start),
              subtitle: Text(
                guardian.role == 'owner'
                    ? 'Ù…Ø§Ù„Ùƒ Ø§Ù„Ø·ÙÙ„'
                    : 'ÙˆÙ„ÙŠ Ø£Ù…Ø±',
                textAlign: TextAlign.start,
              ),
            ),
          ),
      ],
    ),
  );
}

class _PendingInvitesCard extends StatelessWidget {
  const _PendingInvitesCard({required this.invites});

  final List<FamilyInvite> invites;

  @override
  Widget build(BuildContext context) => NumuwCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NumuwSectionHeader(
          title: 'Ø¯Ø¹ÙˆØ§Øª Ù…Ø¹Ù„Ù‚Ø©',
          icon: Icons.pending_actions_rounded,
        ),
        const SizedBox(height: 10),
        ...invites.map(
          (invite) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(invite.inviteCode, textDirection: TextDirection.ltr),
            subtitle: Text(invite.invitedEmail ?? 'Ø¨Ø¯ÙˆÙ† Ø¨Ø±ÙŠØ¯ Ù…Ø­Ø¯Ø¯'),
          ),
        ),
      ],
    ),
  );
}
