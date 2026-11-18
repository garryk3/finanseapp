import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/ui/currency_form_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_snack_bar.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';

/// Создание пользовательской валюты (BR-C-8).
class CurrencyFormScreen extends StatefulWidget {
  const CurrencyFormScreen({super.key, required this.viewModel});

  final CurrencyFormViewModel viewModel;

  @override
  State<CurrencyFormScreen> createState() => _CurrencyFormScreenState();
}

class _CurrencyFormScreenState extends State<CurrencyFormScreen> {
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _fraction = TextEditingController(text: '2');
  String? _codeError;
  String? _nameError;
  String? _fractionError;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _fraction.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.viewModel.saving.value) return;
    final l10n = AppLocalizations.of(context);
    final code = _code.text.trim().toUpperCase();
    if (!isValidCurrencyCode(code)) {
      setState(() => _codeError = l10n.currencyErrorCode);
      return;
    }
    final result = await widget.viewModel.save(
      code: code,
      name: _name.text,
      fractionDigits: parseFractionDigits(_fraction.text),
    );
    if (!mounted) return;
    if (result is Failure<void>) {
      final errors = result.error.fieldErrors;
      setState(() {
        _codeError = switch (errors['code']) {
          'validationCurrencyCodeFormat' => l10n.currencyErrorCode,
          'validationCurrencyDuplicate' => l10n.currencyErrorDuplicate,
          _ => null,
        };
        _nameError = errors['name'] == 'validationCurrencyDuplicate'
            ? l10n.currencyErrorDuplicate
            : null;
        _fractionError =
            errors['fractionDigits'] == 'validationFractionDigitsRange'
            ? l10n.currencyFractionError
            : null;
      });
      return;
    }
    showAppSnackBar(context, message: l10n.currencySaved);
    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) navigator!.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.currencyAdd,
      body: AppListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTextField(
            label: l10n.currencyCodeLabel,
            controller: _code,
            errorText: _codeError,
            maxLength: 3,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: l10n.currencyNameLabel,
            controller: _name,
            errorText: _nameError,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: l10n.currencyFractionLabel,
            controller: _fraction,
            keyboardType: TextInputType.number,
            errorText: _fractionError,
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<bool>(
            valueListenable: widget.viewModel.saving,
            builder: (context, saving, _) => AppButton(
              label: l10n.commonSave,
              pending: saving,
              onPressed: saving ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}
