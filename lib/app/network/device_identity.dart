/// 设备标识 `dvid`。
///
/// 来源：`OkHttpUtil.getDvid()` / `generateDvid()`。
///
/// ```java
/// private static String generateDvid() {
///     String string = UUID.randomUUID().toString();
///     return string + string.charAt(3);
/// }
/// ```
///
/// 也就是 **UUID v4 后面再补一位（第 4 个字符）**，共 37 个字符。
/// 服务端下发的 `dvid` 就是这个形状（实测响应头：
/// `01d56ec7-10e7-471d-ae58-2167032a1e275` —— 36 位 UUID + 末尾的 `5`，
/// 而 UUID 第 4 个字符正是 `5`）。所以这里照抄，不自己发明格式。
///
/// `dvid` 是**设备级**标识：每个请求都带（`dvid` 头），登录/登出都不清它。
/// 它同时是推送别名的前缀（来源 `PushManager`），所以不能随手重置。
library;

import 'dart:math';

/// 生成一个新的 `dvid`。
String generateDvid([Random? random]) {
  final rng = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  // RFC 4122 v4：第 7 字节高 4 位置 0100，第 9 字节高 2 位置 10。
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String hex(int start, int end) => bytes
      .sublist(start, end)
      .map((int b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  final uuid = '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-'
      '${hex(8, 10)}-${hex(10, 16)}';
  return '$uuid${uuid[3]}';
}
