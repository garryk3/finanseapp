import 'package:finanseapp/uikit/app_summary_card.dart';
import 'package:material_ui/material_ui.dart';

/// Net worth на главной: сумма, дата и базовая валюта (10.1).
class DashboardNetWorth extends StatelessWidget {
  const DashboardNetWorth({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.onTap,
  });

  final String title, value, subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppSummaryCard(
      title: title,
      value: value,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}
