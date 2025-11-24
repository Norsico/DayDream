import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/timeline_entry.dart';
import '../providers/event_provider.dart';
import 'past_days_screen.dart';

class HistoryCalendarScreen extends StatefulWidget {
  const HistoryCalendarScreen({super.key});

  @override
  State<HistoryCalendarScreen> createState() => _HistoryCalendarScreenState();
}

class _HistoryCalendarScreenState extends State<HistoryCalendarScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventProvider = Provider.of<EventProvider>(context);

    final monthEvents = _getMonthEvents(eventProvider.events, _currentMonth);
    final maxEvents = _getMaxEvents(monthEvents);

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史统计图'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  DateFormat('yyyy年MM月').format(_currentMonth),
                  style: theme.textTheme.headlineMedium,
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildWeekdayHeader(theme),
                  const SizedBox(height: 8),
                  _buildCalendar(theme, monthEvents, maxEvents, eventProvider),
                  const SizedBox(height: 24),
                  _buildLegend(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(ThemeData theme) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: theme.textTheme.bodySmall,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendar(
    ThemeData theme,
    Map<int, List<TimelineEvent>> monthEvents,
    int maxEvents,
    EventProvider eventProvider,
  ) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    final firstWeekday = _currentMonth.weekday;

    final weeks = <Widget>[];
    var dayCounter = 1;

    while (dayCounter <= daysInMonth) {
      final week = <Widget>[];
      for (var i = 1; i <= 7; i++) {
        if (weeks.isEmpty && i < firstWeekday) {
          week.add(const Expanded(child: SizedBox()));
        } else if (dayCounter <= daysInMonth) {
          final day = dayCounter;
          final date = DateTime(_currentMonth.year, _currentMonth.month, day);
          final events = monthEvents[day] ?? [];
          week.add(
            Expanded(
              child: _buildDayCell(
                theme,
                day,
                date,
                events,
                maxEvents,
                eventProvider,
              ),
            ),
          );
          dayCounter++;
        } else {
          week.add(const Expanded(child: SizedBox()));
        }
      }
      weeks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: week),
        ),
      );
    }

    return Column(children: weeks);
  }

  Widget _buildDayCell(
    ThemeData theme,
    int day,
    DateTime date,
    List<TimelineEvent> events,
    int maxEvents,
    EventProvider eventProvider,
  ) {
    final eventCount = events.length;
    final intensity = maxEvents > 0 ? eventCount / maxEvents : 0.0;
    final color = _getColorIntensity(theme, intensity);
    final isToday = _isToday(date);

    return GestureDetector(
      onTap: eventCount > 0
          ? () => _navigateToDay(context, date, events)
          : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: isToday
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '$day',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: intensity > 0.5
                        ? Colors.white
                        : theme.textTheme.bodySmall?.color,
                    fontSize: 11,
                  ),
                ),
              ),
              if (eventCount > 0)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: intensity > 0.5
                          ? Colors.white.withOpacity(0.9)
                          : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Center(
                      child: Text(
                        '$eventCount',
                        style: TextStyle(
                          color: intensity > 0.5
                              ? theme.colorScheme.primary
                              : Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorIntensity(ThemeData theme, double intensity) {
    final baseColor = theme.colorScheme.primary;
    if (intensity == 0) {
      return theme.brightness == Brightness.dark
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceVariant.withOpacity(0.3);
    }
    if (intensity < 0.25) {
      return baseColor.withOpacity(0.2);
    } else if (intensity < 0.5) {
      return baseColor.withOpacity(0.4);
    } else if (intensity < 0.75) {
      return baseColor.withOpacity(0.7);
    } else {
      return baseColor;
    }
  }

  Widget _buildLegend(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('活跃度', style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('少', style: theme.textTheme.bodySmall),
            const SizedBox(width: 8),
            for (var i = 0; i < 5; i++) ...[
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _getColorIntensity(theme, i * 0.25),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.3),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            Text('多', style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Map<int, List<TimelineEvent>> _getMonthEvents(
    List<TimelineEvent> allEvents,
    DateTime month,
  ) {
    final monthEvents = <int, List<TimelineEvent>>{};
    for (final event in allEvents) {
      if (event.startTime.year == month.year &&
          event.startTime.month == month.month) {
        final day = event.startTime.day;
        monthEvents.putIfAbsent(day, () => []).add(event);
      }
    }
    return monthEvents;
  }

  int _getMaxEvents(Map<int, List<TimelineEvent>> monthEvents) {
    if (monthEvents.isEmpty) {
      return 0;
    }
    return monthEvents.values.map((e) => e.length).reduce(
          (a, b) => a > b ? a : b,
        );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _navigateToDay(
    BuildContext context,
    DateTime date,
    List<TimelineEvent> events,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PastDetailsPage(date: date, events: events),
      ),
    );
  }
}
