import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../utils/date_utils.dart';
import '../models/timeline_entry.dart';
import '../widgets/timeline_item.dart';

class PastDaysScreen extends StatelessWidget {
  const PastDaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final uniqueDates = eventProvider.getUniqueDates();

    return Scaffold(
      appBar: AppBar(
        title: const Text('往日'),
      ),
      body: uniqueDates.isEmpty
          ? Center(
              child: Text(
                '还没有往日记录',
                style: theme.textTheme.bodyMedium,
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: _buildHistoryItems(context, uniqueDates, eventProvider),
            ),
    );
  }

  List<Widget> _buildHistoryItems(
    BuildContext context,
    List<DateTime> uniqueDates,
    EventProvider eventProvider,
  ) {
    final theme = Theme.of(context);
    final items = <Widget>[];
    String? currentMonthLabel;
    int? currentWeekNumber;

    for (final date in uniqueDates) {
      final monthLabel = DateFormat('yyyy年MM月').format(date);
      final weekNumber = DateHelper.getWeekNumber(date);
      final events = eventProvider.getEventsForDate(date);

      if (monthLabel != currentMonthLabel) {
        currentMonthLabel = monthLabel;
        currentWeekNumber = null;
        items.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              currentMonthLabel!,
              style: theme.textTheme.headlineSmall,
            ),
          ),
        );
      }

      if (weekNumber != currentWeekNumber) {
        currentWeekNumber = weekNumber;
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Chip(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              label: Text(
                '第${weekNumber}周 (${DateHelper.getWeekRangeLabel(date)})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      }

      items.add(
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              '${DateHelper.formatFullDate(date)} ${DateHelper.formatWeekday(date)}',
            ),
            subtitle: Text('${events.length} 条记录'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PastDetailsPage(date: date, events: events),
                ),
              );
            },
          ),
        ),
      );
    }

    return items;
  }
}

class PastDetailsPage extends StatelessWidget {
  final DateTime date;
  final List<TimelineEvent> events;

  const PastDetailsPage({
    super.key,
    required this.date,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedEvents = List<TimelineEvent>.from(events)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      appBar: AppBar(
        title: Text('${DateHelper.formatFullDate(date)} ${DateHelper.formatWeekday(date)}'),
      ),
      body: sortedEvents.isEmpty
          ? Center(
              child: Text(
                '当天暂无记录',
                style: theme.textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedEvents.length,
              itemBuilder: (context, index) {
                return TimelineItem(
                  event: sortedEvents[index],
                  isFirst: index == 0,
                  isLast: index == sortedEvents.length - 1,
                );
              },
            ),
    );
  }
}
