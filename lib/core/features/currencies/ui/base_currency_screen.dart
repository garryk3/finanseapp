import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/ui/base_currency_view_model.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_radio_list_tile.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_snack_bar.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Выбор базовой валюты (BR-C-5); storage-снапшоты в RUB не меняются.
class BaseCurrencyScreen extends StatefulWidget {
  const BaseCurrencyScreen({super.key, required this.viewModel});

  final BaseCurrencyViewModel viewModel;

  @override
  State<BaseCurrencyScreen> createState() => _BaseCurrencyScreenState();
}

class _BaseCurrencyScreenState extends State<BaseCurrencyScreen> {
  late BaseCurrencyViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didUpdateWidget(covariant BaseCurrencyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      oldWidget.viewModel.dispose();
      _viewModel = widget.viewModel..init();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.baseCurrencyTitle,
      body: SignalBuilder(
        builder: (context) => switch (_viewModel.state.value) {
          ViewLoading() => Center(child: AppText(l10n.commonLoading)),
          ViewError() => AppErrorState(
            title: l10n.errorStateTitle,
            message: l10n.errorStateMessage,
            errorLabel: l10n.errorLabel,
          ),
          ViewData(:final value) => Column(
            children: [
              Expanded(
                child: AppListView(
                  children: [
                    for (final currency in value)
                      AppRadioListTile<String>(
                        label: '${currency.code} · ${currency.name}',
                        value: currency.code,
                        groupValue:
                            _viewModel.selected.value ?? value.first.code,
                        onChanged: (code) => _viewModel.selected.value = code,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton(
                  label: l10n.baseCurrencySave,
                  pending: _viewModel.busy.value,
                  onPressed: _viewModel.busy.value ? null : _save,
                ),
              ),
            ],
          ),
        },
      ),
    );
  }

  Future<void> _save() async {
    if (_viewModel.busy.value) return;
    final result = await _viewModel.save();
    if (!mounted) return;
    if (result is Failure<void>) {
      showAppSnackBar(
        context,
        message: AppLocalizations.of(context).errorStateMessage,
        isError: true,
      );
      return;
    }
    showAppSnackBar(
      context,
      message: AppLocalizations.of(context).baseCurrencySaved,
    );
    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) navigator!.pop();
  }
}
