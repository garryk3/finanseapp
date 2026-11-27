import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/dashboard/logic/tax_estimate.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_amount_blur.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_card.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_icon_button.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:material_ui/material_ui.dart';

/// Блок «Предполагаемый налог» на Главной (D21.6).
///
/// Показывает сумму процентов по вкладам за текущий год и предполагаемый налог
/// по редактируемой ставке. Инфо-диалог поясняет формулу (X4). При
/// неустранимой ошибке курса блок остаётся видимым с inline-сообщением (X5).
class DashboardTaxEstimate extends StatefulWidget {
  const DashboardTaxEstimate({
    super.key,
    required this.estimate,
    required this.ratePercent,
    required this.error,
    required this.l10n,
    required this.formatMoney,
    required this.onRateChanged,
  });

  /// Расчёт налога; null — нет расчёта (ошибка, см. [error]).
  final TaxEstimate? estimate;

  /// Текущая ставка, % (0..100).
  final int ratePercent;

  /// Причина отсутствия расчёта; null — расчёт есть.
  final DomainErrorCode? error;

  final AppLocalizations l10n;
  final String Function(Money) formatMoney;

  /// Сохранение новой ставки (валидное значение 0..100).
  final ValueChanged<int> onRateChanged;

  @override
  State<DashboardTaxEstimate> createState() => _DashboardTaxEstimateState();
}

class _DashboardTaxEstimateState extends State<DashboardTaxEstimate> {
  late final TextEditingController _rateController = TextEditingController(
    text: '${widget.ratePercent}',
  );
  bool _rateInvalid = false;

  @override
  void didUpdateWidget(covariant DashboardTaxEstimate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ratePercent != oldWidget.ratePercent &&
        _rateController.text != '${widget.ratePercent}') {
      _rateController.text = '${widget.ratePercent}';
      _rateInvalid = false;
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  void _onRateChanged(String raw) {
    final percent = int.tryParse(raw);
    if (percent == null || !TaxEstimate.isValidRatePercent(percent)) {
      setState(() => _rateInvalid = true);
      return;
    }
    if (_rateInvalid) setState(() => _rateInvalid = false);
    widget.onRateChanged(percent);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final secondary = textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final estimate = widget.estimate;

    final Widget value;
    if (estimate != null) {
      value = AppMoneyText(
        widget.formatMoney(estimate.tax),
        style: textTheme.headlineSmall,
        maxLines: 1,
      );
    } else {
      value = AppText(
        widget.error == DomainErrorCode.rateUnavailable
            ? l10n.dashboardTaxRateUnavailable
            : l10n.dashboardNetWorthUnavailable,
        style: textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
      );
    }

    return AppSection(
      header: l10n.dashboardTaxTitle,
      padded: false,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      value,
                      if (estimate != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        AppAmountBlur(
                          child: AppText(
                            l10n.dashboardTaxBase(
                              widget.formatMoney(estimate.base),
                            ),
                            style: secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppIconButton(
                  icon: Icons.info_outline,
                  tooltip: l10n.dashboardTaxInfoTitle,
                  onPressed: () => _showInfo(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: l10n.dashboardTaxRateLabel,
              controller: _rateController,
              keyboardType: TextInputType.number,
              errorText: _rateInvalid ? l10n.dashboardTaxRateInvalid : null,
              onChanged: _onRateChanged,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInfo(BuildContext context) {
    final l10n = widget.l10n;
    return showAppDialog<void>(
      context: context,
      builder: (context) => AppDialog(
        title: AppText(l10n.dashboardTaxInfoTitle),
        content: AppText(l10n.dashboardTaxInfoBody),
        scrollable: true,
        actions: [
          AppButton(
            label: l10n.commonDone,
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
