const String tableUserSettings = 'user_settings';

const String tableCountdownTargets = 'countdown_targets';

const String createUserSettingsTable = '''
  CREATE TABLE $tableUserSettings (
    id TEXT PRIMARY KEY,
    birth_date INTEGER NOT NULL,
    retirement_date INTEGER,
    life_expectancy INTEGER DEFAULT 80,
    is_dark_mode INTEGER DEFAULT 0,
    language TEXT DEFAULT 'zh',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )
''';

const String createCountdownTargetsTable = '''
  CREATE TABLE $tableCountdownTargets (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    target_date INTEGER,
    type TEXT NOT NULL,
    is_recurring INTEGER DEFAULT 0,
    is_lunar_calendar INTEGER DEFAULT 0,
    is_completed INTEGER DEFAULT 0,
    completed_at INTEGER,
    relation TEXT,
    has_notification INTEGER DEFAULT 1,
    notification_days_before INTEGER DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )
''';