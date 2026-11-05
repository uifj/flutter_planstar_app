import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/application/auth_providers.dart';
import 'application/profile_providers.dart';

/// 编辑资料页（企划星 `EditProfileActivity` + `fragment_edit_profile.xml`）。
///
/// ## 结构
///
/// - 头像（点击更换 → 相册/相机选择，这里 toast 说明）；
/// - 昵称（可编辑输入框）；
/// - 性别（单选 chip）；
/// - 个性签名（多行输入框，最多 50 字）；
/// - 底部保存按钮。
///
/// ## 与 Android 的差异
///
/// - **不上传头像**：需要图片上传接口（OSS），这里只展示当前头像。
///   点击头像 toast 说明"头像上传待接入"。
/// - **不实际提交保存**：企划星走 `POST v1/user/baseInfo`，这里没有
///   真实的接口实现。保存时 toast 提示"已记录（演示）"。
/// - 不做生日选择：原页用 `DatePicker`，这里展示当前值（如果有），
///   点击 toast 说明"待接入"。
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;
  int _gender = 0;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authControllerProvider);
    final user = auth.user;
    _nicknameController = TextEditingController(text: user?.displayName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _gender = user?.gender ?? 0;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final profile = ref.watch(userProfileProvider);

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: '编辑资料'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 头像
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _toast(context, '头像上传待接入'),
                child: Column(
                  children: <Widget>[
                    ClipOval(
                      child: profile.avatarUrl != null
                          ? Image.network(
                              profile.avatarUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 80,
                                height: 80,
                                color: colors.brandSubtle,
                                child: Icon(LucideIcons.user, size: 40, color: colors.brand),
                              ),
                            )
                          : Image.network(
                              profile.avatarFallbackUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 80,
                                height: 80,
                                color: colors.brandSubtle,
                                child: Icon(LucideIcons.user, size: 40, color: colors.brand),
                              ),
                            ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '点击更换头像',
                      style: TextStyle(fontSize: 12, color: colors.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 昵称
            _Label(text: '昵称'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colors.bgCard,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _nicknameController,
                maxLength: 20,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  counterStyle: TextStyle(
                    fontSize: 11,
                    color: colors.textTertiary,
                  ),
                ),
                style: TextStyle(fontSize: 14, color: colors.textPrimary),
              ),
            ),
            const SizedBox(height: 20),
            // 性别
            _Label(text: '性别'),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                _GenderChip(
                  label: '保密',
                  selected: _gender == 0,
                  onTap: () => setState(() => _gender = 0),
                ),
                const SizedBox(width: 10),
                _GenderChip(
                  label: '男',
                  selected: _gender == 1,
                  onTap: () => setState(() => _gender = 1),
                ),
                const SizedBox(width: 10),
                _GenderChip(
                  label: '女',
                  selected: _gender == 2,
                  onTap: () => setState(() => _gender = 2),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 个性签名
            _Label(text: '个性签名'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colors.bgCard,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: TextField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 50,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '写点什么介绍自己吧…',
                  hintStyle: TextStyle(fontSize: 14, color: colors.textTertiary),
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
            const SizedBox(height: 36),
            // 保存按钮
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: _nicknameController.text.trim().isNotEmpty
                    ? _save
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                  disabledBackgroundColor: colors.brandDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                child: const Text(
                  '保存',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    // 不实际提交：企划星走 POST v1/user/baseInfo，这里没有真实接口实现。
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('资料已记录（演示模式，未实际提交到服务器）')),
    );
    context.pop();
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// 段标题。
class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
    );
  }
}

/// 性别选择 chip。
class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.brandSubtle : colors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colors.brand : colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: selected ? colors.brand : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
