import 'dart:async';

import 'package:collection/collection.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/features/references/ui/subgroups_view_model.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_confirm_dialog.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_floating_action_button.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_popup_menu.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_select.dart';
import 'package:finanseapp/uikit/app_segmented_control.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:finanseapp/uikit/app_snack_bar.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

enum _SubgroupAction { rename, delete }

/// Справочник банков и брокеров: CRUD и перенос активов (BR-P-1…5).
class SubgroupsScreen extends StatefulWidget {
  const SubgroupsScreen({
    super.key,
    required this.viewModel,
    required this.initialKind,
    required this.onKindChanged,
  });

  final SubgroupsViewModel viewModel;
  final SubgroupKind initialKind;
  final ValueChanged<SubgroupKind> onKindChanged;

  @override
  State<SubgroupsScreen> createState() => _SubgroupsScreenState();
}

class _SubgroupsScreenState extends State<SubgroupsScreen> {
  late SubgroupsViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.init(widget.initialKind);
  }

  @override
  void didUpdateWidget(covariant SubgroupsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      unawaited(oldWidget.viewModel.dispose());
      _viewModel = widget.viewModel..init(widget.initialKind);
      return;
    }
    // URL может сменить kind без пересоздания VM.
    _viewModel.selectKind(widget.initialKind);
  }

  @override
  void dispose() {
    unawaited(_viewModel.dispose());
    super.dispose();
  }

  AppLocalizations get _l10n => AppLocalizations.of(context);

  bool get _isBank => _viewModel.kind.value == SubgroupKind.bank;

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    final width = MediaQuery.sizeOf(context).width;
    return AppScaffold(
      title: l10n.subgroupsTitle,
      floatingActionButton: AppFloatingActionButton(
        icon: Icons.add,
        tooltip: l10n.subgroupAdd,
        onPressed: _create,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding(width),
              vertical: AppSpacing.sm,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.formMaxWidth,
                ),
                child: AppSegmentedControl<SubgroupKind>(
                  segments: [
                    AppSegment(
                      value: SubgroupKind.bank,
                      label: l10n.subgroupsBankTab,
                    ),
                    AppSegment(
                      value: SubgroupKind.broker,
                      label: l10n.subgroupsBrokerTab,
                    ),
                  ],
                  selected: {_viewModel.kind.value},
                  onSelectionChanged: (selection) {
                    widget.onKindChanged(selection.single);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: SignalBuilder(
              builder: (context) => switch (_viewModel.state.value) {
                ViewLoading() => const _LoadingList(),
                ViewError() => AppErrorState(
                  title: l10n.errorStateTitle,
                  message: l10n.errorStateMessage,
                  errorLabel: l10n.errorLabel,
                  retryLabel: l10n.retry,
                  onRetry: _viewModel.retry,
                ),
                ViewData(:final value) =>
                  value.isEmpty
                      ? AppEmptyState(
                          icon: _kindIcon,
                          title: l10n.subgroupEmptyTitle,
                          message: _isBank
                              ? l10n.subgroupEmptyMessageBank
                              : l10n.subgroupEmptyMessageBroker,
                          actionLabel: l10n.subgroupAdd,
                          onAction: _create,
                        )
                      : _list(value, l10n),
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData get _kindIcon =>
      _isBank ? Icons.account_balance_outlined : Icons.show_chart;

  Widget _list(List<SubgroupItem> items, AppLocalizations l10n) =>
      AppListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return AppListTile(
            key: ValueKey(item.subgroup.id),
            title: item.subgroup.name,
            subtitle: l10n.subgroupAssetsCount(item.assetCount),
            leading: AppIcon(_kindIcon),
            semanticLabel:
                '${item.subgroup.name}, '
                '${l10n.subgroupAssetsCount(item.assetCount)}',
            trailing: AppPopupMenu<_SubgroupAction>(
              tooltip: l10n.subgroupActionsTooltip,
              items: [
                AppPopupMenuItem(
                  value: _SubgroupAction.rename,
                  label: l10n.subgroupEditTooltip,
                  icon: Icons.edit_outlined,
                ),
                AppPopupMenuItem(
                  value: _SubgroupAction.delete,
                  label: l10n.subgroupDeleteTooltip,
                  icon: Icons.delete_outline,
                ),
              ],
              onSelected: (action) => switch (action) {
                _SubgroupAction.rename => _rename(item),
                _SubgroupAction.delete => _delete(items, item),
              },
            ),
          );
        },
      );

  Future<DomainException?> _createSubmit(String name) async {
    final result = await _viewModel.create(name);
    return result is Failure<int> ? result.error : null;
  }

  Future<DomainException?> _renameSubmit(int id, String name) async {
    final result = await _viewModel.rename(id, name);
    return result is Failure<void> ? result.error : null;
  }

  Future<void> _create() async {
    await showAppDialog<void>(
      context: context,
      builder: (context) => _NameDialog(
        title: _isBank ? _l10n.subgroupNewBank : _l10n.subgroupNewBroker,
        submit: _createSubmit,
        errorText: _errorText,
      ),
    );
  }

  Future<void> _rename(SubgroupItem item) async {
    await showAppDialog<void>(
      context: context,
      builder: (context) => _NameDialog(
        title: _l10n.subgroupRenameTitleNamed(item.subgroup.name),
        initial: item.subgroup.name,
        submit: (name) => _renameSubmit(item.subgroup.id, name),
        errorText: _errorText,
      ),
    );
  }

  Future<void> _delete(List<SubgroupItem> all, SubgroupItem item) async {
    final l10n = _l10n;
    final countResult = await _viewModel.countAssets(item.subgroup.id);
    if (!mounted) return;
    if (countResult is Failure<int>) {
      _showError(_errorText(countResult.error));
      return;
    }
    final int actualCount = (countResult as Success<int>).value;

    if (actualCount == 0) {
      final confirmed = await showAppDialog<bool>(
        context: context,
        builder: (context) => AppConfirmDialog(
          title: l10n.subgroupDeleteConfirmTitleNamed(item.subgroup.name),
          message: l10n.subgroupDeleteConfirmMessageNamed,
          confirmLabel: l10n.commonDelete,
          cancelLabel: l10n.commonCancel,
          destructive: true,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
        ),
      );
      if (confirmed != true) return;
      final result = await _viewModel.deleteIfUnused(item.subgroup.id);
      if (!mounted) return;
      _report(result, successMessage: l10n.subgroupDeleted);
      return;
    }

    final targets = all
        .where((other) => other.subgroup.id != item.subgroup.id)
        .toList();
    if (targets.isEmpty) {
      await showAppDialog<void>(
        context: context,
        builder: (context) => AppDialog(
          title: AppText(l10n.subgroupNoTargetTitle),
          content: AppText(l10n.subgroupNoTargetMessage(item.subgroup.name)),
          actions: [
            AppButton(
              label: l10n.commonCancel,
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.of(context).pop(),
            ),
            AppButton(
              label: l10n.subgroupAdd,
              onPressed: () {
                Navigator.of(context).pop();
                _create();
              },
            ),
          ],
        ),
      );
      return;
    }

    final targetId = await showAppDialog<int>(
      context: context,
      builder: (context) => _MoveDialog(
        title: l10n.subgroupInUseTitle,
        message: l10n.subgroupInUseMessageCount(actualCount),
        items: targets,
      ),
    );
    if (targetId == null) return;
    final targetName = targets
        .firstWhere((target) => target.subgroup.id == targetId)
        .subgroup
        .name;
    final result = await _viewModel.moveAndDelete(item.subgroup.id, targetId);
    if (!mounted) return;
    _report(result, successMessage: l10n.subgroupMovedAndDeleted(targetName));
  }

  void _report(Result<void> result, {String? successMessage}) {
    if (result is Failure<void>) {
      _showError(_errorText(result.error));
      return;
    }
    if (successMessage != null) {
      showAppSnackBar(context, message: successMessage);
    }
  }

  String _errorText(DomainException error) {
    final l10n = _l10n;
    final key = error.fieldErrors.values.firstOrNull;
    return switch (key) {
      'validationSubgroupDuplicate' => l10n.subgroupErrorDuplicate,
      'validationSubgroupKindMismatch' => l10n.subgroupErrorKind,
      'validationSubgroupSameTarget' => l10n.subgroupErrorSame,
      'validationSubgroupInUse' => l10n.subgroupErrorInUse,
      _ => l10n.errorStateMessage,
    };
  }

  void _showError(String message) {
    showAppSnackBar(context, message: message, isError: true);
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Column(
      children: [
        for (var i = 0; i < 4; i++) ...[
          const AppSkeleton(width: double.infinity, height: 56),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    ),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.submit,
    required this.errorText,
    this.initial,
  });

  final String title;
  final String? initial;
  final Future<DomainException?> Function(String name) submit;
  final String Function(DomainException error) errorText;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    if (widget.initial != null) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.initial!.length,
      );
    }
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await widget.submit(name);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = false;
      _error = widget.errorText(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canSave = _controller.text.trim().isNotEmpty && !_saving;
    return PopScope(
      canPop: !_saving,
      child: AppDialog(
        title: AppText(widget.title),
        content: AppTextField(
          label: l10n.subgroupNameLabel,
          controller: _controller,
          autofocus: true,
          errorText: _error,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => canSave ? _save() : null,
        ),
        actions: [
          AppButton(
            label: l10n.commonCancel,
            variant: AppButtonVariant.text,
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
          ),
          AppButton(
            label: l10n.commonSave,
            pending: _saving,
            onPressed: canSave ? _save : null,
          ),
        ],
      ),
    );
  }
}

class _MoveDialog extends StatefulWidget {
  const _MoveDialog({
    required this.title,
    required this.message,
    required this.items,
  });

  final String title;
  final String message;
  final List<SubgroupItem> items;

  @override
  State<_MoveDialog> createState() => _MoveDialogState();
}

class _MoveDialogState extends State<_MoveDialog> {
  int? _targetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDialog(
      title: AppText(widget.title),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(widget.message),
          const SizedBox(height: AppSpacing.sm),
          AppSelect<int>(
            label: l10n.subgroupMoveTarget,
            value: _targetId,
            items: [
              for (final item in widget.items)
                AppSelectItem(
                  value: item.subgroup.id,
                  label: item.subgroup.name,
                ),
            ],
            onChanged: (value) => setState(() => _targetId = value),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: l10n.commonCancel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: l10n.subgroupMoveAction,
          variant: AppButtonVariant.destructive,
          onPressed: _targetId == null
              ? null
              : () => Navigator.of(context).pop(_targetId),
        ),
      ],
    );
  }
}
