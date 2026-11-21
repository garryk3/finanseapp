import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/onboarding/domain/onboarding_repository.dart';
import 'package:finanseapp/core/features/onboarding/ui/onboarding_screen.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:material_ui/material_ui.dart';

/// Показывает онбординг только при первом запуске (12.4).
class OnboardingGate extends StatefulWidget {
  const OnboardingGate({
    super.key,
    required this.repository,
    required this.settingsRepository,
    required this.currencyRepository,
    required this.child,
  });

  final OnboardingRepository repository;
  final SettingsRepository settingsRepository;
  final CurrencyRepository currencyRepository;
  final Widget child;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool? _completed;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final completed = await widget.repository.isCompleted();
      if (mounted) setState(() => _completed = completed);
    } on Object {
      // Ошибка чтения флага не должна оставлять пустой cold start.
      if (mounted) setState(() => _completed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _completed;
    if (completed == null) return const SizedBox.shrink();
    if (completed) return widget.child;
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => OnboardingScreen(
          repository: widget.repository,
          settingsRepository: widget.settingsRepository,
          currencyRepository: widget.currencyRepository,
          onDone: () => setState(() => _completed = true),
        ),
      ),
    );
  }
}
