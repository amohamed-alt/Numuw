import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import '../core/errors/app_error.dart';
import '../models/child_profile.dart';
import '../repositories/child_repository.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/main_shell.dart';
import '../screens/onboarding/child_onboarding_screen.dart';
import '../screens/welcome_screen.dart';
import '../services/auth_service.dart';
import '../state/app_preferences.dart';
import '../state/child_session.dart';
import '../widgets/app_widgets.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    this.startupError,
    this.authService,
    this.childRepository,
  });

  final String? startupError;
  final AuthService? authService;
  final ChildRepository? childRepository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<List<ChildProfile>>? _childrenFuture;
  String? _loadedUserId;
  String _authScreen = 'auto';
  String? _pendingEmail;

  AuthService get _auth => widget.authService ?? AuthService();
  ChildRepository get _children => widget.childRepository ?? ChildRepository();

  @override
  Widget build(BuildContext context) {
    if (widget.startupError != null) {
      return _StateScreen(
        title: 'إعدادات مطلوبة',
        message: widget.startupError!,
        icon: Icons.settings_outlined,
        onRetry: () => setState(() {}),
      );
    }
    return _authBuilder();
  }

  Widget _authBuilder() {
    return StreamBuilder<AuthState>(
      stream: _auth.authStateChanges,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        _auth.currentSession,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _StateScreen(
            title: 'تعذر التحقق من الحساب',
            message: readableError(snapshot.error!),
            icon: Icons.error_outline_rounded,
            onRetry: () => setState(() {}),
          );
        }
        final session = snapshot.data?.session ?? _auth.currentSession;
        if (session == null) return _signedOutFlow();
        if (session.user.emailConfirmedAt == null &&
            session.user.email != null) {
          return EmailConfirmationScreen(
            email: session.user.email!,
            onSignOut: _auth.signOut,
          );
        }
        _ensureChildren(session.user.id);
        return FutureBuilder<List<ChildProfile>>(
          future: _childrenFuture,
          builder: (context, childSnapshot) {
            if (childSnapshot.connectionState != ConnectionState.done) {
              return const _StateScreen(
                title: 'جارٍ التحميل',
                message: 'نجهّز بيانات طفلك...',
                icon: Icons.hourglass_empty_rounded,
                loading: true,
              );
            }
            if (childSnapshot.hasError) {
              return _StateScreen(
                title: 'تعذر تحميل الأطفال',
                message: readableError(childSnapshot.error!),
                icon: Icons.error_outline_rounded,
                onRetry: _reloadChildren,
              );
            }
            final loaded = childSnapshot.data ?? const <ChildProfile>[];
            ChildSession.instance.setChildren(loaded);
            if (loaded.isEmpty) {
              return ChildOnboardingScreen(onSaved: _reloadChildrenAsync);
            }
            return const MainShell();
          },
        );
      },
    );
  }

  Widget _signedOutFlow() {
    ChildSession.instance.clear();
    _loadedUserId = null;
    _childrenFuture = null;
    if (_authScreen == 'confirm' && _pendingEmail != null) {
      return EmailConfirmationScreen(
        email: _pendingEmail!,
        onSignOut: () async => setState(() => _authScreen = 'signin'),
      );
    }
    if (_authScreen == 'signup') {
      return SignUpScreen(
        onBack: () => setState(() => _authScreen = 'welcome'),
        onSignIn: () => setState(() => _authScreen = 'signin'),
        onConfirmationRequired: (email) => setState(() {
          _pendingEmail = email;
          _authScreen = 'confirm';
        }),
      );
    }
    if (_authScreen == 'signin' || AppPreferences.instance.hasSeenWelcome) {
      return SignInScreen(
        onBack: () => setState(() => _authScreen = 'welcome'),
        onSignUp: () => setState(() => _authScreen = 'signup'),
      );
    }
    return WelcomeScreen(
      onSignIn: () async {
        await AppPreferences.instance.setHasSeenWelcome(true);
        if (mounted) setState(() => _authScreen = 'signin');
      },
      onSignUp: () async {
        await AppPreferences.instance.setHasSeenWelcome(true);
        if (mounted) setState(() => _authScreen = 'signup');
      },
    );
  }

  void _ensureChildren(String userId) {
    if (_loadedUserId == userId && _childrenFuture != null) return;
    _loadedUserId = userId;
    _childrenFuture = _children.fetchCurrentUserChildren();
  }

  void _reloadChildren() =>
      setState(() => _childrenFuture = _children.fetchCurrentUserChildren());

  Future<void> _reloadChildrenAsync() async {
    final loaded = await _children.fetchCurrentUserChildren();
    ChildSession.instance.setChildren(loaded);
    if (!mounted) return;
    setState(() => _childrenFuture = Future.value(loaded));
  }
}

class EmailConfirmationScreen extends StatelessWidget {
  const EmailConfirmationScreen({
    super.key,
    required this.email,
    required this.onSignOut,
  });

  final String email;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppPage(
        padding: const EdgeInsetsDirectional.fromSTEB(32, 32, 32, 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const IconBadge(
              icon: '📧',
              background: AppColors.mintLight,
              size: 96,
            ),
            const SizedBox(height: 24),
            Text(
              'تأكيد البريد الإلكتروني',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: numuwTextColor(),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'أرسلنا رابط التأكيد إلى $email. تفضّلي بالتحقق منه ثم عودي للمتابعة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: numuwSecondaryTextColor(),
                fontSize: 15,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'العودة إلى تسجيل الدخول',
              onPressed: () => onSignOut(),
            ),
            const SizedBox(height: 16),
            Text(
              'لم يصلكِ البريد؟ يمكنك طلب رابط جديد من شاشة تسجيل الدخول.',
              textAlign: TextAlign.center,
              style: TextStyle(color: numuwSecondaryTextColor(), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateScreen extends StatelessWidget {
  const _StateScreen({
    required this.title,
    required this.message,
    required this.icon,
    this.loading = false,
    this.onRetry,
  });

  final String title;
  final String message;
  final IconData icon;
  final bool loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppPage(
        child: Column(
          children: [
            AppHeader(title: title, subtitle: message, showNotification: false),
            const SizedBox(height: 24),
            SoftCard(
              padding: const EdgeInsetsDirectional.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (loading)
                    const CircularProgressIndicator()
                  else
                    Icon(icon, color: numuwAccentColor(), size: 46),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: numuwTextColor(),
                      fontWeight: FontWeight.w800,
                      height: 1.6,
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    PrimaryButton(label: 'إعادة المحاولة', onPressed: onRetry),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
