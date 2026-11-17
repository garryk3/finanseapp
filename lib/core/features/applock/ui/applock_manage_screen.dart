import 'dart:async';

import 'package:finanseapp/core/features/applock/logic/applock_settings_view_model.dart';
import 'package:finanseapp/core/features/applock/ui/pin_dots.dart';
import 'package:finanseapp/core/features/applock/ui/pin_keypad.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_box.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_segmented_control.dart';
import 'package:finanseapp/uikit/app_switch.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Управление защитой (BR-Sec-3…6): включение/смена/отключение PIN,
/// биометрия и auto-lock. До появления экрана настроек (10.3) доступен
/// из демо-секции домашнего экрана.
class ApplockManageScreen extends StatefulWidget {
  const ApplockManageScreen({super.key, required this.viewModel});

  final ApplockSettingsViewModel viewModel;

  @override
  State<ApplockManageScreen> createState() => _ApplockManageScreenState();
}

class _ApplockManageScreenState extends State<ApplockManageScreen> {
  ApplockSettingsViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    // Периодический опрос lockout только пока активна блокировка ввода.
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (viewModel.lockoutRemaining.value != null) {
        unawaited(viewModel.refreshLockout());
      }
    });
    unawaited(viewModel.init());
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Timer? _lockoutTimer;

  String _errorText(AppLocalizations l10n, ApplockSettingsError? error) =>
      switch (error) {
        ApplockSettingsError.wrongPin => l10n.appLockWrongPin,
        ApplockSettingsError.pinsMismatch => l10n.appLockPinsMismatch,
        ApplockSettingsError.biometricUnavailable =>
          l10n.appLockBiometricUnavailable,
        ApplockSettingsError.locked => l10n.appLockLockedOut(1),
        null => '',
      };

  /// Текст ошибки/блокировки: реальный countdown из VM, не константа.
  String _inputErrorText(AppLocalizations l10n) {
    final remaining = viewModel.lockoutRemaining.value;
    if (remaining != null) {
      return l10n.appLockLockedOut(remaining.inSeconds.clamp(1, 9999));
    }
    return _errorText(l10n, viewModel.error.value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.appLockTitle,
      body: SignalBuilder(
        builder: (context) {
          final step = viewModel.step.value;
          return step == ApplockSettingsStep.manage
              ? _buildManage(context, l10n)
              : _buildInput(context, l10n, step);
        },
      ),
    );
  }

  Widget _buildManage(BuildContext context, AppLocalizations l10n) {
    final enabled = viewModel.enabled.value;
    final error = viewModel.error.value;
    return AppListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: <Widget>[
        AppText(
          enabled ? l10n.appLockStatusOn : l10n.appLockStatusOff,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const AppBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (!enabled)
                AppButton(
                  label: l10n.appLockEnable,
                  onPressed: viewModel.startEnable,
                )
              else ...<Widget>[
                AppButton(
                  label: l10n.appLockChange,
                  variant: AppButtonVariant.tonal,
                  onPressed: viewModel.startChange,
                ),
                const AppBox(height: 8),
                AppButton(
                  label: l10n.appLockDisable,
                  variant: AppButtonVariant.destructive,
                  onPressed: viewModel.startDisable,
                ),
                const AppBox(height: 24),
                AppSwitch(
                  value: viewModel.biometricEnabled.value,
                  label: l10n.appLockBiometricSwitch,
                  onChanged: (value) =>
                      unawaited(viewModel.setBiometric(value)),
                ),
                const AppBox(height: 24),
                AppText(
                  l10n.appLockAutoLock,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const AppBox(height: 8),
                AppSegmentedControl<int>(
                  segments: <AppSegment<int>>[
                    AppSegment<int>(
                      value: 0,
                      label: l10n.appLockAutoLockImmediate,
                    ),
                    AppSegment<int>(
                      value: 1,
                      label: l10n.appLockAutoLockAfterMinutes(1),
                    ),
                    AppSegment<int>(
                      value: 5,
                      label: l10n.appLockAutoLockAfterMinutes(5),
                    ),
                    AppSegment<int>(
                      value: 15,
                      label: l10n.appLockAutoLockAfterMinutes(15),
                    ),
                  ],
                  selected: <int>{viewModel.autoLockMinutes.value},
                  onSelectionChanged: (selection) =>
                      unawaited(viewModel.setAutoLockMinutes(selection.first)),
                  expanded: false,
                ),
              ],
            ],
          ),
        ),
        if (error == ApplockSettingsError.biometricUnavailable) ...<Widget>[
          const AppBox(height: 16),
          AppText(
            _errorText(l10n, error),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  Widget _buildInput(
    BuildContext context,
    AppLocalizations l10n,
    ApplockSettingsStep step,
  ) {
    final title = switch (step) {
      ApplockSettingsStep.enterCurrent => l10n.appLockEnterCurrent,
      ApplockSettingsStep.enterNew => l10n.appLockEnterNew,
      ApplockSettingsStep.confirmNew => l10n.appLockConfirmNew,
      ApplockSettingsStep.manage => '',
    };
    final dotsLength = step == ApplockSettingsStep.enterCurrent
        ? viewModel.currentPinLength
        : 6;
    final error = viewModel.error.value;
    return Column(
      children: <Widget>[
        AppBox(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AppText(title, textAlign: TextAlign.center),
        ),
        const AppBox(height: 24),
        PinDots(
          length: dotsLength,
          filled: viewModel.entered.value.length,
          hasError: error != null,
          semanticsLabel: l10n.appLockDotsSemantics(
            viewModel.entered.value.length,
            dotsLength,
          ),
        ),
        const AppBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppText(
            _inputErrorText(l10n),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ),
        const Spacer(),
        Opacity(
          opacity: viewModel.lockoutRemaining.value != null ? 0.4 : 1,
          child: PinKeypad(
            onDigit: viewModel.onDigit,
            onBackspace: viewModel.onBackspace,
            backspaceLabel: l10n.appLockBackspace,
          ),
        ),
        const AppBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: l10n.appLockCancel,
                  variant: AppButtonVariant.text,
                  onPressed: viewModel.cancelInput,
                ),
              ),
              if (step == ApplockSettingsStep.enterNew ||
                  step == ApplockSettingsStep.confirmNew) ...<Widget>[
                const AppBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: l10n.appLockContinue,
                    onPressed: viewModel.canSubmit.value
                        ? () => unawaited(viewModel.submit())
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),
        const AppBox(height: 32),
      ],
    );
  }
}
