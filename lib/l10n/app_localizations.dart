import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/utils/countdown_utils.dart';

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
      'confirm': 'OK',
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
      'loginPassword': 'Login Password',
      'dataReset': 'Reset Data',
      'setPassword': 'Set Password',
      'changePassword': 'Change Password',
      'disablePassword': 'Disable Password',
      'biometricUnlock': 'Biometric Unlock',
      'pinMismatch': 'PINs do not match',
      'pinIncorrect': 'Incorrect PIN',
      'passwordSet': 'Password set',
      'passwordChanged': 'Password changed',
      'passwordDisabled': 'Password disabled',
      'verifyIdentity': 'Verify Identity',
      'enableBiometric': 'Enable Biometric?',
      'enableBiometricDesc': 'Use fingerprint/face to quickly unlock?',
      'skip': 'Skip',
      'enable': 'Enable',
      'resetConfirmTitle': 'Delete all data?',
      'resetConfirmDesc': 'This cannot be undone. All settings and countdown data will be deleted.',
      'dataResetDone': 'Data has been reset',
      'basicInfo': 'Basic Info',
      'appearance': 'Appearance',
      'features': 'Features',
      'notSet': 'Not set',
      'selectLanguage': 'Select Language',
      'followSystem': 'Follow System',
      'chinese': 'Chinese',
      'ageHint': 'Age',
      'enterLifeExpectancy': 'Enter life expectancy',
      'dataSyncPlaceholder': 'Data sync (coming soon)',
      'importSuccess': 'Import successful',
      'importFail': 'Import failed',
      'verifyPassword': 'Verify Password',
      'verifyIdentityToReset': 'Verify identity to reset data',
      'notificationPermission': 'Notification Permission',
      'enabled': 'Enabled',
      'notEnabled': 'Not enabled',
      'requestAgain': 'Request again',
      'enableNotification': 'Enable notifications',
      'notificationDescription': 'After enabling notifications, anniversaries and wishes will remind you at 9:00 AM the day before the set date.',
      'setPasswordDesc': 'Set a 6-digit PIN to protect the app',
      'passwordSetStatus': 'Password is set',
      'passwordVerifyDesc': 'App will require verification on cold start',
      'biometricUnlockDesc': 'Use biometrics for quick unlock',
      'verifyCurrentPassword': 'Verify current password',
      'setNewPassword': 'Set new password',
      'confirmNewPassword': 'Confirm new password',
      'confirmPassword': 'Confirm password',
      'currentPasswordIncorrect': 'Current password is incorrect',
      'biometricVerifyFailed': 'Biometric verification failed, please ensure fingerprint/face is enrolled',
      'verifyIdentityForBiometric': 'Verify identity to enable biometric',
      'verifyIdentityToUnlock': 'Verify identity to unlock app',
      'noAnniversary': 'No anniversaries yet',
      'noWish': 'No wishes yet',
      'daysUntilBirthday': ' days until birthday',
      'thisYear': 'This year',
      'yearsOld': 'years old',
      'distance': 'In',
      'lunarSuffix': '(Lunar)',
      'selectDate': 'Please select a date',
      'enterName': 'Please enter name',
      'zodiac': 'Zodiac',
      'selectDateFirst': 'Shown after selecting a date',
      'wishName': 'Wish name',
      'enterWishName': 'Please enter wish name',
      'targetDateOptional': 'Target date (optional)',
      'add': 'Add',
      'seeAll': 'See all',
      'noCompletedWish': 'No completed wishes yet',
      'saveFailed': 'Save failed',
      'setIdealLeaveDate': 'Set your ideal leave date',
      'deleteConfirm': 'Confirm Delete',
      'deleteConfirmDesc': 'Are you sure you want to delete',
      'targetDate': 'Target Date',
      'noDateLimit': 'No date limit',
      'completedOn': 'Completed on',
      'markComplete': 'Mark Complete',
      'ageLabel': 'Age',
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
      'confirm': '确定',
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
      'loginPassword': '登录密码',
      'dataReset': '数据重置',
      'setPassword': '设置密码',
      'changePassword': '修改密码',
      'disablePassword': '关闭密码',
      'biometricUnlock': '指纹/面容解锁',
      'pinMismatch': '两次输入的密码不一致',
      'pinIncorrect': '密码错误',
      'passwordSet': '密码已设置',
      'passwordChanged': '密码已修改',
      'passwordDisabled': '密码已关闭',
      'verifyIdentity': '验证身份',
      'enableBiometric': '启用生物识别？',
      'enableBiometricDesc': '是否使用指纹/面容快速解锁应用？',
      'skip': '跳过',
      'enable': '启用',
      'resetConfirmTitle': '确定要清除所有数据吗？',
      'resetConfirmDesc': '此操作不可恢复，所有设置和倒计时数据将被删除。',
      'dataResetDone': '数据已重置',
      'basicInfo': '基本信息',
      'appearance': '外观',
      'features': '功能',
      'notSet': '未设置',
      'selectLanguage': '选择语言',
      'followSystem': '跟随系统',
      'chinese': '中文',
      'ageHint': '年龄',
      'enterLifeExpectancy': '请输入预期寿命',
      'dataSyncPlaceholder': '数据同步功能（预留接口）',
      'importSuccess': '导入成功',
      'importFail': '导入失败',
      'verifyPassword': '验证密码',
      'verifyIdentityToReset': '验证身份以重置数据',
      'notificationPermission': '通知权限',
      'enabled': '已开启',
      'notEnabled': '未开启',
      'requestAgain': '重新请求',
      'enableNotification': '开启通知',
      'notificationDescription': '开启通知权限后，纪念日和心愿将在设定日期的前一天上午9:00提醒您。',
      'setPasswordDesc': '设置6位数字密码保护应用',
      'passwordSetStatus': '已设置密码',
      'passwordVerifyDesc': '应用将在冷启动时要求验证',
      'biometricUnlockDesc': '使用生物识别快速解锁',
      'verifyCurrentPassword': '验证当前密码',
      'setNewPassword': '设置新密码',
      'confirmNewPassword': '确认新密码',
      'confirmPassword': '确认密码',
      'currentPasswordIncorrect': '当前密码错误',
      'biometricVerifyFailed': '生物识别验证失败，请确认已录入指纹/面容',
      'verifyIdentityForBiometric': '验证身份以启用生物识别',
      'verifyIdentityToUnlock': '验证身份以解锁应用',
      'noAnniversary': '暂无纪念日',
      'noWish': '暂无心愿',
      'daysUntilBirthday': '距离生日还有',
      'thisYear': '今年',
      'yearsOld': '周岁',
      'distance': '距离',
      'lunarSuffix': '(农历)',
      'selectDate': '请选择日期',
      'enterName': '请输入名称',
      'zodiac': '生肖',
      'selectDateFirst': '选择日期后显示',
      'wishName': '心愿名称',
      'enterWishName': '请输入心愿名称',
      'targetDateOptional': '目标日期（可选）',
      'add': '添加',
      'seeAll': '查看全部',
      'noCompletedWish': '暂无已完成的心愿',
      'saveFailed': '保存失败',
      'setIdealLeaveDate': '设置你的理想离开日期',
      'deleteConfirm': '删除确认',
      'deleteConfirmDesc': '确定要删除',
      'targetDate': '目标日期',
      'noDateLimit': '无日期限制',
      'completedOn': '完成于',
      'markComplete': '标记完成',
      'ageLabel': '年龄',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  CountdownLocalizations get countdownLoc => locale.languageCode == 'zh'
      ? CountdownLocalizations.zh
      : CountdownLocalizations.en;

  // Convenience getters
  String get appTitle => translate('appTitle');
  String get clock => translate('clock');
  String get anniversary => translate('anniversary');
  String get wish => translate('wish');
  String get settings => translate('settings');
  String get lifeTimer => translate('lifeTimer');
  String get distanceFromLeaving => translate('distanceFromLeaving');
  String get distanceFromRetirement => translate('distanceFromRetirement');
  String get workedYears => translate('workedYears');
  String get elapsed => translate('elapsed');
  String get years => translate('years');
  String get months => translate('months');
  String get days => translate('days');
  String get hours => translate('hours');
  String get minutes => translate('minutes');
  String get seconds => translate('seconds');
  String get addAnniversary => translate('addAnniversary');
  String get addWish => translate('addWish');
  String get editAnniversary => translate('editAnniversary');
  String get editWish => translate('editWish');
  String get name => translate('name');
  String get date => translate('date');
  String get type => translate('type');
  String get birthday => translate('birthday');
  String get recurring => translate('recurring');
  String get notification => translate('notification');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
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
  String get notificationSettings => translate('notificationSettings');
  String get dataSync => translate('dataSync');
  String get dataExport => translate('dataExport');
  String get dataImport => translate('dataImport');
  String get about => translate('about');
  String get version => translate('version');
  String get age => translate('age');
  String get relation => translate('relation');
  String get noDate => translate('noDate');
  String get loginPassword => translate('loginPassword');
  String get dataReset => translate('dataReset');
  String get setPassword => translate('setPassword');
  String get changePassword => translate('changePassword');
  String get disablePassword => translate('disablePassword');
  String get biometricUnlock => translate('biometricUnlock');
  String get pinMismatch => translate('pinMismatch');
  String get pinIncorrect => translate('pinIncorrect');
  String get passwordSet => translate('passwordSet');
  String get passwordChanged => translate('passwordChanged');
  String get passwordDisabled => translate('passwordDisabled');
  String get verifyIdentity => translate('verifyIdentity');
  String get enableBiometric => translate('enableBiometric');
  String get enableBiometricDesc => translate('enableBiometricDesc');
  String get skip => translate('skip');
  String get enable => translate('enable');
  String get resetConfirmTitle => translate('resetConfirmTitle');
  String get resetConfirmDesc => translate('resetConfirmDesc');
  String get dataResetDone => translate('dataResetDone');
  String get basicInfo => translate('basicInfo');
  String get appearance => translate('appearance');
  String get features => translate('features');
  String get notSet => translate('notSet');
  String get selectLanguage => translate('selectLanguage');
  String get followSystem => translate('followSystem');
  String get chinese => translate('chinese');
  String get ageHint => translate('ageHint');
  String get enterLifeExpectancy => translate('enterLifeExpectancy');
  String get dataSyncPlaceholder => translate('dataSyncPlaceholder');
  String get importSuccess => translate('importSuccess');
  String get importFail => translate('importFail');
  String get verifyPassword => translate('verifyPassword');
  String get verifyIdentityToReset => translate('verifyIdentityToReset');
  String get notificationPermission => translate('notificationPermission');
  String get enabled => translate('enabled');
  String get notEnabled => translate('notEnabled');
  String get requestAgain => translate('requestAgain');
  String get enableNotification => translate('enableNotification');
  String get notificationDescription => translate('notificationDescription');
  String get setPasswordDesc => translate('setPasswordDesc');
  String get passwordSetStatus => translate('passwordSetStatus');
  String get passwordVerifyDesc => translate('passwordVerifyDesc');
  String get biometricUnlockDesc => translate('biometricUnlockDesc');
  String get verifyCurrentPassword => translate('verifyCurrentPassword');
  String get setNewPassword => translate('setNewPassword');
  String get confirmNewPassword => translate('confirmNewPassword');
  String get confirmPassword => translate('confirmPassword');
  String get currentPasswordIncorrect => translate('currentPasswordIncorrect');
  String get biometricVerifyFailed => translate('biometricVerifyFailed');
  String get verifyIdentityForBiometric => translate('verifyIdentityForBiometric');
  String get verifyIdentityToUnlock => translate('verifyIdentityToUnlock');
  String get noAnniversary => translate('noAnniversary');
  String get noWish => translate('noWish');
  String get daysUntilBirthday => translate('daysUntilBirthday');
  String get thisYear => translate('thisYear');
  String get yearsOld => translate('yearsOld');
  String get distance => translate('distance');
  String get lunarSuffix => translate('lunarSuffix');
  String get selectDate => translate('selectDate');
  String get enterName => translate('enterName');
  String get zodiac => translate('zodiac');
  String get selectDateFirst => translate('selectDateFirst');
  String get wishName => translate('wishName');
  String get enterWishName => translate('enterWishName');
  String get targetDateOptional => translate('targetDateOptional');
  String get add => translate('add');
  String get seeAll => translate('seeAll');
  String get noCompletedWish => translate('noCompletedWish');
  String get saveFailed => translate('saveFailed');
  String get setIdealLeaveDate => translate('setIdealLeaveDate');
  String get deleteConfirm => translate('deleteConfirm');
  String get deleteConfirmDesc => translate('deleteConfirmDesc');
  String get targetDate => translate('targetDate');
  String get noDateLimit => translate('noDateLimit');
  String get completedOn => translate('completedOn');
  String get markComplete => translate('markComplete');
  String get ageLabel => translate('ageLabel');
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