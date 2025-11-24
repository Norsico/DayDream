import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/timeline_entry.dart';
import '../providers/event_provider.dart';
import 'common_dialogs.dart';

class EditEventDialog extends StatefulWidget {
  final TimelineEvent event;

  const EditEventDialog({super.key, required this.event});

  @override
  State<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late DateTime _startTime;
  DateTime? _endTime;
  final DateFormat _dateTimeFormat = DateFormat('yyyy年MM月dd日 HH:mm');

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _noteController = TextEditingController(text: widget.event.note);
    _startTime = widget.event.startTime;
    _endTime = widget.event.endTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) {
      return null;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickStartTime() async {
    final result = await _pickDateTime(_startTime);
    if (result != null) {
      setState(() {
        _startTime = result;
        if (_endTime != null && _endTime!.isBefore(_startTime)) {
          _endTime = _startTime;
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final base = _endTime ?? _startTime;
    final result = await _pickDateTime(base);
    if (result != null) {
      setState(() {
        _endTime = result;
      });
    }
  }

  void _clearEndTime() {
    setState(() {
      _endTime = null;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();

    if (title.isEmpty) {
      _showError('事件名称不能为空');
      return;
    }
    if (_endTime != null && _endTime!.isBefore(_startTime)) {
      _showError('结束时间不能早于开始时间');
      return;
    }

    final updatedEvent = widget.event.copyWith(
      title: title,
      startTime: _startTime,
      endTime: _endTime,
      note: note.isEmpty ? null : note,
    );
    Navigator.of(context).pop(updatedEvent);
  }

  void _handleDelete() {
    Navigator.of(context).pop('delete');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        '编辑事件',
        style: theme.textTheme.headlineMedium,
      ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('事件名称', style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 1,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: '输入事件名称',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('开始时间', style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            _DateTimeTile(
              label: _dateTimeFormat.format(_startTime),
              onTap: _pickStartTime,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('结束时间', style: theme.textTheme.bodySmall),
                if (_endTime != null)
                  TextButton.icon(
                    onPressed: _clearEndTime,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('清除'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _DateTimeTile(
              label: _endTime != null
                  ? _dateTimeFormat.format(_endTime!)
                  : '进行中 (点击设置结束时间)',
              highlight: _endTime == null,
              onTap: _pickEndTime,
            ),
            const SizedBox(height: 20),
            Text('备注', style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              minLines: 2,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: '添加备注（可选）',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              TextButton.icon(
                onPressed: _handleDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('删除'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.textTheme.bodySmall?.color,
                      side: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _handleSave,
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  const _DateTimeTile({
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: highlight
                ? theme.colorScheme.primary.withOpacity(0.6)
                : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 20,
              color: highlight
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: highlight
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.edit_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}

Future<void> showEventEditorDialog({
  required BuildContext context,
  required EventProvider eventProvider,
  required TimelineEvent event,
}) async {
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
