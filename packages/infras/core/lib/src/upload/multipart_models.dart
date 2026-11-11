/// 分片上传的数据模型与配置。
library;

/// 取第 [partNumber] 片（1 基）上传目标的回调。
///
/// **这是本模块最重要的一行代码。** 引擎在**每次重试前**都会重新调用它，
/// 于是"凭证过期 → 重新签名"不是引擎里的一个 if 分支，而是**结构上的必然**：
/// 实现方只要在回调里做正常的取签名逻辑，刷新就自动生效。
///
/// 反面做法是 403 之后手动刷凭证再重发，属于命令式补丁；
/// 这里是依赖倒置的解法。
typedef PartUrlProvider = Future<MultipartTarget> Function(int partNumber);

/// 一片的上传目标。引擎只知道"往这个 URL PUT 这些头"，完全不知道
/// OSS / COS / 自建存储的存在。
final class MultipartTarget {
  /// 创建上传目标。
  const MultipartTarget({
    required this.url,
    this.headers = const <String, String>{},
  });

  /// 预签名 PUT URL（必须是绝对地址）。
  final String url;

  /// 该片需要附带的请求头（OSS 签名 / STS token 等）。
  final Map<String, String> headers;

  @override
  String toString() => 'MultipartTarget($url, headers: ${headers.keys.toList()})';
}

/// 分片上传配置。
///
/// 默认值一览（全部可在构造时覆盖）：
///
/// | 项 | 默认值 |
/// |---|---|
/// | 分片大小 | 20 MiB |
/// | 并发数 | 5 |
/// | 重试次数 | 5 |
/// | 重试间隔 | 1s |
/// | 进度节流 | 500ms |
final class MultipartUploadConfig {
  /// 创建配置。所有字段可覆盖。
  const MultipartUploadConfig({
    this.partSize = defaultPartSize,
    this.concurrency = 5,
    this.maxRetries = 5,
    this.retryDelay = const Duration(seconds: 1),
    this.progressThrottle = const Duration(milliseconds: 500),
  })  : assert(partSize > 0, '分片大小必须为正'),
        assert(concurrency > 0, '并发数必须为正'),
        assert(maxRetries >= 0, '重试次数不能为负');

  /// 默认分片大小：20 MiB。
  static const int defaultPartSize = 20 * 1024 * 1024;

  /// 每片字节数。
  final int partSize;

  /// 同时在传的分片数。
  final int concurrency;

  /// 单片最多重试次数（不含首次）。
  final int maxRetries;

  /// 重试间隔。
  final Duration retryDelay;

  /// 进度回调的最小间隔。0 表示每次都回调。
  final Duration progressThrottle;
}

/// 一次进度快照。
final class MultipartProgress {
  /// 创建快照。
  const MultipartProgress({
    required this.uploadedBytes,
    required this.totalBytes,
    required this.completedParts,
    required this.totalParts,
  });

  /// 已上传字节数。
  final int uploadedBytes;

  /// 总字节数。
  final int totalBytes;

  /// 已完成分片数。
  final int completedParts;

  /// 总分片数。
  final int totalParts;

  /// 完成比例（0..1）。总长为 0 时返回 1。
  double get fraction => totalBytes == 0 ? 1 : uploadedBytes / totalBytes;

  @override
  String toString() => 'MultipartProgress($completedParts/$totalParts, '
      '${(fraction * 100).toStringAsFixed(1)}%)';
}

/// 上传成功的结果。
final class MultipartUploadResult {
  /// 创建结果。
  const MultipartUploadResult({
    required this.etags,
    required this.partCount,
    required this.totalBytes,
  });

  /// 分片号（1 基）→ ETag。调用方拿到后交给业务层做 complete 请求。
  final Map<int, String> etags;

  /// 分片总数。
  final int partCount;

  /// 总字节数。
  final int totalBytes;

  @override
  String toString() =>
      'MultipartUploadResult(parts: $partCount, bytes: $totalBytes)';
}
