import 'package:collection/collection.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/ui/category_form_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_form_section.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_snack_bar.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Создание категории выбранного типа (BR-CAT-1…6).
class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key, required this.viewModel});

  final CategoryFormViewModel viewModel;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _name = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.viewModel.busy.value) return;
    final l10n = AppLocalizations.of(context);
    final result = await widget.viewModel.create(_name.text);
    if (!mounted) return;
    if (result is Failure<int>) {
      final key = result.error.fieldErrors.values.firstOrNull;
      setState(() {
        _error = switch (key) {
          'validationCategoryDuplicate' => l10n.categoryErrorDuplicate,
          'validationNameRequired' => l10n.categoryErrorName,
          _ => l10n.errorStateMessage,
        };
      });
      return;
    }
    showAppSnackBar(context, message: l10n.categorySaved);
    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) navigator!.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kindLabel = widget.viewModel.kind == CashflowKind.income
        ? l10n.categoriesIncomeTab
        : l10n.categoriesExpenseTab;
    return AppScaffold(
      title: l10n.categoryNewTitle,
      body: SignalBuilder(
        builder: (context) => AppListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppFormSection(
              title: kindLabel,
              children: [
                AppTextField(
                  label: l10n.commonNameLabel,
                  controller: _name,
                  errorText: _error,
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.commonSave,
                  pending: widget.viewModel.busy.value,
                  onPressed: widget.viewModel.busy.value ? null : _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
