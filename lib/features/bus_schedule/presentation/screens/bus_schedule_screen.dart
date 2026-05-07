import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/bus_route_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/widgets/empty_state.dart';

final _busProvider = StateNotifierProvider<_BusNotifier, List<BusRouteModel>>(
  (ref) => _BusNotifier(),
);

class _BusNotifier extends StateNotifier<List<BusRouteModel>> {
  _BusNotifier() : super([]) { _load(); }
  void _load() {
    state = HiveService.busRoutes.values.whereType<BusRouteModel>().toList()
      ..sort((a, b) {
        final am = a.minutesUntilNext ?? 9999;
        final bm = b.minutesUntilNext ?? 9999;
        return am.compareTo(bm);
      });
  }
  Future<void> add(BusRouteModel r) async { await HiveService.busRoutes.put(r.id, r); _load(); }
  Future<void> delete(String id) async { await HiveService.busRoutes.delete(id); _load(); }
  Future<void> toggleFavorite(String id) async {
    final r = state.firstWhere((r) => r.id == id);
    await HiveService.busRoutes.put(id, r.copyWith(isFavorite: !r.isFavorite)); _load();
  }
}

String _formatTime(String hhmm) {
  final parts = hhmm.split(':');
  final h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  final period = h >= 12 ? 'PM' : 'AM';
  final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
  return '${displayH}:${m.toString().padLeft(2, '0')} $period';
}

class BusScheduleScreen extends ConsumerWidget {
  const BusScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(_busProvider);
    final favorites = routes.where((r) => r.isFavorite).toList();
    final others = routes.where((r) => !r.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Schedule', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(_busProvider))],
      ),
      body: routes.isEmpty
          ? const EmptyState(emoji: '🚌', title: 'No routes added', subtitle: 'Add your university bus routes to track departures')
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                _LiveCountdownCard(routes: routes),
                const SizedBox(height: 16),
                if (favorites.isNotEmpty) ...[
                  Text('⭐ Favorites', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  ...favorites.map((r) => _RouteCard(route: r, ref: ref)),
                  const SizedBox(height: 12),
                ],
                if (others.isNotEmpty) ...[
                  Text('🚌 All Routes', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  ...others.map((r) => _RouteCard(route: r, ref: ref)),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add), label: const Text('Add Route'),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final stopsCtrl = TextEditingController();
    final List<String> departures = [];

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Add Bus Route', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Route Name (e.g. Campus Express)')),
              const SizedBox(height: 12),
              TextField(controller: stopsCtrl, decoration: const InputDecoration(labelText: 'Stops (e.g. Gate 1 → City Center → Terminal)', hintText: 'Optional')),
              const SizedBox(height: 16),
              Row(children: [
                Text('Departure Times', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                    if (t != null) {
                      final hhmm = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                      setSt(() => departures..add(hhmm)..sort());
                    }
                  },
                  icon: const Icon(Icons.add, size: 16), label: const Text('Add Time'),
                ),
              ]),
              if (departures.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('No departure times added yet', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                )
              else
                Wrap(
                  spacing: 6, runSpacing: 4,
                  children: departures.map((t) => Chip(
                    label: Text(_formatTime(t)),
                    onDeleted: () => setSt(() => departures.remove(t)),
                    deleteIconColor: Colors.grey,
                  )).toList(),
                ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty || departures.isEmpty) return;
                  final stops = stopsCtrl.text.trim().isNotEmpty
                      ? stopsCtrl.text.trim().split('→').map((s) => s.trim()).toList()
                      : <String>[];
                  ref.read(_busProvider.notifier).add(BusRouteModel(
                    routeName: nameCtrl.text.trim(),
                    stops: stops,
                    departureTimes: List.from(departures),
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Save Route'),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

class _LiveCountdownCard extends StatelessWidget {
  final List<BusRouteModel> routes;
  const _LiveCountdownCard({required this.routes});

  @override
  Widget build(BuildContext context) {
    BusRouteModel? soonest;
    int minMinutes = 9999;
    for (final r in routes) {
      final m = r.minutesUntilNext ?? 9999;
      if (m < minMinutes) { minMinutes = m; soonest = r; }
    }
    if (soonest == null) return const SizedBox.shrink();

    final isVeryClose = minMinutes <= 5;
    final isSoon = minMinutes <= 15;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVeryClose
              ? [AppColors.error, const Color(0xFFDC2626)]
              : isSoon
                  ? [AppColors.warning, const Color(0xFFD97706)]
                  : [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        const Text('🚌', style: TextStyle(fontSize: 40)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Next Bus', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
          Text(soonest.routeName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          if (soonest.stops.isNotEmpty)
            Text(soonest.stops.join(' → '), style: GoogleFonts.inter(fontSize: 11, color: Colors.white60), overflow: TextOverflow.ellipsis),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            minMinutes == 0 ? 'NOW' : '${minMinutes}m',
            style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          if (soonest.nextDeparture != null)
            Text(_formatTime(soonest.nextDeparture!), style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
        ]),
      ]),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final BusRouteModel route;
  final WidgetRef ref;
  const _RouteCard({required this.route, required this.ref});

  @override
  Widget build(BuildContext context) {
    final minutes = route.minutesUntilNext;
    final isUrgent = minutes != null && minutes <= 5;
    final isSoon = minutes != null && minutes <= 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isUrgent ? AppColors.error.withOpacity(0.3) : const Color(0xFFE2E8F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(route.routeName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700))),
          IconButton(
            icon: Icon(route.isFavorite ? Icons.star : Icons.star_outline,
              color: route.isFavorite ? AppColors.warning : Colors.grey, size: 20),
            onPressed: () => ref.read(_busProvider.notifier).toggleFavorite(route.id),
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          PopupMenuButton(
            iconSize: 18,
            itemBuilder: (_) => [const PopupMenuItem(value: 'delete', child: Text('Remove'))],
            onSelected: (v) { if (v == 'delete') ref.read(_busProvider.notifier).delete(route.id); },
          ),
        ]),
        if (route.stops.isNotEmpty)
          Text(route.stops.join(' → '), style: GoogleFonts.inter(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        Row(children: [
          if (minutes != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isUrgent ? AppColors.error : isSoon ? AppColors.warningContainer : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                minutes == 0 ? '🚌 Departing now!' : '🕐 ${minutes}m away',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
                  color: isUrgent ? Colors.white : isSoon ? AppColors.warning : AppColors.primary),
              ),
            ),
          const Spacer(),
          if (route.nextDeparture != null)
            Text(_formatTime(route.nextDeparture!), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        if (route.departureTimes.length > 1) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: route.departureTimes.map((t) => Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
              child: Text(_formatTime(t), style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[700])),
            )).toList()),
          ),
        ],
      ]),
    );
  }
}
