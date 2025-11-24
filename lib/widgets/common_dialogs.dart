import 'package:flutter/material.dart';

class CommonDialogs {
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<String?> showInputDialog(
    BuildContext context, {
    required String title,
    String? hint,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final theme = Theme.of(context);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: theme.textTheme.headlineMedium,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 1,
          maxLength: 100,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 8),
            child: Row(
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
                  onPressed: () => Navigator.of(context).pop(controller.text),
                  child: const Text('确定'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return result;
  }

  static Future<String?> showNoteDialog(
    BuildContext context, {
    required String title,
    String? hint,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final theme = Theme.of(context);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: theme.textTheme.headlineMedium,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 6,
          minLines: 3,
          maxLength: 300,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 8),
            child: Row(
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
                  onPressed: () => Navigator.of(context).pop(controller.text),
                  child: const Text('确定'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return result;
  }
}
