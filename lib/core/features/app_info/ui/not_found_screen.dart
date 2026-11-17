import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/core/features/app_info/ui/not_found_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Not Found: безопасное сообщение без stack trace и сырых route-деталей.
class NotFoundScreen extends StatefulWidget {
  const NotFoundScreen({super.key, required this.viewModel});

  final NotFoundViewModel viewModel;

  @override
  State<NotFoundScreen> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen> {
  late NotFoundViewModel _viewModel = widget.viewModel;

  @override
  void didUpdateWidget(covariant NotFoundScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      oldWidget.viewModel.dispose();
      _viewModel = widget.viewModel;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppScaffold(
      body: SignalBuilder(
        builder: (context) => AppEmptyState(
          icon: Icons.search_off,
          title: l10n.notFoundTitle,
          message: l10n.notFoundMessage,
          actionLabel: l10n.notFoundHome,
          onAction: () => context.go(AppRoutes.dashboard),
        ),
      ),
    );
  }
}

/// Заглушка для secondary-маршрутов, чьи экраны придут в своих задачах.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: title,
      body: AppEmptyState(
        icon: Icons.construction_outlined,
        title: l10n.comingSoonTitle,
        message: l10n.comingSoonMessage,
        actionLabel: l10n.notFoundHome,
        onAction: () => context.go(AppRoutes.dashboard),
      ),
    );
  }
}
