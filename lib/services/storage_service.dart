import 'package:hive_flutter/hive_flutter.dart';
import '../models/timeline_entry.dart';

class StorageService {
  static const String _eventsBoxName = 'events';
  static const String _settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<Box> getEventsBox() async {
    if (!Hive.isBoxOpen(_eventsBoxName)) {
      return await Hive.openBox(_eventsBoxName);
    }
    return Hive.box(_eventsBoxName);
  }

  static Future<Box> getSettingsBox() async {
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      return await Hive.openBox(_settingsBoxName);
    }
    return Hive.box(_settingsBoxName);
  }

  static Future<void> saveEvent(TimelineEvent event) async {
    final box = await getEventsBox();
    await box.put(event.id, event.toJson());
  }

  static Future<void> deleteEvent(String id) async {
    final box = await getEventsBox();
    await box.delete(id);
  }

  static Future<List<TimelineEvent>> getAllEvents() async {
    final box = await getEventsBox();
    final events = <TimelineEvent>[];
    for (var key in box.keys) {
      final json = box.get(key) as Map;
      events.add(TimelineEvent.fromJson(Map<String, dynamic>.from(json)));
    }
    events.sort((a, b) => b.startTime.compareTo(a.startTime));
    return events;
  }

  static Future<List<TimelineEvent>> getEventsByDate(DateTime date) async {
    final allEvents = await getAllEvents();
    return allEvents.where((event) {
      return event.startTime.year == date.year &&
          event.startTime.month == date.month &&
          event.startTime.day == date.day;
    }).toList();
  }

  static Future<bool> getThemeMode() async {
    final box = await getSettingsBox();
    return box.get('isDarkMode', defaultValue: false) as bool;
  }

  static Future<void> setThemeMode(bool isDarkMode) async {
    final box = await getSettingsBox();
    await box.put('isDarkMode', isDarkMode);
  }
}
