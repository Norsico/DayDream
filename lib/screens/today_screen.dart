import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/common_dialogs.dart';
import '../widgets/timeline_item.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final today = DateTime.now();
    final todayEvents = eventProvider.getEventsForDate(today);
    final hasOngoingEvent = eventProvider.currentOngoingEvent != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('今日'),
            Text(
              '${DateHelper.formatFullDate(today)} ${DateHelper.formatWeekday(today)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: todayEvents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 64,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '今天还没有记录',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击右下角按钮开始记录',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todayEvents.length,
              itemBuilder: (context, index) {
                return TimelineItem(
                  event: todayEvents[index],
                  isFirst: index == 0,
                  isLast: index == todayEvents.length - 1,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleFabPress(context, eventProvider, hasOngoingEvent),
        child: Icon(hasOngoingEvent ? Icons.stop : Icons.add),
      ),
    );
  }

  Future<void> _handleFabPress(
    BuildContext context,
    EventProvider eventProvider,
    bool hasOngoingEvent,
  ) async {
    if (hasOngoingEvent) {
      final note = await CommonDialogs.showNoteDialog(
        context,
        title: '结束事件',
        hint: '写下一些感悟或备注...',
      );
      await eventProvider.endEvent(note);
    } else {
      final title = await CommonDialogs.showInputDialog(
        context,
        title: '新增事件',
        hint: '你正在或打算做什么？',
      );
      if (title == null) {
        return;
      }
      if (title.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('内容不能为空')), 
          );
        }
        return;
      }
      await eventProvider.startEvent(title);
    }
  }
}
