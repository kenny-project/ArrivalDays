# ArrivalDays Bug List

## Bug ID 格式
`AD-[序号]-[模块]-[严重程度]`

严重程度: Critical(崩溃), Major(功能错误), Minor(体验问题)

---

## AD-001-[编辑纪念日]-Major

**问题**: 编辑纪念日时，"每年重复"选项逻辑写反了。生日默认是每年重复的，但代码逻辑错误。

**原因**: 代码中 `_isRecurring` 的初始化和切换逻辑不正确

**修复**: 编辑纪念日时，生日类型自动设置 isRecurring = true

**状态**: 已修复

---

## AD-002-[纪念日详情]-Major

**问题**: 纪念日详情页中的"每年重复"和"通知提醒"开关没有与实际数据对应

**原因**: SwitchListTile 的 value 没有绑定 target 的实际属性

**修复**: 详情页 SwitchListTile 的 value 已正确绑定 target.isRecurring 和 target.hasNotification

**状态**: 已修复

---

## AD-003-[纪念日列表]-Critical

**问题**: 纪念日列表右滑时应用崩溃

**原因**: Dismissible 的 onDismissed 直接调用 onTap，而 onTap 是导航回调，不是删除回调

**修复**: 修复 dismissible 的 confirmDismiss 逻辑，删除操作通过独立的 onDelete 回调执行

**状态**: 已修复

---

## AD-004-[时钟界面]-Major

**问题**: 时钟界面下的纪念日列表、心愿列表都不支持右滑删除操作

**原因**: ClockScreen 的列表项没有设置 showDeleteAction = false，也缺少独立的 onDelete 回调

**修复**: ClockScreen 添加 showDeleteAction: false，纪念日/心愿列表添加右滑删除

**状态**: 已修复

---

## AD-005-[时钟界面]-Minor

**问题**: 时钟界面的"查看全部"按钮点击后没有跳转到对应界面

**原因**: onSeeAllPressed 回调被注释掉，没有实现导航逻辑

**修复**: MainScreen 添加 _navigateToTab 方法，ClockScreen 的查看全部按钮可跳转

**状态**: 已修复

---

## AD-006-[时钟界面]-Major

**问题**: "距离退休"的时间没有更新，不会动态倒计时

**原因**: retirementTimerProvider 没有被 ClockScreen 的 1 秒刷新机制监听

**修复**: 添加 tickerProvider，每秒更新一次，ClockScreen 和所有 clock providers 都 watch 这个 ticker

**状态**: 已修复

---

## AD-007-[保存机制]-Critical

**问题**: 纪念日/心愿保存失败，但不显示任何错误提示

**原因**:
1. onSave 回调是 fire-and-forget，没有 await
2. Navigator.pop 在保存完成前就执行
3. 数据库操作没有 try-catch，错误被吞掉

**涉及文件**:
- `anniversary_list_screen.dart:71-74` - addTarget 没有 await
- `anniversary_detail_screen.dart:111-114` - updateAnniversary 没有 await
- `wish_list_screen.dart:156-159` - addTarget 没有 await
- `wish_detail_screen.dart:105-108` - updateWish 没有 await
- `database_providers.dart` - addTarget/updateTarget 没有 try-catch

**修复**:
1. 所有 onSave 改为 `Future<bool> Function(CountdownTarget)`
2. 保存方法返回 bool，失败时返回 false
3. 数据库操作加 try-catch
4. 保存成功后再 Navigator.pop，失败显示 SnackBar "保存失败"

**状态**: 已修复

---

## AD-008-[生日日历]-Minor

**问题**: 编辑生日时，打开的日历包含年，但生日只需要选月日

**原因**: showDatePicker 使用完整日期作为 initialDate

**状态**: 待修复

---

## 强制规则

### 所有保存相关 Bug 必须记录到 BUG_LIST.md

**规则**: 任何保存失败、加载失败、数据不同步的问题，发现后必须立即记录到此文档

**格式**:
```markdown
## AD-[序号]-[模块]-【严重程度】

**问题**: 
**原因**: 
**涉及文件**:
**修复**:
**状态**: 
```

---

## 状态说明

| Bug ID | 状态 | 修复说明 |
|--------|------|----------|
| AD-001 | 已修复 | 编辑纪念日时，生日类型自动设置 isRecurring = true |
| AD-002 | 已修复 | 详情页 SwitchListTile 的 value 已正确绑定 target.isRecurring 和 target.hasNotification |
| AD-003 | 已修复 | 修复 dismissible 的 confirmDismiss 逻辑，删除操作通过回调执行 |
| AD-004 | 已修复 | 纪念日/心愿列表添加右滑删除，心愿已完成列表也添加了删除 |
| AD-005 | 已修复 | MainScreen 添加 _navigateToTab 方法，ClockScreen 的查看全部按钮可跳转 |
| AD-006 | 已修复 | ClockScreen 1秒刷新机制包含了"距离退休"时间 |
| AD-007 | 已修复 | 所有保存方法返回 bool 加 try-catch，失败显示 Toast |
| AD-008 | 待修复 | 生日日历需要只显示月日选择器 |
