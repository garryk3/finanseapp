// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/uikit/app_category_select.dart';
import 'package:finanseapp/uikit/app_chip.dart';

/// Chip категории с иконкой и allowlisted colorKey (иначе neutral fallback).
/// Архивная категория показывает [archivedLabel] визуально и в Semantics.
///
/// Экраны: CashflowForm (выбранная категория), фильтры Аналитики и
/// Операций по категориям, CategoriesScreen (карточки категорий).
class AppCategoryChip extends StatelessWidget {
  const AppCategoryChip({
    super.key,
    required this.label,
    this.icon,
    this.colorKey,
    this.selected = false,
    this.onSelected,
    this.archived = false,
    this.archivedLabel,
  }) : assert(!archived || archivedLabel != null);

  final String label;
  final IconData? icon;
  final String? colorKey;
  final bool selected, archived;
  final String? archivedLabel;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final color = resolveCategoryColor(context, colorKey);
    return Semantics(
      label: archived ? '$label, $archivedLabel' : label,
      child: AppChip(
        label: label,
        icon: icon,
        color: color,
        selected: selected,
        onSelected: archived ? null : onSelected,
        onDeleted: null,
      ),
    );
  }
}
