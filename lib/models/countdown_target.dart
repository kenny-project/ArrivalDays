enum CountdownTargetType {
  lifeTimer,
  anniversary,
  birthday,
  wish,
}

class CountdownTarget {
  final String id;
  final String name;
  final DateTime? targetDate;
  final CountdownTargetType type;
  final bool isRecurring;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? relation;
  final bool hasNotification;
  final int notificationDaysBefore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CountdownTarget({
    required this.id,
    required this.name,
    this.targetDate,
    required this.type,
    this.isRecurring = false,
    this.isCompleted = false,
    this.completedAt,
    this.relation,
    this.hasNotification = true,
    this.notificationDaysBefore = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  CountdownTarget copyWith({
    String? id,
    String? name,
    DateTime? targetDate,
    CountdownTargetType? type,
    bool? isRecurring,
    bool? isCompleted,
    DateTime? completedAt,
    String? relation,
    bool? hasNotification,
    int? notificationDaysBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CountdownTarget(
      id: id ?? this.id,
      name: name ?? this.name,
      targetDate: targetDate ?? this.targetDate,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      relation: relation ?? this.relation,
      hasNotification: hasNotification ?? this.hasNotification,
      notificationDaysBefore: notificationDaysBefore ?? this.notificationDaysBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_date': targetDate?.millisecondsSinceEpoch,
      'type': type.name,
      'is_recurring': isRecurring ? 1 : 0,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'relation': relation,
      'has_notification': hasNotification ? 1 : 0,
      'notification_days_before': notificationDaysBefore,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CountdownTarget.fromMap(Map<String, dynamic> map) {
    return CountdownTarget(
      id: map['id'] as String,
      name: map['name'] as String,
      targetDate: map['target_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['target_date'] as int)
          : null,
      type: CountdownTargetType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CountdownTargetType.wish,
      ),
      isRecurring: (map['is_recurring'] as int?) == 1,
      isCompleted: (map['is_completed'] as int?) == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
      relation: map['relation'] as String?,
      hasNotification: (map['has_notification'] as int?) == 1,
      notificationDaysBefore: map['notification_days_before'] as int? ?? 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}