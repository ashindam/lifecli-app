import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lifecli_app/core/constants/app_colors.dart';

// ─── Inbox badge provider (simple ValueNotifier for now) ──────────────────

final ValueNotifier<int> inboxBadgeCount = ValueNotifier<int>(0);

// ─── Bottom nav destinations ───────────────────────────────────────────────

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}

const List<_NavDestination> _destinations = [
  _NavDestination(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    route: '/home',
  ),
  _NavDestination(
    label: 'Academic',
    icon: Icons.school_outlined,
    selectedIcon: Icons.school_rounded,
    route: '/academic',
  ),
  _NavDestination(
    label: 'Finance',
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet_rounded,
    route: '/finance',
  ),
  _NavDestination(
    label: 'Focus',
    icon: Icons.timer_outlined,
    selectedIcon: Icons.timer_rounded,
    route: '/focus',
  ),
  _NavDestination(
    label: 'More',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view_rounded,
    route: '/more',
  ),
];

// ─── Main Shell ────────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _fabExpanded = false;
  late AnimationController _fabController;
  late Animation<double> _fabRotation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fabRotation = Tween<double>(begin: 0, end: 0.375).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    context.go(_destinations[index].route);
    if (_fabExpanded) _closeFab();
  }

  int _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].route)) return i;
    }
    return 0;
  }

  void _toggleFab() {
    setState(() => _fabExpanded = !_fabExpanded);
    if (_fabExpanded) {
      _fabController.forward();
    } else {
      _fabController.reverse();
    }
  }

  void _closeFab() {
    setState(() => _fabExpanded = false);
    _fabController.reverse();
  }

  void _handleQuickAction(_QuickAction action, BuildContext context) {
    _closeFab();
    switch (action) {
      case _QuickAction.addTask:
        context.pushNamed('task-add');
        break;
      case _QuickAction.addExpense:
        context.go('/finance/expenses');
        break;
      case _QuickAction.pomodoro:
        context.go('/focus/pomodoro');
        break;
      case _QuickAction.quickCapture:
        context.pushNamed('quick-capture');
        break;
      case _QuickAction.markAttendance:
        context.go('/academic/attendance');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToIndex(context);
    if (currentIndex != _selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedIndex = currentIndex);
      });
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey<String>(_destinations[_selectedIndex].route),
          child: widget.child,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _buildQuickCaptureFab(context),
      bottomNavigationBar: _buildNavBar(context),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 350),
        destinations: _destinations.map((d) {
          return NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: d.label,
            tooltip: d.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickCaptureFab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 72),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Speed dial items
          if (_fabExpanded) ...[
            _SpeedDialItem(
              icon: Icons.add_task_rounded,
              label: 'Add Task',
              color: AppColors.primary,
              onTap: () => _handleQuickAction(_QuickAction.addTask, context),
            ),
            const SizedBox(height: 8),
            _SpeedDialItem(
              icon: Icons.payments_outlined,
              label: 'Add Expense',
              color: AppColors.success,
              onTap: () => _handleQuickAction(_QuickAction.addExpense, context),
            ),
            const SizedBox(height: 8),
            _SpeedDialItem(
              icon: Icons.timer_rounded,
              label: 'Start Pomodoro',
              color: AppColors.error,
              onTap: () => _handleQuickAction(_QuickAction.pomodoro, context),
            ),
            const SizedBox(height: 8),
            _SpeedDialItem(
              icon: Icons.bolt_rounded,
              label: 'Quick Capture',
              color: AppColors.accent,
              onTap: () =>
                  _handleQuickAction(_QuickAction.quickCapture, context),
            ),
            const SizedBox(height: 8),
            _SpeedDialItem(
              icon: Icons.how_to_reg_rounded,
              label: 'Mark Attendance',
              color: AppColors.info,
              onTap: () =>
                  _handleQuickAction(_QuickAction.markAttendance, context),
            ),
            const SizedBox(height: 12),
          ],
          // Main FAB
          ValueListenableBuilder<int>(
            valueListenable: inboxBadgeCount,
            builder: (context, count, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  FloatingActionButton(
                    heroTag: 'quick_capture_fab',
                    onPressed: _toggleFab,
                    elevation: _fabExpanded ? 6 : 4,
                    child: AnimatedBuilder(
                      animation: _fabRotation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _fabRotation.value * 2 * 3.14159,
                          child: Icon(
                            _fabExpanded
                                ? Icons.close_rounded
                                : Icons.add_rounded,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ),
                  if (count > 0 && !_fabExpanded)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Speed dial item ───────────────────────────────────────────────────────

class _SpeedDialItem extends StatelessWidget {
  const _SpeedDialItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label chip
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Mini FAB
        FloatingActionButton.small(
          heroTag: 'speed_dial_$label',
          onPressed: onTap,
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }
}

// ─── Quick actions enum ────────────────────────────────────────────────────

enum _QuickAction {
  addTask,
  addExpense,
  pomodoro,
  quickCapture,
  markAttendance,
}
