# Foundations и theme contracts

## 1. Цвет

`AppTheme.light()` и `AppTheme.dark()` строятся через Material 3
`ColorScheme.fromSeed(seedColor: Color(0xFF2E7D32), brightness: ...)`. Seed является
**provisional**, не утверждённым бренд-цветом. Полные hex/OKLCH палитры не копировать из
другого приложения и не записывать вручную: фактические роли вычисляет Flutter.

```dart
enum AppMoneyTone { neutral, income, expense, transfer }
enum AppStatusTone { neutral, success, warning, error, archived }

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
  final Color income, onIncome, incomeContainer, onIncomeContainer;
  final Color expense, onExpense, expenseContainer, onExpenseContainer;
  final Color transfer, onTransfer;
  final Color success, onSuccess;
  final Color archived, onArchived;

  @override
  AppSemanticColors copyWith(/* те же nullable поля */);
  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t);
}
```

Semantic colors выбираются из существующих M3 roles в `app_semantic_colors.dart`:
income — primary, expense — tertiary (не error), transfer — secondary, success — primary,
archived — onSurfaceVariant/surfaceContainerHighest. Error всегда `ColorScheme.error` и
только для ошибки/destructive action. Это сопоставление — контракт, новые hex не нужны.

Проверка WCAG вычисляется тестом для фактических pairs light/dark: обычный текст ≥4.5:1,
large text/icons/boundaries ≥3:1. Если generated seed pair не проходит, меняется mapping
на M3 role, а не добавляется произвольный оттенок.

## 2. Spacing, sizing, shapes

```dart
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double minTouchTarget = 48;
  static const double contentMaxWidth = 1200;
  static const double formMaxWidth = 640;
}

abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}
```

- Screen padding compact 16dp, expanded 24dp; section gap 24dp; item gap 8/12dp.
- Card radius 16, inputs/buttons 12 или M3 full shape по их theme, sheets 24 top corners.
- Elevation преимущественно 0; иерархия через surfaceContainer roles и 1dp outlineVariant.
- Только реальный primary FAB может иметь M3 elevation/shadow; декоративные shadows нет.

## 3. Типографика

Используется Material type scale без самостоятельного font family:

| Назначение | Theme style |
|---|---|
| Page title | headlineSmall / AppTopAppBar large |
| Section title | titleMedium |
| Card/asset title | titleSmall |
| Body, list | bodyMedium |
| Supporting/meta | bodySmall |
| Primary financial value | headlineSmall, tabular figures |
| List amount | titleSmall, tabular figures |
| Button/label | labelLarge/labelMedium |

`AppMoneyText` включает `FontFeature.tabularFigures()`, но не отключает system font scale.
Очень длинные значения переносятся в details; в list допускается maxLines 1 + semantics
полного значения. Отрицательный знак не заменяется цветом.

## 4. Layout и motion

- Breakpoints: compact `<600`, medium `600…839`, expanded `>=840`.
- Forms centered max 640; dashboards max 1200, columns 1/2 по constraints, не по platform.
- List uses lazy builder для неограниченных journals; grids имеют bounded aspect/main extent,
  не зависящий от одной строки текста.
- Motion standard M3 150–300ms, без parallax/confetti/glass. Progress pending использует
  `CircularProgressIndicator` внутри AppButton/AppSpinner, а не layout shift.

## 5. Chart tokens

```dart
enum AppChartSeriesKey { netWorth, income, expense, assets, goals }

abstract final class ChartSeriesColors {
  static Color resolve(BuildContext context, AppChartSeriesKey key);
}
```

`resolve` маппит netWorth→primary, income→semantic income, expense→semantic expense,
assets→secondary, goals→tertiary. Различие series дублируется dash/marker/legend label.
Grid/axis — outlineVariant/onSurfaceVariant. Конкретные raw chart colors не разбросаны по UI.

## 6. Foundation tests

- Light/dark extensions доступны на всех themes и lerp не возвращает null.
- Contrast test проверяет вычисленные pairs, не hardcoded ожидание hex.
- 48dp constraints для button/icon/switch/list actions; font scale 1.3 не меняет tokens.
- Seed остаётся единственным literal app brand color вне chart/test fixtures.
