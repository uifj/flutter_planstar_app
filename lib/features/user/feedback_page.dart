import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 意见反馈页（企划星 `FeedbackActivity` + `fragment_feedback.xml`）。
///
/// ## 结构
///
/// - 反馈类型选择（单选 chip 行：功能建议 / 演出问题 / 支付问题 / 其他）；
/// - 反馈内容输入框（多行，最多 500 字，带字数统计）；
/// - 联系方式输入框（可选，手机号或邮箱）；
/// - 底部提交按钮。
///
/// ## 与 Android 的差异
///
/// - **不实际上传反馈内容**：企划星走 `POST v1/feedback` 接口，这里没有
///   真实的后端反馈接口实现。提交时 toast 提示"已记录（演示）"，
///   不假装发送成功。
/// - 不做图片附件上传：需要 OSS / 文件服务支持。
/// - 不做"反馈历史"：需要接口拉取已提交的反馈列表。
class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  static const List<String> _categories = <String>[
    '功能建议',
    '演出问题',
    '支付问题',
    '购票体验',
    '其他',
  ];

  int _selectedCategory = 0;
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final contentLength = _contentController.text.length;
    final canSubmit = contentLength >= 10;

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: '意见反馈'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 反馈类型
            Text(
              '反馈类型',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (var i = 0; i < _categories.length; i++)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _selectedCategory = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: i == _selectedCategory
                            ? colors.brandSubtle
                            : colors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: i == _selectedCategory
                              ? colors.brand
                              : colors.border,
                        ),
                      ),
                      child: Text(
                        _categories[i],
                        style: TextStyle(
                          fontSize: 13,
                          color: i == _selectedCategory
                              ? colors.brand
                              : colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // 反馈内容
            Text(
              '反馈内容',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '请至少填写 10 个字，以便我们更好地理解您的问题',
              style: TextStyle(fontSize: 12, color: colors.textTertiary),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colors.bgCard,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: TextField(
                controller: _contentController,
                maxLines: 6,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '请描述您遇到的问题或建议…',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: colors.textTertiary,
                  ),
                  counterStyle: TextStyle(
                    fontSize: 11,
                    color: colors.textTertiary,
                  ),
                ),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 联系方式
            Text(
              '联系方式（选填）',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '留下手机号或邮箱，方便我们与您联系',
              style: TextStyle(fontSize: 12, color: colors.textTertiary),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colors.bgCard,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _contactController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '手机号 / 邮箱',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: colors.textTertiary,
                  ),
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 36),
            // 提交按钮
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: canSubmit ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                  disabledBackgroundColor: colors.brandDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                child: Text(
                  '提交反馈',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: canSubmit ? Colors.white : colors.textDisabled,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    // 不实际提交：企划星走 POST v1/feedback，这里没有真实接口实现。
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('反馈已记录（演示模式，未实际提交到服务器）'),
      ),
    );
    context.pop();
  }
}
