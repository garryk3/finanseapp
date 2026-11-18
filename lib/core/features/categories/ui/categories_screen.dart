import 'dart:async';

import 'package:collection/collection.dart';
import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/categories/domain/cashflow_category.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/ui/categories_view_model.dart';
import 'package:finanseapp/core/features/categories/ui/category_conflict_dialog.dart';
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
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

enum _CategoryAction { rename, archive, delete }

/// Категории доходов/расходов: CRUD, архив, перенос записей (BR-CAT).
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({
    super.key,
    required this.viewModel,
    required this.initialKind,
    required this.onKindChanged,
  });

  final CategoriesViewModel viewModel;
  final CashflowKind initialKind;
  final ValueChanged<CashflowKind> onKindChanged;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late CategoriesViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.init(widget.initialKind);
  }

  @override
  void didUpdateWidget(covariant CategoriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      unawaited(oldWidget.viewModel.dispose());
      _viewModel = widget.viewModel..init(widget.initialKind);
      return;
    }
    _viewModel.selectKind(widget.initialKind);
  }

  @override
  void dispose() {
    unawaited(_viewModel.dispose());
    super.dispose();
  }

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    return AppScaffold(
      title: l10n.categoriesTitle,
      floatingActionButton: AppFloatingActionButton(
        icon: Icons.add,
        tooltip: l10n.categoryAdd,
        onPressed: () => context.push(AppRoutes.categoryNewFor(_kindValue)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: AppSegmentedControl<CashflowKind>(
              segments: [
                AppSegment(
                  value: CashflowKind.income,
                  label: l10n.categoriesIncomeTab,
                ),
                AppSegment(
                  value: CashflowKind.expense,
                  label: l10n.categoriesExpenseTab,
                ),
              ],
              selected: {_viewModel.kind.value},
              onSelectionChanged: (selection) {
                widget.onKindChanged(selection.single);
              },
            ),
          ),
          Expanded(
            child: SignalBuilder(
              builder: (context) => switch (_viewModel.state.value) {
                ViewLoading() => Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      for (var i = 0; i < 4; i++) ...[
                        const AppSkeleton(width: double.infinity, height: 56),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
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
                          icon: Icons.category_outlined,
                          title: l10n.categoryEmptyTitle,
                          message: l10n.categoryEmptyMessage,
                          actionLabel: l10n.categoryAdd,
                          onAction: () => context.push(
                            AppRoutes.categoryNewFor(_kindValue),
                          ),
                        )
                      : _list(value, l10n),
              },
            ),
          ),
        ],
      ),
    );
  }

  String get _kindValue =>
      _viewModel.kind.value == CashflowKind.income ? 'income' : 'expense';

  Widget _list(List<CashflowCategory> categories, AppLocalizations l10n) =>
      AppListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final badges = [
            if (category.isPreset) l10n.categoryPresetBadge,
            if (category.archivedAt != null) l10n.categoryArchivedBadge,
          ].join(' · ');
          return AppListTile(
            key: ValueKey(category.id),
            title: category.name,
            subtitle: badges.isEmpty ? null : badges,
            enabled: category.archivedAt == null,
            semanticLabel: badges.isEmpty
                ? category.name
                : '${category.name}, $badges',
            leading: AppIcon(
              category.kind == CashflowKind.income
                  ? Icons.trending_up
                  : Icons.trending_down,
            ),
            trailing: AppPopupMenu<_CategoryAction>(
              tooltip: l10n.categoryActionsTooltip,
              items: [
                AppPopupMenuItem(
                  value: _CategoryAction.rename,
                  label: l10n.commonRename,
                  icon: Icons.edit_outlined,
                ),
                if (category.archivedAt == null)
                  AppPopupMenuItem(
                    value: _CategoryAction.archive,
                    label: l10n.categoryArchiveAction,
                    icon: Icons.archive_outlined,
                  ),
                AppPopupMenuItem(
                  value: _CategoryAction.delete,
                  label: l10n.commonDelete,
                  icon: Icons.delete_outline,
                ),
              ],
              onSelected: (action) => switch (action) {
                _CategoryAction.rename => _rename(category),
                _CategoryAction.archive => _archive(category),
                _CategoryAction.delete => _delete(categories, category),
              },
            ),
          );
        },
      );

  Future<void> _rename(CashflowCategory category) async {
    await showAppDialog<void>(
      context: context,
      builder: (context) => _NameDialog(
        title: _l10n.categoryRenameNamed(category.name),
        initial: category.name,
        submit: (name) async {
          final result = await _viewModel.rename(category, name);
          return result is Failure<void> ? result.error : null;
        },
        errorText: _errorText,
      ),
    );
  }

  Future<void> _archive(CashflowCategory category) async {
    final result = await _viewModel.archive(category.id);
    if (!mounted) return;
    _report(result, success: _l10n.categoryArchived);
  }

  Future<void> _delete(
    List<CashflowCategory> all,
    CashflowCategory category,
  ) async {
    final l10n = _l10n;
    final countResult = await _viewModel.countEntries(category.id);
    if (!mounted) return;
    if (countResult is Failure<int>) {
      _showError(l10n.errorStateMessage);
      return;
    }
    final count = (countResult as Success<int>).value;
    if (count == 0) {
      final confirmed = await showAppDialog<bool>(
        context: context,
        builder: (context) => AppConfirmDialog(
          title: l10n.categoryDeleteNamed(category.name),
          message: l10n.categoryDeleteMessage,
          confirmLabel: l10n.commonDelete,
          cancelLabel: l10n.commonCancel,
          destructive: true,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
        ),
      );
      if (confirmed != true) return;
      final result = await _viewModel.deleteIfUnused(category.id);
      if (!mounted) return;
      _report(result, success: l10n.categoryDeleted);
      return;
    }

    final targets = all
        .where(
          (other) =>
              other.id != category.id &&
              other.archivedAt == null &&
              other.kind == category.kind,
        )
        .toList();
    final action = await showCategoryConflictDialog(
      context,
      categoryName: category.name,
      entriesCount: count,
      canMove: targets.isNotEmpty,
    );
    if (action == null || !mounted) return;
    if (action == CategoryConflictAction.archive) {
      final result = await _viewModel.archive(category.id);
      if (!mounted) return;
      _report(result, success: l10n.categoryArchived);
      return;
    }

    final targetId = await showAppDialog<int>(
      context: context,
      builder: (context) => _MoveDialog(
        message: l10n.categoryInUseMessage(count),
        items: targets,
      ),
    );
    if (targetId == null) return;
    final result = await _viewModel.moveAndDelete(category.id, targetId);
    if (!mounted) return;
    _report(result, success: l10n.categoryDeleted);
  }

  void _report(Result<void> result, {String? success}) {
    if (result is Failure<void>) {
      _showError(_errorText(result.error));
      return;
    }
    if (success != null) showAppSnackBar(context, message: success);
  }

  String _errorText(DomainException error) {
    final l10n = _l10n;
    final key = error.fieldErrors.values.firstOrNull;
    return switch (key) {
      'validationCategoryDuplicate' => l10n.categoryErrorDuplicate,
      'validationCategoryKindMismatch' => l10n.categoryErrorKind,
      'validationCategoryArchived' => l10n.categoryErrorArchived,
      'validationNameRequired' => l10n.categoryErrorName,
      _ => l10n.errorStateMessage,
    };
  }

  void _showError(String message) =>
      showAppSnackBar(context, message: message, isError: true);
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
  void dispose() {
    _controller.dispose();
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
    return PopScope(
      canPop: !_saving,
      child: AppDialog(
        title: AppText(widget.title),
        content: AppTextField(
          label: l10n.commonNameLabel,
          controller: _controller,
          errorText: _error,
          autofocus: true,
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
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

class _MoveDialog extends StatefulWidget {
  const _MoveDialog({required this.message, required this.items});

  final String message;
  final List<CashflowCategory> items;

  @override
  State<_MoveDialog> createState() => _MoveDialogState();
}

class _MoveDialogState extends State<_MoveDialog> {
  int? _targetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDialog(
      title: AppText(l10n.categoryMoveAction),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(widget.message),
          const SizedBox(height: AppSpacing.sm),
          AppSelect<int>(
            label: l10n.categoryMoveTarget,
            value: _targetId,
            items: [
              for (final item in widget.items)
                AppSelectItem(value: item.id, label: item.name),
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
          label: l10n.categoryMoveAction,
          variant: AppButtonVariant.destructive,
          onPressed: _targetId == null
              ? null
              : () => Navigator.of(context).pop(_targetId),
        ),
      ],
    );
  }
}
