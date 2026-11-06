import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/ui/ps_empty_state.dart';
import '../../shared/ui/ps_tag.dart';
import 'application/address_providers.dart';
import 'domain/shipping_address.dart';
import '../../l10n/user_localizations.dart';
import '../../l10n/app_localizations.dart';

/// 收货地址管理（企划星 `AddressListActivity` + `item_address.xml`）。
///
/// ## 结构
///
/// - 顶部 `AdaptiveAppBar`（标题「收货地址」）；
/// - 灰色背景上的地址卡（白底、圆角 12、左右 15dp 边距）：第一行
///   「收件人 18sp 粗体 + 脱敏手机号 14sp + 默认标签」，第二行完整地址
///   （14sp、最多两行），底部 1dp 分隔线 + 操作行（设为默认 / 编辑 / 删除）；
/// - 底部固定 56dp 的「新增地址」按钮。
///
/// ## 三条不变量在控制器里，页面不重复校验
///
/// 「默认地址唯一」「删默认后第一条顶上」「新增不自动默认」都由
/// [AddressListController] 保证（见该文件注释），页面只负责渲染与派发意图。
/// 页面如果也写一套校验，两处规则迟早会漂移。
///
/// ## 与 Android 的差异
///
/// - **不做省市区三级联动选择器**：原页用 `province/city/district` 三张表 +
///   滚轮，这里让用户直接输入 `省 市 区`（输入框提示格式），把"选地址"降级为
///   "填地址"。理由是演示项目没有行政区划数据源，硬造三级联动会出现
///   "选不到自己的区"的假功能。
/// - **不做地图选点**：企划星有 `BaiduMap` 选点页，本项目无地图（见 `venue_page`
///   的说明），所以不放入口。
/// - **编辑**用同一个表单（预填原值）。原页编辑与新增是两个 Activity，
///   这里复用一套表单避免两份字段顺序不一致。
class AddressPage extends ConsumerWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final List<ShippingAddress> addresses = ref.watch(addressListProvider);

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: UserLocalizations.of(context).addressPage_49),
      body: Column(
        children: <Widget>[
          Expanded(
            child: addresses.isEmpty
                ? PsEmptyState(
                    title: UserLocalizations.of(context).addressPage_55,
                    description: UserLocalizations.of(context).addressPage_56,
                    icon: LucideIcons.mapPinOff,
                    actionLabel: UserLocalizations.of(context).addressPage_58,
                    onAction: () => _openForm(context, ref),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                    itemCount: addresses.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ShippingAddress address = addresses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AddressCard(
                          address: address,
                          onSetDefault: () => ref
                              .read(addressListProvider.notifier)
                              .setDefault(address.id),
                          onEdit: () =>
                              _openForm(context, ref, editing: address),
                          onDelete: () => _confirmDelete(context, ref, address),
                        ),
                      );
                    },
                  ),
          ),
          // 底部固定新增按钮。列表为空时上方空态里已有一个入口，
          // 这里仍然保留——两个入口都指向同一个表单，不冲突。
          if (addresses.isNotEmpty)
            _BottomBar(onAdd: () => _openForm(context, ref)),
        ],
      ),
    );
  }

  /// 打开新增 / 编辑表单。[editing] 非空即编辑。
  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    ShippingAddress? editing,
  }) async {
    final _AddressDraft? draft = await _AddressFormSheet.show(
      context,
      initial: editing,
    );
    if (draft == null) return;

    final AddressListController controller = ref.read(
      addressListProvider.notifier,
    );
    if (editing == null) {
      controller.add(
        name: draft.name,
        mobile: draft.mobile,
        region: draft.region,
        detail: draft.detail,
      );
    } else {
      controller.update(
        id: editing.id,
        name: draft.name,
        mobile: draft.mobile,
        region: draft.region,
        detail: draft.detail,
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ShippingAddress address,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(UserLocalizations.of(context).addressPage_131),
        content: Text(UserLocalizations.of(context).addressPage_132(address.name, address.maskedMobile)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(UserLocalizations.of(context).addressPage_140),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    ref.read(addressListProvider.notifier).remove(address.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(UserLocalizations.of(context).addressPage_150)));
  }
}

/// 地址卡（`item_address.xml`）。
class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  final ShippingAddress address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        address.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      address.maskedMobile,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                    if (address.isDefault) ...<Widget>[
                      const SizedBox(width: 6),
                      PsTag(
                        label: UserLocalizations.of(context).addressPage_211,
                        tone: PsTagTone.soft,
                        fontSize: 10,
                        radius: 3,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  address.fullAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: colors.divider),
          SizedBox(
            height: 46,
            child: Row(
              children: <Widget>[
                // 「设为默认」是单选项的语义，所以用圆形图标而不是文字按钮：
                // 已经是默认地址时图标实心且不可点，避免"点自己取消默认"
                // 造成列表里没有默认地址。
                Expanded(
                  child: InkWell(
                    onTap: address.isDefault ? null : onSetDefault,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            address.isDefault
                                ? LucideIcons.circleDot
                                : LucideIcons.circle,
                            size: 18,
                            color: address.isDefault
                                ? colors.brand
                                : colors.textDisabled,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            address.isDefault ? UserLocalizations.of(context).addressPage_263 : UserLocalizations.of(context).addressPage_263_2,
                            style: TextStyle(
                              fontSize: 13,
                              color: address.isDefault
                                  ? colors.brand
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _ActionButton(label: UserLocalizations.of(context).addressPage_276, onTap: onEdit),
                _ActionButton(
                  label: UserLocalizations.of(context).addressPage_278,
                  onTap: onDelete,
                  isDestructive: true,
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDestructive ? colors.error : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      padding: EdgeInsets.fromLTRB(
        15,
        10,
        15,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            backgroundColor: colors.brand,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: Text(
            UserLocalizations.of(context).addressPage_349,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

/// 表单提交出来的纯数据（不含 `id` / `isDefault`——那两个由控制器决定）。
class _AddressDraft {
  const _AddressDraft({
    required this.name,
    required this.mobile,
    required this.region,
    required this.detail,
  });

  final String name;
  final String mobile;
  final String region;
  final String detail;
}

/// 新增 / 编辑地址表单（底部面板）。
///
/// 为什么是 `showModalBottomSheet` 而不是独立页面：字段只有四个，
/// 独立页面会让"填到一半返回"的丢数据风险变高（原页有草稿缓存，
/// 这里没有）。面板里点空白可以关掉，但关掉即放弃，所以提交按钮
/// 只在四项都合法时可点，减少"填一半关掉"的挫败。
class _AddressFormSheet extends StatefulWidget {
  const _AddressFormSheet({this.initial});

  final ShippingAddress? initial;

  static Future<_AddressDraft?> show(
    BuildContext context, {
    ShippingAddress? initial,
  }) {
    return showModalBottomSheet<_AddressDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressFormSheet(initial: initial),
    );
  }

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _mobile;
  late final TextEditingController _region;
  late final TextEditingController _detail;

  @override
  void initState() {
    super.initState();
    final ShippingAddress? initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _mobile = TextEditingController(text: initial?.mobile ?? '');
    _region = TextEditingController(text: initial?.region ?? '');
    _detail = TextEditingController(text: initial?.detail ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _region.dispose();
    _detail.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _name.text.trim().isNotEmpty &&
      _isMobileValid(_mobile.text) &&
      _region.text.trim().isNotEmpty &&
      _detail.text.trim().isNotEmpty;

  /// 任一字段变化后重建，让「保存」按钮的 `onPressed` 跟着变。
  void _refresh() => setState(() {});

  static bool _isMobileValid(String raw) =>
      RegExp(r'^1[3-9]\d{9}$').hasMatch(raw.trim());

  void _submit() {
    if (!_canSubmit) return;
    Navigator.of(context).pop(
      _AddressDraft(
        name: _name.text.trim(),
        mobile: _mobile.text.trim(),
        region: _region.text.trim(),
        detail: _detail.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final bool isEditing = widget.initial != null;

    return Padding(
      // 键盘弹起时把面板顶上去，否则下面的输入框会被挡住。
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    isEditing ? UserLocalizations.of(context).addressPage_472 : UserLocalizations.of(context).addressPage_472_2,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      LucideIcons.x,
                      size: 20,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _Field(
                controller: _name,
                label: UserLocalizations.of(context).addressPage_493,
                hint: UserLocalizations.of(context).addressPage_494,
                maxLength: 20,
                onChanged: _refresh,
              ),
              _Field(
                controller: _mobile,
                label: UserLocalizations.of(context).addressPage_500,
                hint: UserLocalizations.of(context).addressPage_501,
                keyboardType: TextInputType.phone,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                onChanged: _refresh,
              ),
              _Field(
                controller: _region,
                label: UserLocalizations.of(context).addressPage_511,
                hint: UserLocalizations.of(context).addressPage_512,
                onChanged: _refresh,
              ),
              _Field(
                controller: _detail,
                label: UserLocalizations.of(context).addressPage_517,
                hint: UserLocalizations.of(context).addressPage_518,
                maxLines: 2,
                maxLength: 60,
                onChanged: _refresh,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  // 用 setState 触发重建来刷新按钮可用态：四个 controller
                  // 都挂了 listener 太重，直接在 onChanged 里 setState。
                  onPressed: _canSubmit ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.brand,
                    disabledBackgroundColor: colors.brandDisabled,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).actionSave,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 带标签的输入框。抽出来是因为四个字段的样式必须完全一致。
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  /// 内容变化时回调，用于让父级 `setState` 刷新「保存」按钮的可用态。
  final VoidCallback onChanged;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 72,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
              maxLength: maxLength,
              // 计数器对这四个字段没有意义，关掉。
              buildCounter:
                  (
                    _, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) => null,
              // 输入时要重建以刷新「保存」的可用态。
              onChanged: (_) => onChanged(),
              style: TextStyle(fontSize: 15, color: colors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                hintStyle: TextStyle(fontSize: 14, color: colors.textDisabled),
                filled: true,
                fillColor: colors.bgSubtle,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: colors.brand, width: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
