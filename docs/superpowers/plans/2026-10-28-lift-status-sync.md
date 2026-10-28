# Lift Status Sync Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan in the current session.

**Goal:** 首页和启动页的升降杆 UI 及 0x0010 控制寄存器跟随下位机 0x0011 实际状态。

**Architecture:** 在两页共用的 JoystickControl 中读取状态及控制值，不一致时回写控制，并统一映射 UI。命令总线串行发送写入并记录操作版本，保证本地手势、排队停止与反馈校正不会相互覆盖。

**Tech Stack:** Flutter / Dart / flutter_test。

**Spec:** `docs/superpowers/specs/2026-10-28-lift-status-sync-design.md`

## Global Constraints

- 0x0011: 0 停止，1 手动上升，2 手动下降，3 一键上升，4 一键下降。
- 用户已追加确认控制寄存器也要回写为状态值；先比较，相等不重复写；沿用既有图片和布局。
- 保留首页首轮 0x0012 → 0x0006 → 0x01E5 的读取顺序。
- 在当前工作区修复，保留全部既有未提交修改，不自动提交。

## Review Focus

- 空闲后出现下位机动作，仍能检测。
- 页面被覆盖及旧响应返回，不能污染当前状态。
- 本地手动操作期间反馈停止，松手仍须下发停止。
- 通信失败或未知状态，保留显示且能恢复。
- 首页和启动页使用相同修复，保持原有控制值。

## Task 1: 共用组件修复

**Files:** `lib/pages/joystick/ui.dart`, `test/joystick_status_sync_test.dart`, `test/lift_current_test.dart`。

- [x] 先写状态变化、生命周期、手势与过期响应测试，运行并确认失败原因。
- [x] 统一 0～4 映射；持续、单次在途、可暂停的 500ms 轮询；保护手势及命令代次。
- [x] 更新原有“空闲后停止轮询”的断言，验证不读取电流。
- [x] 运行组件回归测试。

## Task 2: 两页验证

**Files:** `lib/pages/main/ui.dart`, `lib/pages/start/ui.dart`, `test/lift_pages_status_sync_test.dart`。

- [x] 为启动页提供与首页一致的 Modbus 服务注入接口，默认服务不变。
- [x] 以真实首页和启动页验证 4 → 3 → 2 → 1 → 0 的显示变化。
- [x] 首页接入 `beforeStatusRead` 等待既有读取周期；慢速首读测试先失败、修复后通过。
- [x] 运行相关页面、启动顺序测试及静态分析。
- [x] 运行完整 flutter test，记录既有失败和本次结果。

## Execution Notes

用户已要求直接修改并确认协议枚举；在当前会话持续完成，无额外设计审批。

独立代码审查发现的慢速首页读取顺序和多触点停止记录覆盖问题均已测试复现并修复，复核通过。完整验证结果见 `2026-10-28-lift-status-sync-verification.md`。

## Task 3: 用户补充的控制寄存器回写

**Files:** `lib/pages/joystick/ui.dart`, `lib/pages/main/ui.dart`, `lib/pages/start/ui.dart`, 对应组件与页面测试。

- [x] 独立模拟 0x0011=3、0x0010=4，观察旧实现测试失败。
- [x] 读取 0x0010 后只在不一致时写入 0x0011 合法状态，重复轮询不重发。
- [x] 共享本地命令代次及在途写入信号，三处控制入口接入，旧校正读数不能覆盖新命令。
- [x] 本地手势和主动停止优先；停止反馈滞后不能重新启动。
- [x] 两页真实 UI 测试同时断言控制寄存器已回写，覆盖两种布局。
- [x] 最终专项及独立审查复核：55 项专项测试通过；审查发现的旧后台读数及排队命令竞争均先写测试复现，再修复并复核。
- [x] 最终全量回归：563 通过、9 跳过、17 既有失败，失败名称集合与修改前一致。
