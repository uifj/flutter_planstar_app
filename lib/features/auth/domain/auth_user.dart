/// 登录后的用户资料（来源 `lib\account\UserProfile` + `lib\domain\UserBean`）。
///
/// 字段是 `UserBean` 里**真正会被 UI 用到**的那一部分，不是全量照搬：
/// `UserBean` 有 26 个字段，其中 `followHim` / `blocked` / `forceFollow` /
/// `shopType` 之类是"看别人的主页"场景才用的，登录返回里恒为默认值。
///
/// 刻意修掉来源的两个毛病：
///
/// 1. `UserProfile.isSame()` 里 `getUserName().equals(...)` 对 null 直接 NPE
///    （23 页 §3.6）——这里 [isSame] 全程判空；
/// 2. `isComplete()` 把 `birthday == 0` 当成"没填"，但 0 是 1970-01-01
///    （23 页 §3.6 的注）——这里语义不变（0 就是没填），但把判断集中到
///    [isComplete] 一处，并写清口径。
library;

/// 用户资料。
final class AuthUser {
  /// 创建资料。
  const AuthUser({
    required this.userId,
    this.userName,
    this.avatar = '',
    this.bio,
    this.gender = 0,
    this.birthday = 0,
    this.mobileNo,
    this.level = 0,
    this.followerNum = 0,
    this.followingNum = 0,
    this.wantWatchNum = 0,
    this.isDouliUser = false,
    this.badgeIcon,
  });

  /// 用户 id。未登录时来源用 `-1` 表示（`AccountService.userId()`）。
  final int userId;

  /// 昵称。
  final String? userName;

  /// 头像 URL。空串表示没设置（来源 `UserBean.avatar` 默认 `""`）。
  final String avatar;

  /// 个性签名。
  final String? bio;

  /// 性别：0 未设置 / 1 男 / 2 女（来源 `UserBean.gender`）。
  final int gender;

  /// 生日（毫秒时间戳）。0 表示未设置。
  final int birthday;

  /// 手机号（服务端返回的可能是脱敏后的）。
  final String? mobileNo;

  /// 等级（"我的"页的等级胶囊）。
  final int level;

  /// 粉丝数。
  final int followerNum;

  /// 关注数。
  final int followingNum;

  /// 想看数。
  final int wantWatchNum;

  /// 是否兜礼用户（"兜礼"角标）。
  final bool isDouliUser;

  /// 等级图标 URL。
  final String? badgeIcon;

  /// 从 JSON 解析（字段名对齐 `UserBean`）。
  factory AuthUser.fromJson(Map<String, Object?> json) {
    return AuthUser(
      userId: _asInt(json['userId']) ?? -1,
      userName: _asString(json['userName']),
      avatar: _asString(json['avatar']) ?? '',
      bio: _asString(json['bio']),
      gender: _asInt(json['gender']) ?? 0,
      birthday: _asInt(json['birthday']) ?? 0,
      mobileNo: _asString(json['mobileNo']),
      level: _asInt(json['level']) ?? 0,
      followerNum: _asInt(json['followerNum']) ?? 0,
      followingNum: _asInt(json['followingNum']) ?? 0,
      wantWatchNum: _asInt(json['wantWatchNum']) ?? 0,
      isDouliUser: _asBool(json['isDouliUser']) ?? false,
      badgeIcon: _asString(json['badgeIcon']),
    );
  }

  /// 序列化（用于本地缓存，字段名与 [AuthUser.fromJson] 对称）。
  Map<String, Object?> toJson() => <String, Object?>{
    'userId': userId,
    'userName': userName,
    'avatar': avatar,
    'bio': bio,
    'gender': gender,
    'birthday': birthday,
    'mobileNo': mobileNo,
    'level': level,
    'followerNum': followerNum,
    'followingNum': followingNum,
    'wantWatchNum': wantWatchNum,
    'isDouliUser': isDouliUser,
    'badgeIcon': badgeIcon,
  };

  /// 是否是一个"真实存在"的用户。
  ///
  /// 来源用 `userId == -1` 表示未登录，但服务端在异常情况下也可能返回 0；
  /// 这里把 `<= 0` 一律当成无效，避免把"空用户"当成已登录。
  bool get isValid => userId > 0;

  /// 展示名。昵称为空时回落到"票友"（来源的默认昵称）。
  String get displayName {
    final name = (userName ?? '').trim();
    return name.isEmpty ? '票友' : name;
  }

  /// 脱敏手机号：`138****8000`。没有手机号时返回 `null`。
  String? get maskedMobile {
    final mobile = (mobileNo ?? '').trim();
    if (mobile.length != 11) {
      return mobile.isEmpty ? null : mobile;
    }
    return '${mobile.substring(0, 3)}****${mobile.substring(7)}';
  }

  /// 资料是否完善（来源 `UserProfile.isComplete()`）。
  ///
  /// 口径与来源一致：头像非空、性别已填、生日已填。
  /// `birthday == 0` 视为未填（它确实是 epoch，但业务上就是"没填"）。
  bool get isComplete =>
      avatar.isNotEmpty && gender != 0 && birthday != 0;

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
