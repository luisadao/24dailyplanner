import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'controllers/calendar_controller.dart';
import 'models/time_event.dart';
import 'repositories/calendar_repository.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/agenda_card.dart';
import 'widgets/event_bottom_sheet.dart';
import 'widgets/radial_clock.dart';
import 'widgets/week_strip.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final repository = CalendarRepository();
  await repository.initialize();
  runApp(RadialPlannerApp(repository: repository));
}

class RadialPlannerApp extends StatelessWidget {
  final CalendarRepository repository;

  const RadialPlannerApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarController(repository)..selectDate(DateTime.now()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryText,
            surface: AppColors.surface,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.primaryText,
            elevation: 0,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primaryText,
            unselectedItemColor: AppColors.secondaryText,
          ),
        ),
        themeMode: ThemeMode.dark,
        home: const PlannerScreen(),
      ),
    );
  }
}

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home, label: 'Home'),
    _NavItem(icon: Icons.calendar_month, label: 'Calendar'),
    _NavItem(icon: Icons.bar_chart, label: 'Statistics'),
    _NavItem(icon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalendarController>();

    return Scaffold(
      appBar: _selectedIndex == 0 ? null : AppBar(title: const Text('Planner')),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _HomeBody(),
          CalendarScreen(),
          StatisticsScreen(),
          SettingsScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await showModalBottomSheet<TimeEvent>(
                  context: context,
                  builder: (_) => EventBottomSheet(
                    date: controller.selectedDate,
                    event: TimeEvent(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: '',
                      date: controller.selectedDate,
                      startMinute: 480,
                      durationMinutes: 60,
                      colorValue: AppColors.presets.first.toARGB32(),
                    ),
                  ),
                );
                if (result != null) controller.saveEvent(result);
              },
              backgroundColor: AppColors.elevatedSurface,
              foregroundColor: AppColors.primaryText,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: _navItems
            .map((item) => NavigationDestination(icon: Icon(item.icon), label: item.label))
            .toList(),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalendarController>();
    final now = DateTime.now();
    final isToday = controller.selectedDate.year == now.year &&
        controller.selectedDate.month == now.month &&
        controller.selectedDate.day == now.day;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Column(
          children: [
            WeekStrip(
              selectedDate: controller.selectedDate,
              onDateSelected: controller.selectDate,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isToday ? 'Your Day' : _formatDate(controller.selectedDate),
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isToday)
                    FilledButton.tonal(
                      onPressed: () => controller.selectDate(DateTime.now()),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.elevatedSurface,
                        foregroundColor: AppColors.primaryText,
                      ),
                      child: const Text('Today'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: RadialClock(
                date: controller.selectedDate,
                events: controller.events,
                currentTime: TimeOfDay.fromDateTime(now),
                showCurrentTime: isToday,
                centerTitle: isToday
                    ? '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'
                    : '${controller.selectedDate.day.toString().padLeft(2, '0')}/${controller.selectedDate.month.toString().padLeft(2, '0')}',
                centerSubtitle: _freeTimeLabel(controller.events),
                onEventSaved: controller.saveEvent,
                onDeleteInstance: controller.deleteEventInstance,
                onDeleteSeries: controller.deleteEventSeries,
                onEventResized: controller.moveEventEdge,
              ),
            ),
            AgendaCard(
              events: controller.events,
              onEventTap: (event) => _openEditSheet(context, controller, event),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _freeTimeLabel(List<TimeEvent> events) {
    final scheduled = events.fold<int>(0, (sum, e) => sum + e.durationMinutes);
    final free = 1440 - scheduled;
    final h = free ~/ 60;
    final m = free % 60;
    if (h == 0) return '${m}m free';
    if (m == 0) return '${h}h free';
    return '${h}h ${m}m free';
  }

  Future<void> _openEditSheet(BuildContext context, CalendarController controller, TimeEvent event) async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      builder: (_) => EventBottomSheet(date: controller.selectedDate, event: event),
    );
    if (result is TimeEvent) {
      controller.saveEvent(result);
    } else if (result == 'delete_instance') {
      controller.deleteEventInstance(event.id, controller.selectedDate);
    } else if (result == 'delete_all') {
      controller.deleteEventSeries(event.id);
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}