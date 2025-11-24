import 'package:flutter/material.dart';
import '../models/timeline_entry.dart';
import '../services/storage_service.dart';

class EventProvider extends ChangeNotifier {
  List<TimelineEvent> _events = [];
  TimelineEvent? _currentOngoingEvent;

  List<TimelineEvent> get events => _events;
  TimelineEvent? get currentOngoingEvent => _currentOngoingEvent;

  EventProvider() {
    loadEvents();
  }

  Future<void> loadEvents() async {
    _events = await StorageService.getAllEvents();
    _currentOngoingEvent = null;
    for (final event in _events) {
      if (event.isOngoing) {
        _currentOngoingEvent = event;
        break;
      }
    }
    notifyListeners();
  }

  Future<void> startEvent(String title) async {
    if (title.trim().isEmpty) return;
    if (_currentOngoingEvent != null) return;

    final event = TimelineEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      startTime: DateTime.now(),
    );
    await StorageService.saveEvent(event);
    _currentOngoingEvent = event;
    await loadEvents();
  }

  Future<void> endEvent(String? note) async {
    if (_currentOngoingEvent == null) return;

    final updatedEvent = _currentOngoingEvent!.copyWith(
      endTime: DateTime.now(),
      note: note != null && note.trim().isNotEmpty ? note.trim() : null,
    );

    await StorageService.saveEvent(updatedEvent);
    _currentOngoingEvent = null;
    await loadEvents();
  }

  Future<void> updateEvent(TimelineEvent event) async {
    await StorageService.saveEvent(event);
    if (event.isOngoing) {
      _currentOngoingEvent = event;
    } else if (_currentOngoingEvent?.id == event.id) {
      _currentOngoingEvent = null;
    }
    await loadEvents();
  }

  Future<void> deleteEvent(String id) async {
    await StorageService.deleteEvent(id);
    await loadEvents();
  }

  List<TimelineEvent> getEventsForDate(DateTime date) {
    final eventsForDate = _events.where((event) {
      return event.startTime.year == date.year &&
          event.startTime.month == date.month &&
          event.startTime.day == date.day;
    }).toList();
    eventsForDate.sort((a, b) => a.startTime.compareTo(b.startTime));
    return eventsForDate;
  }

  List<DateTime> getUniqueDates() {
    final dates = <DateTime>{};
    for (var event in _events) {
      dates.add(DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      ));
    }
    final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));
    return sortedDates;
  }
}
