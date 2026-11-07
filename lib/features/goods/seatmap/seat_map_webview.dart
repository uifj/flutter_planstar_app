import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'seat_bridge.dart';
import 'seat_selection_providers.dart';

/// 选座图（WebView 实现）。
///
/// ## 职责边界
///
/// - **WebView**：只负责渲染与手势（拖动、双指缩放、点选动画）。
/// - **Flutter**：座位图数据与选中态的唯一真源。WebView 每次变更回传**全量**
///   选中集合，经 [SeatSelectionController.setSelection] 校验后落库；
///   Flutter 侧的变化（标签删除、清空、页面重建）再通过 `applySelection`
///   静默回写 WebView。
///
/// 双向通信协议见 [SeatBridgeEvent]：`ready` / `selection` / `limit`。
class SeatMapWebView extends ConsumerStatefulWidget {
  const SeatMapWebView({super.key, required this.showId, this.onLimitReached});

  final String showId;

  /// 用户在 WebView 里超出可选上限时的回调（页面用于提示）。
  final VoidCallback? onLimitReached;

  @override
  ConsumerState<SeatMapWebView> createState() => _SeatMapWebViewState();
}

class _SeatMapWebViewState extends ConsumerState<SeatMapWebView> {
  late final WebViewController _controller;

  /// JS 通道是否已就绪（收到 `ready` 或页面加载完成）。
  bool _ready = false;

  /// 最近一次下发给 WebView 的选中集合签名，用来避免双向同步回环。
  String _appliedSignature = '';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFEDF1F7))
      ..addJavaScriptChannel(
        'PsSeatBridge',
        onMessageReceived: _onBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          // ready 消息极小概率会在通道注入前发出，页面加载完成时兜底一次。
          onPageFinished: (_) {
            if (!_ready) _pushInitialData();
          },
          onWebResourceError: (error) {
            debugPrint(
              'SeatMapWebView 加载失败: ${error.errorCode} ${error.description}',
            );
          },
        ),
      )
      ..loadFlutterAsset('assets/seatmap/seat_map.html');
  }

  @override
  Widget build(BuildContext context) {
    // Flutter 侧（已选标签删除 / 清空 / 返回重进）→ WebView 回显。
    ref.listen(seatSelectionProvider(widget.showId), (previous, next) {
      if (!_ready) return;
      final signature = _signatureOf(next.selectedSeatIds);
      if (signature == _appliedSignature) return;
      _appliedSignature = signature;
      _controller.runJavaScript(
        encodeSeatSelectionScript(next.selectedSeatIds),
      );
    });

    return WebViewWidget(controller: _controller);
  }

  /// 首帧下发：座位图数据 + 已选状态（用于返回重进 / 页面重建后回显）。
  void _pushInitialData() {
    if (!mounted) return;
    _ready = true;
    final state = ref.read(seatSelectionProvider(widget.showId));
    _appliedSignature = _signatureOf(state.selectedSeatIds);
    _controller.runJavaScript(
      encodeSeatMapInitScript(
        mapData: state.mapData,
        maxSeats: SeatSelectionState.maxSeats,
        selectedSeatIds: state.selectedSeatIds,
      ),
    );
  }

  void _onBridgeMessage(JavaScriptMessage message) {
    final event = parseSeatBridgeEvent(message.message);
    switch (event) {
      case SeatBridgeReady():
        _pushInitialData();
      case SeatBridgeSelection(:final seatIds):
        // 先记录签名：随后 provider 触发的 listen 不应再把同一份数据回写。
        _appliedSignature = _signatureOf(seatIds);
        ref
            .read(seatSelectionProvider(widget.showId).notifier)
            .setSelection(seatIds);
      case SeatBridgeLimit():
        widget.onLimitReached?.call();
      case null:
        break;
    }
  }

  static String _signatureOf(Set<int> ids) {
    final sorted = ids.toList()..sort();
    return sorted.join(',');
  }
}
