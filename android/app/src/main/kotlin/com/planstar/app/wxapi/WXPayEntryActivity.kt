package com.planstar.app.wxapi

import com.jarvan.fluwx.wxapi.FluwxWXEntryActivity

/// 微信支付回调入口（fluwx）。
///
/// 微信支付要求回调 Activity 固定命名 `{applicationId}.wxapi.WXPayEntryActivity`。
/// fluwx 用同一个基类 [FluwxWXEntryActivity] 统一处理登录/分享/支付回调，
/// 这里只是按微信 SDK 的命名约定再暴露一个入口。
class WXPayEntryActivity : FluwxWXEntryActivity()
