import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/ui/ps_empty_state.dart';

/// 应用内哔哩哔哩播放页。
///
/// 只托管官方 H5 播放页，不嵌入自定义播放器：B 站的播放地址需要签名与
/// 防盗链处理，自研播放器等于重做一套 CDN 鉴权。
class BilibiliPlayerPage extends StatefulWidget {
  const BilibiliPlayerPage({super.key, required this.bvid});

  final String bvid;

  @override
  State<BilibiliPlayerPage> createState() => _BilibiliPlayerPageState();
}

class _BilibiliPlayerPageState extends State<BilibiliPlayerPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _failed = false;

  String get _url => 'https://www.bilibili.com/video/${widget.bvid}';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF16181D))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _failed = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // 子资源（广告、脚本）失败不算页面加载失败。
            if (error.isForMainFrame == false) return;
            if (!mounted) return;
            setState(() {
              _loading = false;
              _failed = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  void _reload() {
    setState(() {
      _loading = true;
      _failed = false;
    });
    _controller.reload();
  }

  Future<void> _openInBrowser() async {
    try {
      await launchUrl(Uri.parse(_url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.bilibiliPlayerPage_79)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(
        title: context.l10n.bilibiliPlayerPage_89,
        actions: <AdaptiveAppBarAction>[
          AdaptiveAppBarAction(
            icon: LucideIcons.refreshCw,
            label: context.l10n.bilibiliPlayerPage_93,
            onPressed: _reload,
          ),
          AdaptiveAppBarAction(
            icon: LucideIcons.externalLink,
            label: context.l10n.bilibiliPlayerPage_98,
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_failed)
            ColoredBox(
              color: colors.bgPage,
              child: PsEmptyState(
                title: context.l10n.bilibiliPlayerPage_112,
                description: context.l10n.bilibiliPlayerPage_113,
                icon: LucideIcons.wifiOff,
                actionLabel: context.l10n.actionRetry,
                onAction: _reload,
              ),
            ),
        ],
      ),
    );
  }
}
