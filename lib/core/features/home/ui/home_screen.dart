import 'package:finanseapp/core/features/home/ui/home_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Домашний экран-заглушка каркаса: демонстрирует uikit, l10n и signals.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.appTitle,
      body: AppSection(
        header: l10n.homeDemoSection,
        child: SignalBuilder(
          builder: (context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText('${l10n.counterLabel}: ${viewModel.counter.value}'),
              const SizedBox(height: 16),
              AppButton(label: l10n.increment, onPressed: viewModel.increment),
            ],
          ),
        ),
      ),
    );
  }
}
