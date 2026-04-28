import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Arrival Days',
      'clock': 'Clock',
      'anniversary': 'Anniversary',
      'wish': 'Wishes',
      'settings': 'Settings',
      'lifeTimer': 'Life Timer',
      'distanceFromLeaving': 'Distance from ideal leaving',
      'elapsed': 'Elapsed',
      'years': 'y',
      'months': 'm',
      'days': 'd',
      'hours': 'h',
      'minutes': 'min',
      'seconds': 'sec',
      'addAnniversary': 'Add Anniversary',
      'addWish': 'Add Wish',
      'editAnniversary': 'Edit Anniversary',
      'editWish': 'Edit Wish',
      'name': 'Name',
      'date': 'Date',
      'type': 'Type',
      'birthday': 'Birthday',
      'recurring': 'Recurring yearly',
      'notification': 'Notification',
      'daysBefore': 'Days before',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'completed': 'Completed',
      'uncompleted': 'Uncompleted',
      'completedAt': 'Completed at',
      'reactivate': 'Reactivate',
      'emptyAnniversary': 'No anniversaries yet, add your first one',
      'emptyWish': 'No wishes yet, add your first one',
      'birthDate': 'Birth Date',
      'retirementDate': 'Retirement Date',
      'lifeExpectancy': 'Life Expectancy',
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'notificationSettings': 'Notification Settings',
      'dataSync': 'Data Sync',
      'dataExport': 'Export Data',
      'dataImport': 'Import Data',
      'about': 'About',
      'version': 'Version',
      'age': 'years old',
      'distanceFromRetirement': 'Distance from retirement',
      'workedYears': 'Years worked',
      'relation': 'Relation',
      'noDate': 'No date',
    },
    'zh': {
      'appTitle': '人生倒计时',
      'clock': '时钟',
      'anniversary': '纪念日',
      'wish': '心愿',
      'settings': '设置',
      'lifeTimer': '人生定时器',
      'distanceFromLeaving': '距离理想离开',
      'elapsed': '已过',
      'years': '年',
      'months': '月',
      'days': '天',
      'hours': '时',
      'minutes': '分',
      'seconds': '秒',
      'addAnniversary': '添加纪念日',
      'addWish': '添加心愿',
      'editAnniversary': '编辑纪念日',
      'editWish': '编辑心愿',
      'name': '名称',
      'date': '日期',
      'type': '类型',
      'birthday': '生日',
      'recurring': '每年重复',
      'notification': '通知提醒',
      'daysBefore': '提前几天',
      'save': '保存',
      'cancel': '取消',
      'delete': '删除',
      'completed': '已完成',
      'uncompleted': '未完成',
      'completedAt': '完成于',
      'reactivate': '重新激活',
      'emptyAnniversary': '还没有纪念日，添加第一个吧',
      'emptyWish': '还没有心愿，添加第一个吧',
      'birthDate': '出生日期',
      'retirementDate': '计划退休日',
      'lifeExpectancy': '预期寿命',
      'darkMode': '深色主题',
      'language': '语言',
      'notificationSettings': '提醒设置',
      'dataSync': '数据同步',
      'dataExport': '数据导出',
      'dataImport': '数据导入',
      'about': '关于',
      'version': '版本',
      'age': '岁',
      'distanceFromRetirement': '距离退休',
      'workedYears': '已工作',
      'relation': '关系',
      'noDate': '无日期',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Convenience getters
  String get appTitle => translate('appTitle');
  String get clock => translate('clock');
  String get anniversary => translate('anniversary');
  String get wish => translate('wish');
  String get settings => translate('settings');
  String get lifeTimer => translate('lifeTimer');
  String get distanceFromLeaving => translate('distanceFromLeaving');
  String get elapsed => translate('elapsed');
  String get addAnniversary => translate('addAnniversary');
  String get addWish => translate('addWish');
  String get editAnniversary => translate('editAnniversary');
  String get editWish => translate('editWish');
  String get name => translate('name');
  String get date => translate('date');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get completed => translate('completed');
  String get uncompleted => translate('uncompleted');
  String get completedAt => translate('completedAt');
  String get reactivate => translate('reactivate');
  String get emptyAnniversary => translate('emptyAnniversary');
  String get emptyWish => translate('emptyWish');
  String get birthDate => translate('birthDate');
  String get retirementDate => translate('retirementDate');
  String get lifeExpectancy => translate('lifeExpectancy');
  String get darkMode => translate('darkMode');
  String get language => translate('language');
  String get about => translate('about');
  String get version => translate('version');
  String get age => translate('age');
  String get relation => translate('relation');
  String get noDate => translate('noDate');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}