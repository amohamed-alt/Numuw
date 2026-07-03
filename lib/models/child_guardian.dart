class ChildGuardian {
  const ChildGuardian({
    required this.childId,
    required this.userId,
    required this.role,
    this.displayName,
    this.email,
    this.createdAt,
  });

  final String childId;
  final String userId;
  final String role;
  final String? displayName;
  final String? email;
  final DateTime? createdAt;

  factory ChildGuardian.fromMap(Map<String, dynamic> map) => ChildGuardian(
    childId: map['child_id'] as String,
    userId: map['user_id'] as String,
    role: map['role'] as String? ?? 'guardian',
    displayName: (map['display_name'] ?? map['full_name']) as String?,
    email: map['email'] as String?,
    createdAt: DateTime.tryParse('${map['created_at'] ?? ''}'),
  );

  String get label {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final value = email?.trim();
    if (value != null && value.isNotEmpty) return value;
    return role == 'owner' ? 'مالك الطفل' : 'ولي أمر';
  }
}

class FamilyInvite {
  const FamilyInvite({
    required this.id,
    required this.childId,
    required this.inviteCode,
    this.invitedEmail,
    required this.role,
    required this.status,
    this.expiresAt,
    this.createdAt,
  });

  final String id;
  final String childId;
  final String inviteCode;
  final String? invitedEmail;
  final String role;
  final String status;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  factory FamilyInvite.fromMap(Map<String, dynamic> map) => FamilyInvite(
    id: map['id'] as String,
    childId: map['child_id'] as String,
    inviteCode: map['invite_code'] as String,
    invitedEmail: map['invited_email'] as String?,
    role: map['role'] as String? ?? 'guardian',
    status: map['status'] as String? ?? 'pending',
    expiresAt: DateTime.tryParse('${map['expires_at'] ?? ''}'),
    createdAt: DateTime.tryParse('${map['created_at'] ?? ''}'),
  );
}
