import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timeline_entry.dart';
import '../providers/event_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/common_dialogs.dart';
import '../widgets/timeline_item.dart';
import '../widgets/edit_event_dialog.dart';

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
                  onLongPress: () => _handleEditEvent(
                    context,
                    eventProvider,
                    todayEvents[index],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleFabPress(context, eventProvider, hasOngoingEvent),
        child: Icon(hasOngoingEvent ? Icons.stop : Icons.add),
      ),
    );
  }

  Future<void> _handleEditEvent(
    BuildContext context,
    EventProvider eventProvider,
    TimelineEvent event,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<dynamic>(
      context: context,
      builder: (_) => EditEventDialog(event: event),
    );
    if (result == null) {
      return;
    }

    if (result == 'delete') {
      final confirmed = await CommonDialogs.showConfirmDialog(
        context,
        title: '删除事件',
        message: '确定要删除当前事件吗？',
      );
      if (!confirmed) {
        return;
      }
      await eventProvider.deleteEvent(event.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('事件已删除')),
      );
      return;
    }

    if (result is TimelineEvent) {
      await eventProvider.updateEvent(result);
      messenger.showSnackBar(
        const SnackBar(content: Text('事件已更新')),
      );
    }
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
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          const SnackBar(content: Text('内容不能为空')),
        );
        return;
      }
      await eventProvider.startEvent(title);
    }
  }
}
