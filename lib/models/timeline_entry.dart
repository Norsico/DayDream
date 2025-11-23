class TimelineEvent {
  final String id;
  final String title;
  final DateTime startTime;
  DateTime? endTime;
  String? note;

  TimelineEvent({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.note,
  });

  bool get isOngoing => endTime == null;

  Duration? get duration =>
      endTime == null ? null : endTime!.difference(startTime);

  DateTime get dateOnly =>
      DateTime(startTime.year, startTime.month, startTime.day);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'note': note,
    };
  }

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      note: json['note'] as String?,
    );
  }

  TimelineEvent copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? note,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      note: note ?? this.note,
    );
  }
}

