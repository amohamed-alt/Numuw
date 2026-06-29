import 'package:flutter/material.dart';

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
  late final pages = const [
    HomeScreen(),
    QuickLogScreen(),
    ChildScreen(),
    AssistantScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: selectedIndex,
        onChanged: (index) => setState(() => selectedIndex = index),
      ),
    );
  }
}
