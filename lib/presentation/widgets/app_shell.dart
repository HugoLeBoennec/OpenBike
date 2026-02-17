import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell layout that wraps tab routes with a bottom navigation bar (mobile)
/// or a [NavigationRail] sidebar (desktop ≥ 800px).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabConfig('/', 'Home', Icons.home),
    _TabConfig('/workouts', 'Workouts', Icons.fitness_center),
    _TabConfig('/history', 'History', Icons.history),
    _TabConfig('/settings', 'Settings', Icons.settings),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    context.go(_tabs[index].path);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final index = _currentIndex(context);
        if (constraints.maxWidth >= 800) {
          return _buildWithRail(context, index);
        }
        return _buildWithBottomNav(context, index);
      },
    );
  }

  Widget _buildWithBottomNav(BuildContext context, int index) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => _onTabTapped(context, i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF111111),
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.white38,
        items: [
          for (final tab in _tabs)
            BottomNavigationBarItem(
              icon: Icon(tab.icon),
              label: tab.label,
            ),
        ],
      ),
    );
  }

  Widget _buildWithRail(BuildContext context, int index) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: (i) => _onTabTapped(context, i),
            backgroundColor: const Color(0xFF111111),
            indicatorColor: Colors.deepOrange.withValues(alpha: 0.2),
            destinations: [
              for (final tab in _tabs)
                NavigationRailDestination(
                  icon: Icon(tab.icon, color: Colors.white38),
                  selectedIcon: Icon(tab.icon, color: Colors.deepOrange),
                  label: Text(tab.label),
                ),
            ],
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            color: Color(0xFF222222),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _TabConfig {
  const _TabConfig(this.path, this.label, this.icon);
  final String path;
  final String label;
  final IconData icon;
}
