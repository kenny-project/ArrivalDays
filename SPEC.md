# ArrivalDays - 人生倒计时应用 规格文档

> **版本**: v1.0.0
> **更新日期**: 2026-04-28

---

## 1. 项目概述

- **项目名称**: ArrivalDays
- **项目类型**: Flutter 跨平台应用 (iOS / Android / Web)
- **核心功能**: 人生倒计时工具，帮助用户追踪重要时间节点、纪念日和心愿
- **目标用户**: 关注人生规划、珍惜时间的用户

---

## 2. 技术栈

| 项目 | 选择 |
|------|------|
| 框架 | Flutter 3.x |
| 状态管理 | Riverpod (flutter_riverpod) |
| 本地存储 | SQLite (sqflite + sqflite_common_ffi) |
| 安全存储 | flutter_secure_storage (Android Keystore / iOS Keychain) |
| 生物识别 | local_auth (指纹 / 面容 / 设备密码) |
| UI 风格 | Material 3 (Material Design 3) |
| 主题 | 深色主题 + 浅色主题切换 |
| 多语言 | 中文 / 英文 (flutter_localizations + intl) |
| 通知 | flutter_local_notifications |
| 桌面小组件 | home_widget |
| 数据导出 | JSON 文件导出/导入 |

**暂不开发**: 云同步功能（预留接口）

---

## 3. 数据模型

### 3.1 用户设置 (UserSettings)

```dart
class UserSettings {
  String id;                    // UUID
  DateTime birthDate;           // 出生日期（必填）
  DateTime? retirementDate;     // 计划退休日（可选）
  int lifeExpectancy;           // 预期寿命，默认80岁
  bool isDarkMode;              // 深色模式开关
  String language;              // 语言，"zh" | "en"
  DateTime createdAt;
  DateTime updatedAt;
}
```

### 3.2 倒计时目标 (CountdownTarget) - 统一模型

所有倒计时目标（定时器、纪念日、心愿）共用同一数据模型，通过 `type` 区分：

```dart
enum CountdownTargetType {
  lifeTimer,    // 人生定时器
  anniversary,  // 纪念日
  birthday,     // 生日
  wish,         // 心愿
}

class CountdownTarget {
  String id;                      // UUID
  String name;                    // 名称
  DateTime? targetDate;           // 目标日期（可选，心愿可无日期）
  CountdownTargetType type;       // 类型
  bool isRecurring;               // 是否每年重复（生日默认true）
  bool isCompleted;               // 是否已完成（仅心愿使用）
  DateTime? completedAt;          // 完成时间
  String? relation;               // 关系（仅生日使用，如"爸爸"）
  bool hasNotification;           // 是否开启通知
  int notificationDaysBefore;     // 提前几天通知（0=当天）
  DateTime createdAt;
  DateTime updatedAt;
}
```

### 3.3 纪念日类型细分

```dart
enum AnniversaryType {
  birthday,     // 生日（每年重复）
  anniversary,   // 普通纪念日
}
```

---

## 4. 功能模块

### 4.1 时钟 Tab（首页）

布局结构（从上到下）：

```
┌─────────────────────────────────┐
│         状态栏 + 标题            │
├─────────────────────────────────┤
│                                 │
│      人生定时器卡片 (1/3高度)     │
│      距离理想离开: XX年XX月XX天   │
│      XX时XX分XX秒                │
│      已过: XX年XX月               │
│                                 │
├─────────────────────────────────┤
│  纪念日                          │
│  ├─ 🎂 爸爸生日 29岁 还差23天05时30分 │
│  └─ 💕 结婚纪念 还差45天12时30分  │
├─────────────────────────────────┤
│  心愿                            │
│  ├─ 📋 学会游泳 还差30天05时12分  │
│  └─ 📋 读完《xxx》              │
└─────────────────────────────────┘
```

**功能**：
- 显示人生已过去时间（文字形式：已过 XX年XX月XX天 XX时XX分XX秒）
- 显示距离目标日期的倒计时（精确到时分秒）
- 点击各区域标题跳转至对应详情页
- 心愿若无日期，只显示名称，不显示倒计时

### 4.2 纪念日 Tab

**列表展示**：
- 普通纪念日：`💕 结婚纪念 还差45天12时30分`
- 生日：`🎂 爸爸生日 29岁 还差23天05时12分`（显示年龄）
- 已过期的显示：`已过3天`（红色标注）

**操作**：
- 右滑删除
- 点击进入详情页，详情页有编辑按钮
- 底部弹窗新增/编辑

**排序**：按目标日期由近到远

**空状态**：引导文案"还没有纪念日，添加第一个吧"+添加按钮

### 4.3 心愿 Tab

**两个子 Tab**：

```
[未完成] [已完成]
```

**未完成心愿列表**：
- 有日期：`📋 学会游泳 还差30天05时12分30秒`
- 无日期：`📋 读完《xxx》`（只显示名称）
- 点击完成按钮标记为已完成

**已完成心愿列表**：
- `✅ 读完《xxx》 2026-01-15完成`
- 可重新激活（恢复至未完成）

**操作**：
- 右滑删除
- 点击进入详情页，详情页有编辑按钮
- 底部弹窗新增/编辑

**排序**：有日期的按目标日期由近到远，无日期的排在最后

**过期处理**：保持在未完成列表，不自动转移

### 4.4 设置 Tab

| 设置项 | 类型 | 说明 |
|--------|------|------|
| 出生日期 | DateTime | 必填，日期选择器 |
| 计划退休日 | DateTime | 可选，日期选择器 |
| 预期寿命 | int | 数字输入，默认80岁 |
| 深色主题 | bool | Switch 开关 |
| 语言 | String | 下拉选择：中文/English |
| 登录密码 | - | 跳转至密码设置页（见 4.6） |
| 提醒设置 | - | 跳转至通知权限设置页 |
| 数据同步 | - | 预留入口（暂不开发） |
| 数据导出 | - | 导出JSON文件 |
| 数据导入 | - | 导入JSON文件 |
| 数据重置 | - | 清除所有数据并重置应用（需验证身份） |
| 关于 | - | 版本号 v1.0.0 |

### 4.5 退休日期显示

在时钟 Tab 的定时器卡片中，额外显示：
- 距离退休：XX年XX月XX天 XX时XX分
- 已工作：XX年XX月

### 4.6 登录密码

#### 4.6.1 概述

应用默认无密码。用户可在设置中开启登录密码，开启后每次冷启动需验证身份才能进入应用。

#### 4.6.2 密码设置

**设置入口**：设置 → 登录密码

**未设置密码时**：
- 点击进入密码设置页
- 输入 6 位数字 PIN
- 再次输入确认
- 保存成功后弹窗询问：「是否启用指纹/面容解锁？」
  - 启用：调用系统生物识别注册
  - 跳过：仅使用 PIN 解锁

**已设置密码时**：
- 显示「修改密码」选项：需先验证旧 PIN → 输入新 PIN → 确认
- 显示「关闭密码」选项：需验证当前身份（PIN 或生物识别）后清除密码
- 显示「指纹/面容解锁」开关（仅在设备支持时显示）

#### 4.6.3 锁屏验证

**触发时机**：仅冷启动（应用进程被杀后重新打开）

**锁屏界面**：
```
┌─────────────────────────────────┐
│           应用 Logo              │
│                                 │
│      ┌─ ┌─ ┌─ ┌─ ┌─ ┌─┐       │
│      │  │  │  │  │  │  │       │
│      └─ └─ └─ └─ └─ └─┘       │
│        6 位数字 PIN 输入         │
│                                 │
│         [指纹/面容图标]          │
│     点击使用生物识别解锁          │
└─────────────────────────────────┘
```

**验证方式**（用户可自由选择）：
1. **输入 PIN**：在键盘输入 6 位数字，输满自动验证
2. **生物识别**：点击图标调用 `local_auth`，弹出系统指纹/面容/设备密码验证框

**验证失败**：
- PIN 错误：震动提示，清空输入，可重试（无次数限制）
- 生物识别失败：可重试或切换为 PIN 输入

#### 4.6.4 数据重置

设置页新增「数据重置」入口。点击后：
1. 若已设置密码：需先验证身份（PIN 或生物识别）
2. 弹窗二次确认：「确定要清除所有数据吗？此操作不可恢复。」
3. 确认后：清除所有数据，重置为初始状态，关闭密码保护

#### 4.6.6 技术方案

**新增依赖**：
- `flutter_secure_storage`：安全存储 PIN（Android Keystore / iOS Keychain）
- `local_auth`：系统生物识别 + 设备密码验证

**存储方案**：
- PIN 哈希值存储在 `flutter_secure_storage`（不存明文）
- 生物识别开关状态存储在 `flutter_secure_storage`
- 不使用 SQLite 存储密码相关信息

**锁屏实现**：
- 在 `MaterialApp` 外层包裹 `LockScreen` Widget
- 通过 Riverpod provider 管理认证状态（`isAuthenticated`）
- 冷启动时 `isAuthenticated = false`，显示锁屏
- 验证成功后 `isAuthenticated = true`，显示主界面

---

## 5. 通知功能

### 5.1 通知触发时机

- **当天早上 9:00**：目标日期当天提醒
- **前一天早上 9:00**：提前1天提醒

### 5.2 单独设置

每个目标可单独开启/关闭通知，并设置提前几天通知（0=当天，1=前一天，7=前一周）

### 5.3 权限

- iOS：请求通知权限（UNUserNotificationCenter）
- Android：请求通知权限（POST_NOTIFICATIONS）
- Web：暂不支持

---

## 6. 桌面小组件

### 6.1 支持平台

- iOS（iOS 14+ WidgetKit）
- Android（App Widget）

### 6.2 小组件内容

显示最重要的倒计时：
- 人生定时器（主要）
- 下一个即将到来的纪念日/心愿

### 6.3 Web

暂不支持 Web Widget

---

## 7. 数据导出/导入

- **格式**：JSON 文件
- **导出内容**：所有数据（用户设置 + 所有倒计时目标）
- **导入**：选择 JSON 文件覆盖或合并

---

## 8. 国际化

### 8.1 支持语言

- 中文（zh_CN）- 默认
- English（en）

### 8.2 本地化内容

- 界面所有文字
- 日期格式（MMdd / ddMM）
- 通知文案

---

## 9. 架构设计

### 9.1 项目结构

```
lib/
├── main.dart
├── app.dart
├── l10n/                    # 国际化
│   ├── app_zh.arb
│   └── app_en.arb
├── core/                    # 核心模块
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── database/
├── features/                # 功能模块
│   ├── settings/
│   ├── countdown/           # 统一倒计时模型
│   ├── clock/               # 时钟Tab
│   ├── anniversary/         # 纪念日Tab
│   ├── wish/                # 心愿Tab
│   └── widget/              # 桌面小组件
└── shared/                  # 共享组件
    ├── widgets/
    └── providers/
```

### 9.2 数据库表

```sql
-- 用户设置表
CREATE TABLE user_settings (
  id TEXT PRIMARY KEY,
  birth_date INTEGER NOT NULL,
  retirement_date INTEGER,
  life_expectancy INTEGER DEFAULT 80,
  is_dark_mode INTEGER DEFAULT 0,
  language TEXT DEFAULT 'zh',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- 倒计时目标表（统一模型）
CREATE TABLE countdown_targets (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  target_date INTEGER NOT NULL,
  type TEXT NOT NULL,           -- 'lifeTimer' | 'anniversary' | 'birthday' | 'wish'
  is_recurring INTEGER DEFAULT 0,
  is_completed INTEGER DEFAULT 0,
  completed_at INTEGER,
  relation TEXT,
  has_notification INTEGER DEFAULT 1,
  notification_days_before INTEGER DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

---

## 10. 待确认/待定

- [x] 登录密码功能需求确认（2026-05-09）

---

## 11. 后续工作

确认后进入开发阶段。
