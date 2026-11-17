import 'dart:async';

import 'package:finanseapp/core/features/applock/logic/applock_view_model.dart';
import 'package:finanseapp/core/features/applock/ui/pin_dots.dart';
import 'package:finanseapp/core/features/applock/ui/pin_keypad.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_box.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Экран блокировки (BR-Sec-6): PIN-клавиатура, ошибки, lockout-таймер
/// и опциональная биометрия. Кнопка «назад» не обходит защиту.
class ApplockScreen extends StatefulWidget {
  const ApplockScreen({super.key, required this.viewModel});

  final ApplockViewModel viewModel;

  @override
  State<ApplockScreen> createState() => _ApplockScreenState();
}

class _ApplockScreenState extends State<ApplockScreen> {
  Timer? _lockoutTimer;

  ApplockViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    // Периодический опрос только пока активен lockout.
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: AppScaffold(
        title: l10n.appLockLockTitle,
        body: SignalBuilder(
          builder: (context) {
            final error = viewModel.error.value;
            final remaining = viewModel.lockoutRemaining.value;
            return Column(
              children: <Widget>[
                const AppBox(height: 48),
                PinDots(
                  length: viewModel.pinLength,
                  filled: viewModel.entered.value.length,
                  hasError: error != null,
                  semanticsLabel: l10n.appLockDotsSemantics(
                    viewModel.entered.value.length,
                    viewModel.pinLength,
                  ),
                ),
                const AppBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppText(
                    error == ApplockInputError.wrongPin
                        ? l10n.appLockWrongPin
                        : remaining != null
                        ? l10n.appLockLockedOut(
                            remaining.inSeconds.clamp(1, 9999),
                          )
                        : '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                const Spacer(),
                Opacity(
                  opacity: remaining != null ? 0.4 : 1,
                  child: PinKeypad(
                    onDigit: viewModel.onDigit,
                    onBackspace: viewModel.onBackspace,
                    backspaceLabel: l10n.appLockBackspace,
                  ),
                ),
                const AppBox(height: 16),
                if (viewModel.biometricVisible.value)
                  AppButton(
                    label: l10n.appLockBiometricUnlock,
                    variant: AppButtonVariant.tonal,
                    onPressed: () => unawaited(
                      viewModel.authenticateBiometric(
                        reason: l10n.appLockBiometricReason,
                      ),
                    ),
                  ),
                const AppBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}
