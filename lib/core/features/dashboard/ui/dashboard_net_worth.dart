import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_summary_card.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Одна строка разбивки чистого капитала (label + уже отформатированная сумма).
final class DashboardNetWorthPart {
  const DashboardNetWorthPart({required this.label, required this.value});

  final String label;
  final String value;
}

/// Net worth на главной: сумма, дата, базовая валюта и разбивка по видам
/// (задача 19.4; только ненулевые категории).
class DashboardNetWorth extends StatelessWidget {
  const DashboardNetWorth({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.breakdown = const [],
    this.onTap,
  });

  final String title, value, subtitle;
  final List<DashboardNetWorthPart> breakdown;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final secondaryStyle = textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return AppSummaryCard(
      title: title,
      value: value,
      subtitle: subtitle,
      onTap: onTap,
      footer: breakdown.isEmpty
          ? null
          : Semantics(
              label: breakdown
                  .map((part) => '${part.label} ${part.value}')
                  .join(', '),
              excludeSemantics: true,
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final part in breakdown)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxs),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppText(
                                part.label,
                                style: secondaryStyle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.62,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: AppMoneyText(
                                  part.value,
                                  style: secondaryStyle,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
