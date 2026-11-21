import 'dart:developer' as developer;

import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/onboarding/domain/onboarding_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_select.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Первичный онбординг: приватность, базовая валюта, старт (12.4).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.repository,
    required this.settingsRepository,
    required this.currencyRepository,
    required this.onDone,
  });

  final OnboardingRepository repository;
  final SettingsRepository settingsRepository;
  final CurrencyRepository currencyRepository;
  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<Currency> _currencies = const [];
  String? _selected;
  bool _busy = false;
  bool _loadFailed = false;
  bool _saveFailed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final currencies = await widget.currencyRepository.getEnabled();
      final base = await widget.settingsRepository.getBaseCurrency();
      // Базовая валюта должна быть в списке, иначе AppSelect не найдёт значение.
      final options = currencies.any((item) => item.code == base.code)
          ? currencies
          : <Currency>[base, ...currencies];
      if (!mounted) return;
      setState(() {
        _currencies = options;
        _selected = base.code;
        _loadFailed = false;
        _saveFailed = false;
      });
    } on Object catch (error, stackTrace) {
      developer.log(
        'Не удалось загрузить онбординг',
        name: 'onboarding.load',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _loadFailed = true);
    }
  }

  Future<void> _finish({required bool applyCurrency}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _saveFailed = false;
    });
    try {
      final selected = _selected;
      if (applyCurrency && selected != null) {
        await widget.settingsRepository.setBaseCurrency(selected);
      }
      await widget.repository.complete();
      if (mounted) widget.onDone();
    } on Object catch (error, stackTrace) {
      developer.log(
        'Не удалось завершить онбординг',
        name: 'onboarding.finish',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) setState(() => _saveFailed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.onboardingTitle,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: l10n.onboardingStart,
              pending: _busy,
              onPressed: _busy ? null : () => _finish(applyCurrency: true),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l10n.onboardingSkip,
              variant: AppButtonVariant.text,
              onPressed: _busy ? null : () => _finish(applyCurrency: false),
            ),
          ],
        ),
      ),
      body: AppListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          AppSection(
            header: l10n.onboardingSetupTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(l10n.onboardingIntro),
                const SizedBox(height: AppSpacing.sm),
                AppText(l10n.onboardingPrivacy),
                const SizedBox(height: AppSpacing.md),
                if (_loadFailed)
                  AppErrorState(
                    title: l10n.errorStateTitle,
                    message: l10n.errorStateMessage,
                    retryLabel: l10n.retry,
                    onRetry: _load,
                    errorLabel: l10n.errorLabel,
                    compact: true,
                  )
                else if (_selected == null)
                  AppText(l10n.commonLoading)
                else
                  AppSelect<String>(
                    label: l10n.onboardingCurrencyLabel,
                    value: _selected,
                    searchable: true,
                    items: [
                      for (final currency in _currencies)
                        AppSelectItem(
                          value: currency.code,
                          label: currency.code,
                          subtitle: currency.name,
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      if (value != _selected) _saveFailed = false;
                      _selected = value;
                    }),
                  ),
                if (!_loadFailed && _selected != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    l10n.onboardingBaseCurrency,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (_saveFailed) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Semantics(
                    liveRegion: true,
                    child: AppText(
                      l10n.onboardingSaveError,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
