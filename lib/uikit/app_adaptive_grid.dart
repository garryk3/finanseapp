// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'package:material_ui/material_ui.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';

/// Адаптивная контентная сетка для узких и широких экранов (телефон /
/// fold / планшет).
///
/// Поведение по ширине (LayoutBuilder, не platform — DESIGN.md §4):
/// - `< 600dp` — одна колонка, padding 16dp, gap 16dp;
/// - `>= 600dp` — [maxColumns] (по умолчанию 2) равные колонки с gap 24dp.
///
/// Контент центрируется с ограничением ширины: [maxWidth] (по умолчанию
/// `AppSpacing.contentMaxWidth`). Формы на широких экранах остаются
/// одной колонкой: `AppAdaptiveGrid(maxColumns: 1, maxWidth: AppSpacing.formMaxWidth)`.
///
/// Заполняется сверху вниз, слева направо: порядок [children] — визуальный
/// порядок чтения. Каждая ячейка stretch по высоте своей строки.
///
/// Экраны: все master-экраны на fold/планшете — Dashboard (summary + cashflow
/// + цели + последние операции), Активы, Цели, Аналитика, Настройки, Ещё.
/// Формы (AccountForm, TransactionForm, CashflowForm, GoalForm и др.) —
/// через `maxColumns: 1` для центрирования по formMaxWidth.
class AppAdaptiveGrid extends StatelessWidget {
  const AppAdaptiveGrid({
    super.key,
    required this.children,
    this.maxColumns = 2,
    this.maxWidth = AppSpacing.contentMaxWidth,
  }) : assert(maxColumns >= 1);

  final List<Widget> children;
  final int maxColumns;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final twoColumns =
            maxColumns > 1 && width >= AppSpacing.twoColumnBreakpoint;
        final columns = twoColumns ? maxColumns : 1;
        final horizontalPadding = AppSpacing.screenPadding(width);
        final gap = twoColumns ? AppSpacing.lg : AppSpacing.md;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: _buildColumns(columns, gap),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColumns(int columns, double gap) {
    if (columns == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _spaced(children, gap),
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final chunk = children.sublist(
        i,
        i + columns > children.length ? children.length : i + columns,
      );
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _spacedRow(chunk, columns, gap),
          ),
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: _spaced(rows, gap));
  }

  List<Widget> _spaced(List<Widget> items, double gap) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) result.add(SizedBox(height: gap));
      result.add(items[i]);
    }
    return result;
  }

  List<Widget> _spacedRow(List<Widget> items, int columns, double gap) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) result.add(SizedBox(width: gap));
      result.add(Expanded(child: items[i]));
    }
    // Нечётный хвост: последняя ячейка растягивается на свободную колонку.
    if (items.length < columns) {
      result.add(SizedBox(width: gap));
      result.add(Expanded(child: const SizedBox.shrink()));
    }
    return result;
  }
}
