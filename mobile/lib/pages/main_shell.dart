import 'package:flutter/material.dart';

import '../api_client.dart';
import '../widgets/app_bottom_navigation.dart';
import 'ai_page.dart';
import 'charts_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.api, required this.onLogout});
  final ApiClient api;
  final Future<void> Function() onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _selectTab(int value) => setState(() => _index = value);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(api: widget.api, onSelectTab: _selectTab),
      ChartsPage(api: widget.api),
      AiPage(api: widget.api),
      ProfilePage(
        api: widget.api,
        onLogout: widget.onLogout,
        onSelectTab: _selectTab,
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar:
          AppBottomNavigation(index: _index, onChanged: _selectTab),
    );
  }
}
