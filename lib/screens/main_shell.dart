import 'dart:async';

import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../state/child_session.dart';
import '../widgets/app_bottom_navigation.dart';
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
  StreamSubscription<String>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _ensurePage(0);
    _notificationSubscription = NotificationService.instance.responsePayloads
        .listen(_handleNotificationPayload);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final payload = NotificationService.instance.takePendingLaunchPayload();
      if (payload != null) _handleNotificationPayload(payload);
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _selectTab(int index) {
    setState(() {
      selectedIndex = index;
      _ensurePage(index);
    });
  }

  void _openChildSection(String section) {
    setState(() {
      childInitialSection = section;
      selectedIndex = 2;
      _pages[2] = ChildScreen(initialSection: section);
    });
  }

  void _handleNotificationPayload(String payload) {
    if (!mounted) return;
    final destination = parseNotificationPayload(payload);
    _selectChildIfAvailable(destination.childId);

    switch (destination.type) {
      case NotificationDestinationType.quickLog:
        _selectTab(1);
      case NotificationDestinationType.vaccinations:
        _openChildSection('vaccinations');
      case NotificationDestinationType.home:
        _selectTab(0);
    }
  }

  void _selectChildIfAvailable(String? childId) {
    if (childId == null || childId.isEmpty) return;
    for (final child in ChildSession.instance.children) {
      if (child.id == childId) {
        if (ChildSession.instance.selectedChild?.id != childId) {
          ChildSession.instance.selectChild(child);
        }
        return;
      }
    }
  }

  void _ensurePage(int index) {
    _pages[index] ??= switch (index) {
      0 => const HomeScreen(),
      1 => const QuickLogScreen(),
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
        body: Stack(
          children: [
            for (var i = 0; i < _pages.length; i++)
              if (_pages[i] != null)
                Offstage(
                  offstage: selectedIndex != i,
                  child: TickerMode(
                    enabled: selectedIndex == i,
                    child: _pages[i]!,
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
