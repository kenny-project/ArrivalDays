class UserSettings {
  final String id;
  final DateTime birthDate;
  final DateTime? retirementDate;
  final int lifeExpectancy;
  final bool isDarkMode;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettings({
    required this.id,
    required this.birthDate,
    this.retirementDate,
    this.lifeExpectancy = 80,
    this.isDarkMode = false,
    this.language = 'zh',
    required this.createdAt,
    required this.updatedAt,
  });

  UserSettings copyWith({
    String? id,
    DateTime? birthDate,
    DateTime? retirementDate,
    int? lifeExpectancy,
    bool? isDarkMode,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      birthDate: birthDate ?? this.birthDate,
      retirementDate: retirementDate ?? this.retirementDate,
      lifeExpectancy: lifeExpectancy ?? this.lifeExpectancy,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'birth_date': birthDate.millisecondsSinceEpoch,
      'retirement_date': retirementDate?.millisecondsSinceEpoch,
      'life_expectancy': lifeExpectancy,
      'is_dark_mode': isDarkMode ? 1 : 0,
      'language': language,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'] as String,
      birthDate: DateTime.fromMillisecondsSinceEpoch(map['birth_date'] as int),
      retirementDate: map['retirement_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['retirement_date'] as int)
          : null,
      lifeExpectancy: map['life_expectancy'] as int? ?? 80,
      isDarkMode: (map['is_dark_mode'] as int?) == 1,
      language: map['language'] as String? ?? 'zh',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}