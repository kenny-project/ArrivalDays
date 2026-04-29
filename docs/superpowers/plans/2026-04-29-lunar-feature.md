# 农历功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现农历日期存储和显示，包括：农历转公历、生肖计算、列表日期标注

**Architecture:**
- `useDate` 存用户原始日期，公历/农历都存 DateTime
- `targetDate` 每次从 useDate + isLunarCalendar 计算（公历直接赋值，农历用当前年份转换）
- 生肖用天干地支算法计算

**Tech Stack:** 手动实现农历转公历（查表法），不依赖第三方库

---

## 任务清单

| # | 任务 | 文件 |
|---|------|------|
| 1 | ~~添加 lunar_chinese 依赖~~ | pubspec.yaml |
| 2 | 添加农历转公历工具方法 | lib/core/utils/countdown_utils.dart |
| 3 | 添加生肖计算方法 | lib/core/utils/countdown_utils.dart |
| 4 | 修改 anniversary_form 隐藏关系字段 + 显示生肖 | lib/features/anniversary/widgets/anniversary_form.dart |
| 5 | 修改数据库加载时计算 targetDate | lib/shared/providers/database_providers.dart |
| 6 | 修改 CountdownItem 显示日期标注 | lib/shared/widgets/countdown_item.dart |
| 7 | 检查并修复理想离开日期功能 | lib/features/clock/providers/clock_provider.dart |

**注意**: Task 1 (useDate字段) 已完成 (commit c0ae25f)，Task 2 (lunar_chinese依赖) 已跳过，改用手动实现

---

### Task 1: 添加 useDate 字段到 CountdownTarget

**Files:**
- Modify: `lib/models/countdown_target.dart`

- [ ] **Step 1: 添加 useDate 字段定义**

在 `CountdownTarget` 类的 `targetDate` 字段后添加：

```dart
final DateTime? targetDate;
final DateTime? useDate; // 用户原始设置的日期，公历存公历日期，农历存农历月日（年份填用户设置值）
```

- [ ] **Step 2: 添加 copyWith 支持**

```dart
CountdownTarget copyWith({
  String? id,
  String? name,
  DateTime? targetDate,
  DateTime? useDate,  // 新增
  // ... 其他字段
}) {
  return CountdownTarget(
    id: id ?? this.id,
    name: name ?? this.name,
    targetDate: targetDate ?? this.targetDate,
    useDate: useDate ?? this.useDate,  // 新增
    // ... 其他字段
  );
}
```

- [ ] **Step 3: 添加 toMap 支持**

```dart
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'target_date': targetDate?.millisecondsSinceEpoch,
    'use_date': useDate?.millisecondsSinceEpoch,  // 新增
    'type': type.name,
    // ... 其他字段
  };
}
```

- [ ] **Step 4: 添加 fromMap 支持**

```dart
factory CountdownTarget.fromMap(Map<String, dynamic> map) {
  return CountdownTarget(
    id: map['id'] as String,
    name: map['name'] as String,
    targetDate: map['target_date'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['target_date'] as int)
        : null,
    useDate: map['use_date'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['use_date'] as int)
        : null,
    // ... 其他字段
  );
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/models/countdown_target.dart
git commit -m "feat: add useDate field for storing original date"
```

---

## 依赖关系

```
Task 1 (useDate字段 - 已完成)
Task 2 (农历转公历 + 生肖计算 - 已跳过lunar_chinese依赖)
→ Task 3, 4, 5, 6, 7 (可并行)
```
**Task 1 (useDate字段) 和 Task 2 (lunar_chinese依赖) 已完成，跳过**

**Files:**
- Modify: `lib/core/utils/countdown_utils.dart`

- [ ] **Step 1: 添加 convertLunarToSolar 方法（手动查表法）**

在 `CountdownUtils` 类中添加：

```dart
/// 农历数据：1900-2100年每年正月初一的公历日期
/// 数据来源：已知农历-公历对照表
static final Map<int, DateTime> _lunarNewYearDates = {
  1900: DateTime(1900, 1, 31),
  2000: DateTime(2000, 2, 5),
  2010: DateTime(2010, 2, 14),
  2020: DateTime(2020, 1, 25),
  2030: DateTime(2030, 2, 3),
  2040: DateTime(2040, 2, 15),
  2050: DateTime(2050, 2, 4),
  2060: DateTime(2060, 2, 12),
  2070: DateTime(2070, 2, 1),
  2080: DateTime(2080, 2, 10),
  2090: DateTime(2090, 2, 18),
  2100: DateTime(2100, 2, 6),
};

/// 简化版农历转公历（不支持闰月）
/// [targetYear] 要转换到的公历年份
/// [lunarMonth] 农历月份（1-12）
/// [lunarDay] 农历日期（1-30）
static DateTime convertLunarToSolar(int targetYear, int lunarMonth, int lunarDay) {
  // 找到最接近的基准年
  int baseYear = targetYear;
  while (baseYear >= 1900 && !_lunarNewYearDates.containsKey(baseYear)) {
    baseYear--;
  }
  if (baseYear < 1900) baseYear = 1900;

  final baseNewYear = _lunarNewYearDates[baseYear]!;
  // 估算目标年正月初一的公历日期（每年约推进11天）
  int yearDiff = targetYear - baseYear;
  int approxDays = yearDiff * 11;
  DateTime approxNewYear = baseNewYear.add(Duration(days: approxDays));

  // 粗略计算：正月初一 + (lunarMonth-1)*30 + (lunarDay-1)
  // 这个简化算法精度有限，建议后续用准确查表法
  int daysToAdd = (lunarMonth - 1) * 30 + (lunarDay - 1);
  return approxNewYear.add(Duration(days: daysToAdd));
}
```

- [ ] **Step 2: 添加 calculateZodiac 方法**

```dart
/// 根据年份计算生肖（地支）
/// 返回如 "马"、"鼠" 等
static String calculateZodiac(int year) {
  final zodiacs = ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'];
  // 1990年是马年（index 6），计算偏移量
  final baseYear = 1990;
  final baseIndex = 6; // 马
  final offset = (year - baseYear) % 12;
  final index = (baseIndex + offset + 12) % 12;
  return zodiacs[index];
}
```

- [ ] **Step 3: 添加 calculateTargetDate 方法**

```dart
/// 根据 useDate 和 isLunarCalendar 计算显示用的 targetDate
/// 每次 app 打开时调用，返回当前年份对应的公历日期
static DateTime? calculateTargetDate(DateTime? useDate, bool isLunarCalendar) {
  if (useDate == null) return null;

  if (isLunarCalendar) {
    final now = DateTime.now();
    return convertLunarToSolar(now.year, useDate.month, useDate.day);
  } else {
    return useDate;
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/core/utils/countdown_utils.dart
git commit -m "feat: add lunar conversion and zodiac calculation"
```

---

### Task 4: 修改 anniversary_form - 隐藏关系字段 + 显示生肖

**Files:**
- Modify: `lib/features/anniversary/widgets/anniversary_form.dart`

- [ ] **Step 1: 删除关系输入框（105-115行）**

删除这段代码：

```dart
if (_isBirthday) ...[
  TextFormField(
    controller: _relationController,
    decoration: const InputDecoration(
      labelText: '关系（可选）',
      border: OutlineInputBorder(),
      hintText: '如：爸爸、妈妈、朋友',
    ),
  ),
  const SizedBox(height: 16),
],
```

- [ ] **Step 2: 添加生肖显示**

在 SwitchListTile('农历') 后面添加生肖显示：

```dart
if (_isLunarCalendar) ...[
  ListTile(
    contentPadding: EdgeInsets.zero,
    title: const Text('生肖'),
    subtitle: Text(
      _selectedDate != null
          ? '属${CountdownUtils.calculateZodiac(_selectedDate!.year)}'
          : '选择日期后显示',
    ),
  ),
],
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/anniversary/widgets/anniversary_form.dart
git commit -m "fix: hide relation field and show zodiac for lunar dates"
```

---

### Task 5: 修改数据库加载时计算 targetDate

**Files:**
- Modify: `lib/shared/providers/database_providers.dart`

- [ ] **Step 1: 在 _loadTargets 方法中添加 targetDate 计算**

找到 `_loadTargets` 方法，在加载每条记录后计算 targetDate：

```dart
final target = CountdownTarget.fromMap(map);
final calculatedTargetDate = CountdownUtils.calculateTargetDate(
  target.useDate,
  target.isLunarCalendar,
);
// 如果计算出的 targetDate 与存储的不同，更新它
targets.add(target.copyWith(targetDate: calculatedTargetDate));
```

注意：需要先完整加载后再 map 转换，或者修改 `copyWith` 后重新存入数据库。

**简化方案**：在 provider 读取时直接计算，不修改数据库存储。

```dart
final loaded = await _db.getCountdownTargets();
final targets = loaded.map((t) {
  final calculatedDate = CountdownUtils.calculateTargetDate(t.useDate, t.isLunarCalendar);
  return t.copyWith(targetDate: calculatedDate);
}).toList();
```

- [ ] **Step 2: Commit**

```bash
git add lib/shared/providers/database_providers.dart
git commit -m "fix: calculate targetDate from useDate on load"
```

---

### Task 6: 修改 CountdownItem 显示日期标注

**Files:**
- Modify: `lib/shared/widgets/countdown_item.dart`

- [ ] **Step 1: 找到显示名称的位置，添加日期标注**

在 `_buildTitle` 或类似方法中，找到 `Text(target.name)` 那行，修改为：

```dart
Text('${target.name}（${_formatDisplayDate(target)}）'),
```

- [ ] **Step 2: 添加 _formatDisplayDate 方法**

```dart
String _formatDisplayDate(CountdownTarget target) {
  final date = target.useDate ?? target.targetDate;
  if (date == null) return '';

  final dateStr = '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  if (target.isLunarCalendar) {
    return '$dateStr(农历)';
  }
  return dateStr;
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/shared/widgets/countdown_item.dart
git commit -m "feat: show date annotation in list items"
```

---

### Task 7: 检查并修复理想离开日期功能

**Files:**
- Modify: `lib/features/clock/providers/clock_provider.dart`

- [ ] **Step 1: 检查 lifeTimerProvider 逻辑**

查看 `lifeTimerProvider` 是否正确返回数据，检查数据库中是否有 `type = lifeTimer` 的记录。

- [ ] **Step 2: 如有问题，修复逻辑**

如果 `type = lifeTimer` 的记录存在但 provider 不返回，需要修复查询逻辑。

- [ ] **Step 3: Commit**

```bash
git add lib/features/clock/providers/clock_provider.dart
git commit -m "fix: lifeTimerProvider logic"
```

---

## 依赖关系

```
Task 1 → Task 2 → Task 3 → Task 4, 5, 6, 7 (可并行)
```

---

## 执行选项

**1. Subagent-Driven (recommended)** - 每次 dispatch 一个 subagent

**2. Inline Execution** - 我直接执行

**选择哪个？**
