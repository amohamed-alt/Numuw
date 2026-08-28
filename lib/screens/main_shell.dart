import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../services/network_status_service.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/app_widgets.dart';
import '../widgets/quick_log_sheet.dart';
import 'assistant_screen.dart';
import 'child_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'quick_log_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedIndex = 0;
  String? childInitialSection;
  final List<Widget?> _pages = List<Widget?>.filled(5, null);

  @override
  void initState() {
    super.initState();
    _ensurePage(0);
  }

  void _selectTab(int index) {
    if (index == 1) {
      _openQuickLog();
      return;
    }
    setState(() {
      selectedIndex = index;
      _ensurePage(index);
    });
  }

  Future<void> _openQuickLog() async {
    final mode = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: numuwSurfaceColor(),
      barrierColor: const Color(0x9904080D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NumuwRadius.largeCard),
        ),
      ),
      builder: (_) => const QuickLogSheet(),
    );
    if (!mounted || mode == null) return;
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: NumuwMotion.screen,
        reverseTransitionDuration: NumuwMotion.fast,
        pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
          backgroundColor: numuwPageColor(),
          body: QuickLogScreen(initialMode: mode),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(.06, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openChildSection(String section) {
    setState(() {
      childInitialSection = section;
      selectedIndex = 2;
      _pages[2] = ChildScreen(initialSection: section);
    });
  }

  void _ensurePage(int index) {
    _pages[index] ??= switch (index) {
      0 => const HomeScreen(),
      2 => ChildScreen(initialSection: childInitialSection),
      3 => const AssistantScreen(),
      4 => const MoreScreen(),
      _ => const HomeScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return MainShellScope(
      selectedIndex: selectedIndex,
      selectTab: _selectTab,
      openChildSection: _openChildSection,
      child: Scaffold(
        backgroundColor: numuwPageColor(),
        body: Column(
          children: [
            AnimatedBuilder(
              animation: NetworkStatusService.instance,
              builder: (context, _) {
                final offline = NetworkStatusService.instance.initialized &&
                    !NetworkStatusService.instance.hasConnectivity;
                return AnimatedContainer(
                  duration: NumuwMotion.fast,
                  height: offline ? 34 : 0,
                  width: double.infinity,
                  color: numuwNightMode()
                      ? AppColors.nightWarningSoft
                      : AppColors.peachLight,
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    duration: NumuwMotion.fast,
                    opacity: offline ? 1 : 0,
                    child: Text(
                      'أنتِ بدون اتصال — التسجيلات المدعومة تُحفظ مؤقتًا',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: numuwNightMode()
                            ? AppColors.nightWarning
                            : AppColors.peach,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    if (_pages[i] != null)
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: selectedIndex != i,
                          child: TickerMode(
                            enabled: selectedIndex == i,
                            child: AnimatedOpacity(
                              opacity: selectedIndex == i ? 1 : 0,
                              duration: NumuwMotion.screen,
                              curve: Curves.easeOutCubic,
                              child: AnimatedSlide(
                                offset: selectedIndex == i
                                    ? Offset.zero
                                    : const Offset(0, .018),
                                duration: NumuwMotion.screen,
                                curve: Curves.easeOutCubic,
                                child: _pages[i]!,
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavigation(
          selectedIndex: selectedIndex,
          onChanged: _selectTab,
        ),
      ),
    );
  }
}

class MainShellScope extends InheritedWidget {
  const MainShellScope({
    super.key,
    required this.selectedIndex,
    required this.selectTab,
    required this.openChildSection,
    required super.child,
  });

  final int selectedIndex;
  final ValueChanged<int> selectTab;
  final ValueChanged<String> openChildSection;

  static MainShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainShellScope>();

  @override
  bool updateShouldNotify(MainShellScope oldWidget) =>
      selectedIndex != oldWidget.selectedIndex;
}
