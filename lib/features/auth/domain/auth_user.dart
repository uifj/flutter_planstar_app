/// 登录后的用户资料。
///
/// 字段只收登录接口里**真正会被 UI 用到**的那一部分，不是全量照搬：
/// `followHim` / `blocked` / `forceFollow` / `shopType` 之类是
/// "看别人的主页"场景才用的，登录返回里恒为默认值。
///
/// 刻意修掉两个毛病：
///
/// 1. 比较昵称时不判空，昵称为 null 就直接崩
///    ——这里 [isSame] 全程判空；
/// 2. `isComplete()` 把 `birthday == 0` 当成"没填"，但 0 是 1970-01-01
///    ——这里语义不变（0 就是没填），但把判断集中到
///    [isComplete] 一处，并写清口径。
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

/// 用户资料。
@freezed
abstract class AuthUser with _$AuthUser {
  const AuthUser._();

  /// 创建资料。
  const factory AuthUser({
    /// 用户 id。缺失或非法时兜底为 `-1`，由 [isValid] 判为未登录。
    @JsonKey(readValue: _readUserId) required int userId,

    /// 昵称。
    @JsonKey(readValue: _readUserName) String? userName,

    /// 头像 URL。空串表示没设置。
    @JsonKey(readValue: _readAvatar) @Default('') String avatar,

    /// 个性签名。
    @JsonKey(readValue: _readBio) String? bio,

    /// 性别：0 未设置 / 1 男 / 2 女。
    @JsonKey(readValue: _readGender) @Default(0) int gender,

    /// 生日（毫秒时间戳）。0 表示未设置。
    @JsonKey(readValue: _readBirthday) @Default(0) int birthday,

    /// 手机号（服务端返回的可能是脱敏后的）。
    @JsonKey(readValue: _readMobileNo) String? mobileNo,

    /// 等级（"我的"页的等级胶囊）。
    @JsonKey(readValue: _readLevel) @Default(0) int level,

    /// 粉丝数。
    @JsonKey(readValue: _readFollowerNum) @Default(0) int followerNum,

    /// 关注数。
    @JsonKey(readValue: _readFollowingNum) @Default(0) int followingNum,

    /// 想看数。
    @JsonKey(readValue: _readWantWatchNum) @Default(0) int wantWatchNum,

    /// 是否兜礼用户（"兜礼"角标）。
    @JsonKey(readValue: _readIsDouliUser) @Default(false) bool isDouliUser,

    /// 等级图标 URL。
    @JsonKey(readValue: _readBadgeIcon) String? badgeIcon,
  }) = _AuthUser;

  /// 从 JSON 解析（字段名与服务端下发的一致）。
  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  /// 是否是一个"真实存在"的用户。
  ///
  /// 未登录不能用 `-1` 之类的哨兵值表示：服务端在异常情况下也可能返回 0；
  /// 这里把 `<= 0` 一律当成无效，避免把"空用户"当成已登录。
  bool get isValid => userId > 0;

  /// 展示名。昵称为空时返回空串，由 UI 层按 l10n 决定兜底文案。
  String get displayName => (userName ?? '').trim();

  /// 脱敏手机号：`138****8000`。没有手机号时返回 `null`。
  String? get maskedMobile {
    final mobile = (mobileNo ?? '').trim();
    if (mobile.length != 11) {
      return mobile.isEmpty ? null : mobile;
    }
    return '${mobile.substring(0, 3)}****${mobile.substring(7)}';
  }

  /// 资料是否完善。
  ///
  /// 口径：头像非空、性别已填、生日已填。
  /// `birthday == 0` 视为未填（它确实是 epoch，但业务上就是"没填"）。
  bool get isComplete => avatar.isNotEmpty && gender != 0 && birthday != 0;

  /// 资料是否相同（用于"只刷新资料"vs"换账号"的区分）。
  bool isSame(AuthUser? other) {
    if (other == null) {
      return false;
    }
    return other.userId == userId &&
        other.userName == userName &&
        other.bio == bio &&
        other.avatar == avatar &&
        other.birthday == birthday &&
        other.gender == gender;
  }

  @override
  String toString() => 'AuthUser($userId, $displayName)';
}

// ── JSON 兼容读取（服务端字段可能是字符串 / 数字 / 布尔混用）──────────────

Object? _readUserId(Map<dynamic, dynamic> json, String key) =>
    _asInt(json['userId']) ?? -1;

Object? _readUserName(Map<dynamic, dynamic> json, String key) =>
    _asString(json['userName']);

Object? _readAvatar(Map<dynamic, dynamic> json, String key) =>
    _asString(json['avatar']) ?? '';

Object? _readBio(Map<dynamic, dynamic> json, String key) =>
    _asString(json['bio']);

Object? _readGender(Map<dynamic, dynamic> json, String key) =>
    _asInt(json['gender']) ?? 0;

Object? _readBirthday(Map<dynamic, dynamic> json, String key) =>
    _asInt(json['birthday']) ?? 0;

Object? _readMobileNo(Map<dynamic, dynamic> json, String key) =>
    _asString(json['mobileNo']);

Object? _readLevel(Map<dynamic, dynamic> json, String key) =>
    _asInt(json['level']) ?? 0;

Object? _readFollowerNum(Map<dynamic, dynamic> json, String key) =>
    _asInt(json['followerNum']) ?? 0;

Object? _readFollowingNum(Map<dynamic, dynamic> json, String key) =>
    _asInt(json['followingNum']) ?? 0;

Object? _readWantWatchNum(Map<dynamic, dynamic> json, String key) =>
    _asInt(json['wantWatchNum']) ?? 0;

Object? _readIsDouliUser(Map<dynamic, dynamic> json, String key) =>
    _asBool(json['isDouliUser']) ?? false;

Object? _readBadgeIcon(Map<dynamic, dynamic> json, String key) =>
    _asString(json['badgeIcon']);

int? _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

String? _asString(Object? value) {
  if (value is String) {
    return value;
  }
  if (value == null) {
    return null;
  }
  return '$value';
}

bool? _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return value == 'true' ? true : (value == 'false' ? false : null);
  }
  if (value is num) {
    return value != 0;
  }
  return null;
}
