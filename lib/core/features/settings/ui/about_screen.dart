import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/settings/ui/about_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// О приложении: описание и версия (10.3, версия — 10.5).
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key, required this.viewModel});

  final AboutViewModel viewModel;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void didUpdateWidget(covariant AboutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      oldWidget.viewModel.dispose();
    }
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.aboutTitle,
      body: SignalBuilder(
        builder: (context) => AppListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            AppSection(
              header: l10n.appTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [AppText(l10n.aboutDescription)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
