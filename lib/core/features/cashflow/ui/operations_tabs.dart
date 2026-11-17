import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_segmented_control.dart';
import 'package:material_ui/material_ui.dart';

/// Переключатель вкладок журнала операций (`/operations?tab=`).
class OperationsTabs extends StatelessWidget {
  const OperationsTabs({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppSegmentedControl<String>(
      segments: [
        AppSegment(value: 'cashflow', label: l10n.operationsCashflowTab),
        AppSegment(
          value: 'transactions',
          label: l10n.operationsTransactionsTab,
        ),
      ],
      selected: {current},
      onSelectionChanged: (selection) => onChanged(selection.single),
    );
  }
}
