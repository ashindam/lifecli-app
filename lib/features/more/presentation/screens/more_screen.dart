import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      _ModuleGroup('📚 Academic Tools', [
        _ModuleItem('📋 Tasks', Icons.checklist_outlined, '/tasks', AppColors.primary),
        _ModuleItem('📝 Notes', Icons.note_outlined, '/notes', AppColors.info),
        _ModuleItem('🎓 Grade Simulator', Icons.grade_outlined, '/grades', AppColors.primaryLight),
        _ModuleItem('📖 Study Logger', Icons.timer_outlined, '/study-log', AppColors.success),
        _ModuleItem('📚 Reading List', Icons.menu_book_outlined, '/reading-list', AppColors.accent),
      ]),
      _ModuleGroup('💸 Finance', [
        _ModuleItem('🏦 Finance (Loans)', Icons.account_balance_outlined, '/finance', AppColors.success),
        _ModuleItem('🧾 Bill Splitter', Icons.receipt_long_outlined, '/bill-splitter', AppColors.warning),
        _ModuleItem('💼 Tuition Manager', Icons.people_outlined, '/tuition', AppColors.primaryLight),
        _ModuleItem('📱 Subscriptions', Icons.subscriptions_outlined, '/subscriptions', AppColors.error),
      ]),
      _ModuleGroup('🏠 Lifestyle', [
        _ModuleItem('💊 Health Log', Icons.favorite_outline, '/health-log', AppColors.error),
        _ModuleItem('🌤 Weather', Icons.wb_sunny_outlined, '/weather', AppColors.info),
        _ModuleItem('🚌 Bus Schedule', Icons.directions_bus_outlined, '/bus-schedule', AppColors.primary),
        _ModuleItem('📋 Notice Board', Icons.campaign_outlined, '/notice-board', AppColors.warning),
        _ModuleItem('💡 Load Shedding', Icons.bolt_outlined, '/load-shedding', AppColors.accentDark),
      ]),
      _ModuleGroup('⚙️ Utilities', [
        _ModuleItem('🧮 Calculator', Icons.calculate_outlined, '/calculator', AppColors.primary),
        _ModuleItem('📥 Quick Capture', Icons.inbox_outlined, '/quick-capture', AppColors.success),
        _ModuleItem('📊 Weekly Review', Icons.bar_chart_outlined, '/weekly-review', AppColors.primaryLight),
        _ModuleItem('👤 Profile', Icons.person_outlined, '/profile', Colors.grey),
        _ModuleItem('⚙️ Settings', Icons.settings_outlined, '/settings', Colors.grey),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('More', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        itemCount: modules.length,
        itemBuilder: (ctx, i) {
          final group = modules[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(group.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey)),
              const SizedBox(height: 10),
              ...group.items.map((item) => _ModuleTile(item: item)),
            ],
          );
        },
      ),
    );
  }
}

class _ModuleGroup {
  final String title;
  final List<_ModuleItem> items;
  const _ModuleGroup(this.title, this.items);
}

class _ModuleItem {
  final String label;
  final IconData icon;
  final String route;
  final Color color;
  const _ModuleItem(this.label, this.icon, this.route, this.color);
}

class _ModuleTile extends StatelessWidget {
  final _ModuleItem item;
  const _ModuleTile({required this.item});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 42, height: 42,
      decoration: BoxDecoration(color: item.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Icon(item.icon, color: item.color, size: 22),
    ),
    title: Text(item.label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
    trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
    onTap: () => context.push(item.route),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  );
}
