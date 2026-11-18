import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:flutter/widgets.dart';

/// Выбор действия для используемой категории (BR-CAT-4).
enum CategoryConflictAction { archive, moveAndDelete }

Future<CategoryConflictAction?> showCategoryConflictDialog(
  BuildContext context, {
  required String categoryName,
  required int entriesCount,
  required bool canMove,
}) => showAppDialog<CategoryConflictAction>(
  context: context,
  builder: (context) {
    final l10n = AppLocalizations.of(context);
    return AppDialog(
      title: AppText(l10n.categoryInUseTitle(categoryName)),
      scrollable: true,
      content: AppText(l10n.categoryInUseMessage(entriesCount)),
      actions: [
        AppButton(
          label: l10n.commonCancel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: l10n.categoryArchiveAction,
          variant: AppButtonVariant.tonal,
          onPressed: () =>
              Navigator.of(context).pop(CategoryConflictAction.archive),
        ),
        AppButton(
          label: l10n.categoryMoveAction,
          variant: AppButtonVariant.destructive,
          onPressed: canMove
              ? () =>
                    Navigator.of(context)
                        .pop(CategoryConflictAction.moveAndDelete)
              : null,
        ),
      ],
    );
  },
);
