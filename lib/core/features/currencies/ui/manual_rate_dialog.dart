import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/features/currencies/ui/currency_form_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:flutter/widgets.dart';

/// Ручной курс к рублю (BR-C-2): возвращает null при отмене.
Future<Decimal?> showManualRateDialog(
  BuildContext context, {
  String? currencyCode,
}) => showAppDialog<Decimal>(
  context: context,
  builder: (context) => _ManualRateDialog(currencyCode: currencyCode),
);

class _ManualRateDialog extends StatefulWidget {
  const _ManualRateDialog({this.currencyCode});

  final String? currencyCode;

  @override
  State<_ManualRateDialog> createState() => _ManualRateDialogState();
}

class _ManualRateDialogState extends State<_ManualRateDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final rate = parseManualRate(_controller.text);
    if (rate == null) {
      setState(() => _error = AppLocalizations.of(context).manualRateInvalid);
      return;
    }
    Navigator.of(context).pop(rate);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.currencyCode == null
        ? l10n.manualRateTitle
        : '${l10n.manualRateTitle} · ${widget.currencyCode}';
    return AppDialog(
      title: AppText(title),
      content: AppTextField(
        label: l10n.manualRateLabel,
        hint: l10n.manualRateHint,
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        errorText: _error,
        autofocus: true,
      ),
      actions: [
        AppButton(
          label: l10n.commonCancel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(label: l10n.commonSave, onPressed: _submit),
      ],
    );
  }
}
