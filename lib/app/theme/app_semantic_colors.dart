// ignore_for_file: type=lint
// Зона дизайн-токенов: семантические цветовые роли приложения (см. DESIGN.md §2).
import 'package:material_ui/material_ui.dart';

/// Тон денежного значения. Расход всегда [expense] (tertiary), не error.
enum AppMoneyTone { neutral, income, expense, transfer }

/// Тон статуса объекта (цели, бейджи, подтверждения).
enum AppStatusTone { neutral, success, warning, error, archived }

/// Семантические цвета FinanseApp.
///
/// Маппинг — контракт DESIGN.md §2: income → primary, expense → tertiary,
/// transfer → secondary, success → primary, archived → onSurfaceVariant.
/// Error всегда берётся из `ColorScheme.error` и только для ошибок/destructive.
///
/// Экраны: все экраны приложения (через `Theme.of(context).extension`).
final class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.income,
    required this.onIncome,
    required this.incomeContainer,
    required this.onIncomeContainer,
    required this.expense,
    required this.onExpense,
    required this.expenseContainer,
    required this.onExpenseContainer,
    required this.transfer,
    required this.onTransfer,
    required this.success,
    required this.onSuccess,
    required this.archived,
    required this.onArchived,
  });

  /// Разрешает extension из текущей темы.
  static AppSemanticColors of(BuildContext context) =>
      Theme.of(context).extension<AppSemanticColors>() ??
      AppSemanticColors.fromScheme(Theme.of(context).colorScheme);

  /// Строит семантические роли из сгенерированной M3-схемы (без новых hex).
  factory AppSemanticColors.fromScheme(ColorScheme scheme) => AppSemanticColors(
    income: scheme.primary,
    onIncome: scheme.onPrimary,
    incomeContainer: scheme.primaryContainer,
    onIncomeContainer: scheme.onPrimaryContainer,
    expense: scheme.tertiary,
    onExpense: scheme.onTertiary,
    expenseContainer: scheme.tertiaryContainer,
    onExpenseContainer: scheme.onTertiaryContainer,
    transfer: scheme.secondary,
    onTransfer: scheme.onSecondary,
    success: scheme.primary,
    onSuccess: scheme.onPrimary,
    archived: scheme.onSurfaceVariant,
    onArchived: scheme.surfaceContainerHighest,
  );

  final Color income, onIncome, incomeContainer, onIncomeContainer;
  final Color expense, onExpense, expenseContainer, onExpenseContainer;
  final Color transfer, onTransfer;
  final Color success, onSuccess;
  final Color archived, onArchived;

  /// Контентный цвет для [AppMoneyTone] (текст сумм, дельт).
  Color moneyColor(AppMoneyTone tone) => switch (tone) {
    AppMoneyTone.income => income,
    AppMoneyTone.expense => expense,
    AppMoneyTone.transfer => transfer,
    AppMoneyTone.neutral =>
      Colors.transparent, // вызывающий код подставляет onSurface
  };

  /// Контентный цвет для [AppStatusTone].
  Color statusColor(AppStatusTone tone, ColorScheme scheme) => switch (tone) {
    AppStatusTone.success => success,
    AppStatusTone.warning => scheme.tertiary,
    AppStatusTone.error => scheme.error,
    AppStatusTone.archived => archived,
    AppStatusTone.neutral => scheme.onSurfaceVariant,
  };

  @override
  AppSemanticColors copyWith({
    Color? income,
    Color? onIncome,
    Color? incomeContainer,
    Color? onIncomeContainer,
    Color? expense,
    Color? onExpense,
    Color? expenseContainer,
    Color? onExpenseContainer,
    Color? transfer,
    Color? onTransfer,
    Color? success,
    Color? onSuccess,
    Color? archived,
    Color? onArchived,
  }) => AppSemanticColors(
    income: income ?? this.income,
    onIncome: onIncome ?? this.onIncome,
    incomeContainer: incomeContainer ?? this.incomeContainer,
    onIncomeContainer: onIncomeContainer ?? this.onIncomeContainer,
    expense: expense ?? this.expense,
    onExpense: onExpense ?? this.onExpense,
    expenseContainer: expenseContainer ?? this.expenseContainer,
    onExpenseContainer: onExpenseContainer ?? this.onExpenseContainer,
    transfer: transfer ?? this.transfer,
    onTransfer: onTransfer ?? this.onTransfer,
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    archived: archived ?? this.archived,
    onArchived: onArchived ?? this.onArchived,
  );

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      income: Color.lerp(income, other.income, t)!,
      onIncome: Color.lerp(onIncome, other.onIncome, t)!,
      incomeContainer: Color.lerp(incomeContainer, other.incomeContainer, t)!,
      onIncomeContainer: Color.lerp(
        onIncomeContainer,
        other.onIncomeContainer,
        t,
      )!,
      expense: Color.lerp(expense, other.expense, t)!,
      onExpense: Color.lerp(onExpense, other.onExpense, t)!,
      expenseContainer: Color.lerp(
        expenseContainer,
        other.expenseContainer,
        t,
      )!,
      onExpenseContainer: Color.lerp(
        onExpenseContainer,
        other.onExpenseContainer,
        t,
      )!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      onTransfer: Color.lerp(onTransfer, other.onTransfer, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      archived: Color.lerp(archived, other.archived, t)!,
      onArchived: Color.lerp(onArchived, other.onArchived, t)!,
    );
  }
}

/// Разрешение денежного тона в цвет контента с fallback на [ColorScheme.onSurface].
///
/// Экраны: Dashboard, Операции, Активы (детали), Аналитика — все суммы приложения.
Color resolveMoneyToneColor(BuildContext context, AppMoneyTone tone) {
  if (tone == AppMoneyTone.neutral) {
    return Theme.of(context).colorScheme.onSurface;
  }
  return AppSemanticColors.of(context).moneyColor(tone);
}

/// Разрешение статусного тона в цвет контента.
///
/// Экраны: Цели, Аудит, Настройки (статусы проверки обновления), подтверждения.
Color resolveStatusToneColor(BuildContext context, AppStatusTone tone) {
  final scheme = Theme.of(context).colorScheme;
  return AppSemanticColors.of(context).statusColor(tone, scheme);
}
