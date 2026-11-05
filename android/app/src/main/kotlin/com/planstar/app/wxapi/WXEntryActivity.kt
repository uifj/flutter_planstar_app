package com.planstar.app.wxapi

import com.jarvan.fluwx.wxapi.FluwxWXEntryActivity

/// 微信回调入口（fluwx）。
///
/// 微信 SDK 约定：回调 Activity 必须位于 `{applicationId}.wxapi.WXEntryActivity`。
/// 本项目 applicationId = `com.planstar.app`（release），故类放在此包下，
/// 与清单里声明的 `com.planstar.app.wxapi.WXEntryActivity` 完全对应。
///
/// 直接继承 fluwx 提供的 [FluwxWXEntryActivity] 即可，它负责把微信的
/// onResp（登录 / 分享 / 支付）通过 MethodChannel 转回 Dart 侧。
///
/// 注意：debug 构建带 `.debug` 后缀且用的是本机 debug 签名（非微信登记签名），
/// 微信回跳在 debug 下不可用，属预期，需要真实签名 + 登记的 release 包验证。
class WXEntryActivity : FluwxWXEntryActivity()
